import numpy as np
import gym # open ai gym
import os,re,shutil,argparse
import time
import torch
import random
import subprocess
from static_env import StaticEnv
import pandas as pd
from transformers import AutoTokenizer, AutoModelForCausalLM
from datetime import datetime
from openai import OpenAI

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "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"))

def get_completion(
    messages: list[dict[str, str]],
    model: str = "gpt-4o",
    max_tokens=2048,
    temperature=1,
    stop=None,
    tools=None,
    logprobs=None,
    top_logprobs=None,
) -> tuple:
    params = {
        "model": model,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "stop": stop,
        "logprobs": logprobs,
        "top_logprobs": top_logprobs,
    }
    if tools:
        params["tools"] = tools

    start_time = time.time()
    completion = client.chat.completions.create(**params)
    end_time = time.time()
    print("Temp: ", temperature)
    response_time = end_time - start_time
    print(f"API response time: {response_time:.6f} seconds")
    
    return completion, response_time

class LLMQueryEnv(gym.Env, StaticEnv):
    
    def __init__(self, csv_logger=None, row_data=None, op = "mcts", orig_prompt="def hello_world():", orig_module="hello_world", file_path = "", tb_path = "", dump_path = "", temp = 0):
        self.op = op
        self.csv_logger = csv_logger
        self.row_data = row_data
        self.orig_prompt = orig_prompt
        self.init_state = orig_prompt
        self.num_gen_tokens=0
        self.sim_gen_tokens=0
        self.n_actions = 5
        self.stopwords = ['<|endoftext|>']
        self.trimword = ['endmodule']
        self.temp = temp
        self.depth=2048
        self.orig_module = orig_module
        self.prompt_path = file_path
        self.tb_path = tb_path
        self.dumppath = dump_path
        self.non_compilable_attempts = 0
        compilation_output = None
        self.compilable = False
        self.functional = False
        self.first_successful_product = None
        self.beam_count = 0
        self.cumul_token_time = 0

    def extract_verilog_code(self, input_string):
        """
        Extracts and trims the code between the first and last instance of backticks of any length,
        and removes the word 'verilog' if it appears directly after the first set of backticks.
        
        Args:
        input_string (str): The input string containing the code block.
        
        Returns:
        str: The trimmed code, or an empty string if no code is found.
        """
        # Match the first occurrence of backticks of any length and the content within
        pattern = re.compile(r"(`+)(.*?)\1", re.DOTALL)
        match = pattern.search(input_string)
        
        if match:
            print("trimming text between  ```")
            # Get the content between the first match
            content = match.group(2)
            
            # Remove the word 'verilog' if it appears directly after the first set of backticks
            if content.strip().lower().startswith('verilog'):
                print("trimming text with ```verilog")
                content = content[len('verilog'):].strip()
            
            return content.strip()
        else:
            print("No trimming of ``` needed.")
            return input_string


    def get_tokenized_state(self,prompt):
        input_ids = self.tokenizer(prompt, return_tensors="pt").input_ids
        return input_ids.numpy()

    def get_initial_state(self):
        state = self.init_state
        return state

    def reset(self):
        """ Go back to the initial state. """
        state = self.init_state
        return state

    def trim_with_stopwords(self, currentState):
        print("Trimming the result to last instance of endmodule...")
        for w in sorted(self.trimword, key=len, reverse=True):
            if currentState.endswith(w):
                currentState = currentState[:-len(w)], w
                # print('Trimmed', repr(currentState))
                return currentState

    def isPromptComplete(self,currentState,depth):
        for w in sorted(self.trimword, key=len, reverse=True):
            if currentState.endswith(w):
                print("State ends with endmodule")
                self.verilogFunctionalityCheck(currentState)
                if self.compilable:     #if compilable, finish prompt generation.
                    return True
                elif b'Unknown module type' in self.compilation_output:    #if unknown module, continue generation.
                    return False
                else:
                    return True
            else:
                print("State does not end with endmodule - not complete.")
                return False
            
    def verilogFunctionalityCheck(self, currentState):
        verilog_code = currentState
        verilog_code = verilog_code.replace('\\n', '\n')
        verilog_code = verilog_code.replace('\\t', '\t')
        print("Initiating comile/functionality check.")
        print("VERILOG CODE:")
        print(verilog_code)
        #Creating folder, writing current verilog file.
        module_dump_folder = self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module
        if not os.path.exists(module_dump_folder):
            try:
                os.makedirs(module_dump_folder, mode=0o777)
            except OSError as e:
                print("Error creating dump file: ", e)
        output_verilog_file = str(os.getpid()) + "_" + self.orig_module + ".v"       
        output_file_path = os.path.join(module_dump_folder, output_verilog_file)
        with open(output_file_path, 'w') as temp_file:
            temp_file.write(verilog_code)

        self.row_data['verilog'] = verilog_code

        os.chmod(output_file_path, 0o777)
        #Setting the testbench file path (assuming in same location as prompt file).
        self.compilable = self.compilation_check(output_file_path, self.tb_path)
        #Call functionality check if compilable.
        if self.compilable:
            self.functional = self.functionality_check()
        
        return 0

    def getPromptScore(self):
        print("Running getPromptScore: ")

        if not self.compilable:

            self.row_data['area'] = 'N/A'
            self.row_data['delay'] = 'N/A'
            self.row_data['score'] = -1
            return -1
        
        #TMP EDIT!
        if not self.functional:
            self.row_data['area'] = 'N/A'
            self.row_data['delay'] = 'N/A'
            self.row_data['score'] = -.1
            return  -.1
        
        bash_script = "scripts/synth_gcd.sh"

        module_dump_folder = self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module
        #Creating dump file for results to be placed if not already created.
        if not os.path.exists(module_dump_folder):
            try:
                os.makedirs(module_dump_folder, mode=0o777)
            except OSError as e:
                print("Error creating dump file: ", e)
        #Editing the bash script to run the output verilog module.
        new_script_path = os.path.join(module_dump_folder, "synth_script.sh")
        print(self.orig_module)
        print(new_script_path)
        shutil.copy(bash_script, new_script_path)
        x= self.edit_script_variables(new_script_path, self.orig_module, str(os.getpid()) + '_' + self.orig_module + ".v")

        #Running the script file (with executable permission).
        try:
            print("Running bash")
            subprocess.run(['bash', '-c', f'chmod +x {new_script_path} && {new_script_path}'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running bash script: {e}")

        print("Retrieving snythesis results.")
        logfile_path = module_dump_folder + "/yosys_synth.log"
        if os.path.isfile(logfile_path):
            area_value = self.extract_area_from_log(logfile_path)
            delay_value = self.extract_delay_from_log(logfile_path)
            if(self.functional and area_value is not None and delay_value is not None):
                area_value = float(area_value)
                delay_value = float(delay_value)
                current_area_delay_product = area_value * delay_value
                if(self.first_successful_product == None):
                    self.first_successful_product = current_area_delay_product
                
                reward = .1 + (1 - (current_area_delay_product / self.first_successful_product))

                print()
                print("Currently displaying area/delay scores for ", self.orig_module, " module.")
                print("Area of the chip design is: ", area_value)
                print("Delay value for the chip design is: ", delay_value)
                print("Product: ", current_area_delay_product)
                print("Score (1/chip area): ", reward)
                self.row_data['area'] = area_value
                self.row_data['delay'] = delay_value
                self.row_data['score'] = reward

                return reward
            else:
                #This should not occur - error in retrieving results.
                print("Error retrieving area/delay from results.")
                self.row_data['area'] ='N/A'
                self.row_data['delay'] = 'N/A'
                self.row_data['score'] = 1
                return 1
        else:
            print("Filepath of Yosys results not recognized.")
            return None
    
    def compilation_check(self, module_path, testbench_path=None):
         # Compile the Verilog code using the iVerilog
        print("Compilation check...")
        try:
            compile_output = subprocess.check_output(['iverilog', '-o', os.path.join(self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module, str(os.getpid()) + '_simulation'), testbench_path, module_path], stderr=subprocess.STDOUT)
            compile_exit_code = 0  # Compilation successful
            self.compilation_output = None
            print("Output Verilog module compiles successfully.")
            return True
        except subprocess.CalledProcessError as e:
            # Compilation failed, get error message
            compile_output = e.output
            compile_exit_code = e.returncode
            print("Verilog compilation failed, error: ", compile_exit_code)
            print("Compilation output: ", compile_output)
            self.compilation_output = compile_output
            return False

    #Helper function to check the functionality of output Verilog code against its respective testbench.
    def functionality_check(self):
        print("Functionality check...")
        try:
            sim_path = os.path.join(self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module, str(os.getpid()) + '_simulation')
            simulation_output = subprocess.check_output(['vvp', sim_path], stderr=subprocess.STDOUT)
            simulation_exit_code = 0
        except subprocess.CalledProcessError as e:
            simulation_output = e.output
            simulation_exit_code = e.returncode

        if simulation_exit_code == 0:
            print("Verilog testbench simulation ran successfully.")
            if b"all tests passed" in simulation_output or b"All tests passed" in simulation_output:
                print("Simulation output: ", simulation_output, end='\n\n')
                print("All testbench tests passed!")
                return True
            else:
                print("Some testbench tests failed.")
                print("Simulation output: ", simulation_output,end='\n\n')
                return False
        else: 
            print("Verilog testbench simulation failed.")
            print("Simulation output: ", simulation_output,end='\n\n')
            return False
        
    #Helper - writes to the bash script to run the specific design/verilog file being synthesized.
    def edit_script_variables(self, filename, design_name, file_name):
        with open(filename, "r") as file:
            lines = file.readlines()
        for i, line in enumerate(lines):
            if line.startswith("export ROOT_DIR="):
                lines[i] = f'export ROOT_DIR={os.getcwd()}\n'
            if line.startswith("export MODULE_DIR="):
                lines[i] = f'export MODULE_DIR={self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module}\n'
            if line.startswith("export DESIGN_NAME="):
                #lines[i] = f'export DESIGN_NAME={design_name}\n'
                lines[i] = f'export DESIGN_NAME={design_name}\n'
            elif line.startswith("export VERILOG_FILE="):
                lines[i] = f'export VERILOG_FILE={"${MODULE_DIR}" + "/" + file_name}\n'
            elif line.startswith("export OUTPUT_NAME="):
                lines[i] = f'export OUTPUT_NAME={"${MODULE_DIR}" + "/" + file_name}\n'
            elif line.startswith("export DUMP_DIR="):
                lines[i] = f'export DUMP_DIR={self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module}\n'
        with open(filename, "w") as file:
            file.writelines(lines)
        
    #Helper - retrieving the delay value from the Yosys log file.
    def extract_delay_from_log(self, filepath):
        with open(filepath, "r") as file:
            for line in file:
                if "Delay = " in line:
                    parts = line.split()
                    for i, part in enumerate(parts):
                        if part == "Delay":
                            return parts[i + 2]
        print("Delay could not be found in synthesis results.")
        return None
    
    #Helper - retrieving the area value from the Yosys log file.
    def extract_area_from_log(self, filepath):
        #Reading data.
        with open(filepath, "r") as file:
            for line in file:
                if "Chip area for module" in line:
                    parts = line.split(':')
                    if len(parts) >= 2:
                        chip_area = parts[-1].strip()
                        return chip_area
        print("Error: Chip area not found in syntheis results.")
        return None

    def next_state(self, state, action):
        nextState = state + action
        return nextState

    def is_done_state(self,state,depth):
        if self.isPromptComplete(state,depth):
            return True
        if depth>=self.depth:
            self.verilogFunctionalityCheck(state)
            return True
        else:
            return False

    def getLLMestimates(self,state):
        print("getLLMestimates: prior state:")
        print(state)
        completion = client.chat.completions.create(
        model="gpt-4o",
        messages=[
              {"role": "system", "content": "You are a code completion model. You generate Verilog code that has correct syntax and functionality. \
            You must first analyze the provided information about a Verilog module and its incomplete Verilog module code (top_module()). \
            In your response, you must generate only the single next token that correctly continues the code sequence from the end of the prompt. \
            This token should be able to be directly be appended to the end of the Verilog in the prompt string without syntax issues. \
            (i.e. Make sure the token contains prepended spaces or newlines if needed).\
            Do not generate any formatting tokens, such as ```verilog or ```."},
                        {"role": "user", "content": state}
        ],
        logprobs=True,
        top_logprobs=self.n_actions,
        max_tokens=1,
        temperature=0
        )

        linear_probs = []
        tokens = []
        if completion.choices and completion.choices[0].logprobs and completion.choices[0].logprobs.content:
            for item in completion.choices[0].logprobs.content[0].top_logprobs:
                linear_probs.append(np.round(np.exp(item.logprob) * 100, 2))
                tokens.append(item.token)
        else:
            print("ERROR: Logprobs or content is missing")
            tokens = [" ", " ", " ", " ", " "]
            linear_probs = [.2, .2, .2, .2, .2]
        print("Tokens:", tokens)
        print("Probs:", linear_probs)

        while len(linear_probs) < self.n_actions:
            print("ERROR: less than 5 probs...")
            linear_probs.append(0.0)
        while len(tokens) < self.n_actions:
            print("ERROR: less than 5 tokens...")
            tokens.append(" ")

        self.sim_gen_tokens += 1
        self.num_gen_tokens += 1
        return linear_probs, tokens
    
    def get_best_terminal_state(self,state,depth):
        print("Getting terminal state (rollout). Temp: ", self.temp)
        print("Current prompt:")
        print(state)
        API_RESPONSE, response_time = get_completion(
            [
                      {"role": "system", "content": "You are a code completion model. You generate Verilog code that has correct syntax and functionality.\
            You must first analyze the provided information about a Verilog module and its incomplete Verilog module code (top_module()). \
            In your response, you must generate the rest of the tokens that correctly completes the code sequence from the end of the prompt. \
            This token sequence should be able to be directly be appended to the end of the Verilog in the prompt string without syntax issues. \
            (i.e. Make sure the tokens contain prepended spaces or newlines if needed).\
            Do not generate any formatting tokens, such as ```verilog or ```."},
                {"role": "user", "content": state}
            ],
            model="gpt-4o",
            max_tokens=2048,
            temperature=self.temp
        )

        usage = API_RESPONSE.usage
        prompt_tokens = usage.prompt_tokens
        completion_tokens = usage.completion_tokens
        total_tokens = usage.total_tokens

        response_text = API_RESPONSE.choices[0].message.content
        depth = depth + completion_tokens
        response_text_trimmed = self.extract_verilog_code(response_text)
        state = state + response_text_trimmed
        self.is_done_state(state, depth)
        print("Rollout trimmed response: ", response_text_trimmed)
        print("Depth of rollout: ", depth)
        self.sim_gen_tokens += completion_tokens
        self.num_gen_tokens += completion_tokens

        return state
    
    def get_montecarlo_return(self,state,depth):
        best_terminal_state = self.get_best_terminal_state(state,depth)
        #filteredGen = self.trim_with_stopwords(best_terminal_state)
        score = self.getPromptScore()
        return score

    def get_return(self,state,depth):
        ##Sanity Check##
        print("Getting return based on tokens - no rollout needed!")
        if not self.is_done_state(state,depth):
            print("Serious error")
            exit(1)
        score = self.getPromptScore()
        return score

    