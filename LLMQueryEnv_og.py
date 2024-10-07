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
import OpenAI

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "sk-GOoOKLyunGa2vKV2eRy8YjdKuJ8d_5HNdIahN0qLwMT3BlbkFJtryKaavon-rI0XFIU-IWr5S9zCF6AXKgFv-NfP0P4A"))

def seed_everything(operation):  
    if(operation == "beam" or operation == "greedy"):
        seed = random.randint(1, 1000000)     
        random.seed(seed)                                                     
        torch.manual_seed(seed)
        np.random.seed(seed)
        print("Env seed: ", seed)
        os.environ['PYTHONHASHSEED'] = str(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed(seed)                                                   
            torch.cuda.manual_seed_all(seed)                                             
            torch.backends.cudnn.deterministic = False
            torch.backends.cudnn.benchmark = False
    elif(operation == "mcts"):
        seed = 42                                          
        random.seed(seed)                                                     
        torch.manual_seed(seed)
        np.random.seed(seed)
        print("Env seed: ", seed)
        os.environ['PYTHONHASHSEED'] = str(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed(seed)                                                   
            torch.cuda.manual_seed_all(seed)                                             
            torch.backends.cudnn.deterministic = True
            torch.backends.cudnn.benchmark = False
    else:
        print("Error in --op parameter. Please state 'mcts', 'greedy', or 'beam' as your decision.")

if torch.cuda.is_available():
    device = torch.device("cuda")
        #print("Using GPU")
else:
    device = torch.device("cpu")
#test


def get_completion(
    messages: list[dict[str, str]],
    model: str = "gpt-4",
    max_tokens=2048,
    temperature=0,
    stop=None,
    seed=123,
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
        "seed": seed,
        "logprobs": logprobs,
        "top_logprobs": top_logprobs,
    }
    if tools:
        params["tools"] = tools

    start_time = time.time()
    completion = client.chat.completions.create(**params)
    end_time = time.time()
    
    response_time = end_time - start_time
    print(f"API response time: {response_time:.6f} seconds")
    
    return completion, response_time


class LLMQueryEnv(gym.Env, StaticEnv):
    
    def __init__(self, csv_logger=None, row_data=None, op = "mcts", orig_prompt="def hello_world():", orig_module="hello_world", file_path = "", tb_path = "", dump_path = "",
                 model_name=None, tokenizer=None, model=None):
        self.op = op
        seed_everything(self.op)

        self.csv_logger = csv_logger
        self.row_data = row_data
        model_name = model_name
        self.tokenizer = tokenizer
        self.model = model
        self.orig_prompt = orig_prompt
        self.init_state = self.get_tokenized_state(self.orig_prompt)
        self.num_tokens=0
        self.n_actions = 10 #self.tokenizer.vocab_size
        self.stopwords = ['endmodule']
        #Limit to token generation before cutoff.
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
        #self.top_token_ids = None
            #self.ep_length = NUM_LENGTH_EPISODES # not required

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
        for w in sorted(self.stopwords, key=len, reverse=True):
            if currentState.endswith(w):
                currentState = currentState[:-len(w)], w
                # print('Trimmed', repr(currentState))
                return currentState


    def isPromptComplete(self,currentState,depth):
        #start_time = datetime.now()
        with torch.no_grad():
            torchState = torch.from_numpy(currentState).to(device)
            decoded = self.tokenizer.decode(currentState[0], skip_special_tokens=True)    
        #print('Decoded state: ',repr(decoded))
        for w in sorted(self.stopwords, key=len, reverse=True):
            if decoded.endswith(w):
                self.verilogFunctionalityCheck(currentState)
                if self.compilable:     #if compilable, finish prompt generation.
                    return True
                else:  
                    return True
            else:
                return False
            
    def verilogFunctionalityCheck(self, currentState):
        verilog_code = currentState
        #print(verilog_code)
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

    def getPromptScore(self, currentState=""):
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
        
        #TMP EDIT
        #Specify your bash script to be utilized here.
        bash_script = "scripts/synth_gcd.sh"

        module_dump_folder = self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module
        #print("Dump folder: ", module_dump_folder)

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
            start_time = datetime.now()
            subprocess.run(['bash', '-c', f'chmod +x {new_script_path} && {new_script_path}'], check=True)
            end_time = datetime.now()
            time_difference = end_time - start_time
            seconds = time_difference.total_seconds()
            print("Running bash in x seconds: ", seconds)
        except subprocess.CalledProcessError as e:
            print(f"Error running bash script: {e}")

        #Retrieving the results from generated log file - specify your filepath.
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
        try:
            #print("Path: ", os.path.join(self.dumppath + "/" + str(os.getpid()) + "_" + self.orig_module, str(os.getpid()) + '_simulation'))
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

    def next_state(self,state,action):
        #token_id = self.top_token_ids[action]
        nextState = np.append(state,np.array([[action]]),axis=-1)
        return nextState

    def is_done_state(self,state,depth):
        if self.isPromptComplete(state,depth):
            return True
        if depth>=self.depth:
            self.verilogFunctionalityCheck(state)
            return True
        else:
            return False

    def get_prompt_from_state(self,state):
        with torch.no_grad():
            torchState = torch.from_numpy(state).to(device)
            prompt_from_state = self.tokenizer.decode(torchState[0], skip_special_tokens=True)
            return prompt_from_state

    def getLLMestimates(self,state):
            #sorted_ids_trim = sorted_ids_arr[:self.n_actions]
            #sorted_probs_trim = sorted_probs_arr[:self.n_actions]
            
        API_RESPONSE, response_time = get_completion(
            [
                {"role": "system", "content": "You are a professional computer hardware designer. Analyze the Verilog module instructions provided in the prompt. \
                Then in your response, directly generate the rest of the Verilog code provided in the prompt (do not generate any other text)."},
                {"role": "user", "content": state}
            ],
            model="gpt-4",
            max_tokens=1,
            logprobs=True,
            top_logprobs=5,
            )

        # Extract the token usage details from the main response object
        usage = API_RESPONSE.usage
        prompt_tokens = usage.prompt_tokens
        completion_tokens = usage.completion_tokens
        total_tokens = usage.total_tokens
        response_text = API_RESPONSE.choices[0].message.content

        print("Generated token: ", response_text)
        generated_token_count = completion_tokens

        # print(f"Prompt token count: {prompt_tokens}")
        # print(f"Generated token count: {generated_token_count}")
        # print(f"Total token count: {total_tokens}")
        # per_token_time = response_time / generated_token_count if generated_token_count > 0 else float('inf')
        # per_total_token_time = response_time / total_tokens if total_tokens > 0 else float('inf')
        # print(f"Per generated token time: {per_token_time:.6f} seconds")
        # print(f"Per total token time: {per_total_token_time:.6f} seconds")
        
        linear_probs = []
        tokens = []

        logprobs = API_RESPONSE.choices[0].logprobs
        for token_index, token_logprobs in enumerate(logprobs.content):
            print("Token index: ", token_index)
            for i, logprob in enumerate(token_logprobs.top_logprobs, start=1):
                linear_probs.append(np.round(np.exp(logprob.logprob) * 100, 2))
                tokens.append(logprob.token)
                print("Output token: ", i, " Token: ", logprob.token)
                print("linear prob: ", np.round(np.exp(logprob.logprob) * 100, 2))


        return linear_probs, tokens
    

    def check_sequence_in_ids(self, ids, target_sequence):
        instances = 0
        id_list = ids[0].tolist()
        if len(id_list) < len(target_sequence):
            return False
        for i in range(len(id_list) - len(target_sequence) + 1):
            if id_list[i:i+len(target_sequence)] == target_sequence:
                instances += 1
                if(instances > self.beam_count):
                    self.beam_count += 1
                
                    print("BEAM SEARCH: ID TYPE: ", type(ids))
                    self.verilogFunctionalityCheck(ids.detach().cpu().numpy())
                    if self.compilable:     #if compilable, finish prompt generation.
                        return True
                    elif b'Unknown module type' in self.compilation_output:    #if unknown module, continue generation.
                        print("Continuing generation.")
                        return False
                    else:   #if compilation error is of origin other than "undefined module", finish generation.
                        return True
                #return True
        return False


    def is_comment(self, token_id):
        # Implement a function to check if the token is a comment
        decoded_token = self.tokenizer.decode([token_id], skip_special_tokens=True)
        return '//' in decoded_token or '/*' in decoded_token or '*/' in decoded_token
    
    def get_best_terminal_state(self,state,depth):
        API_RESPONSE, response_time = get_completion(
            [
                {"role": "system", "content": "You are a professional computer hardware designer. Analyze the Verilog module instructions provided in the prompt. \
                Then in your response, directly generate the rest of the Verilog code provided in the prompt (do not generate any other text)."},
                {"role": "user", "content": state}
            ],
            model="gpt-4",
            max_tokens=2048,
        )

        # Extract the token usage details from the main response object
        usage = API_RESPONSE.usage
        prompt_tokens = usage.prompt_tokens
        completion_tokens = usage.completion_tokens
        total_tokens = usage.total_tokens
        response_text = API_RESPONSE.choices[0].message.content

        print("Rollout raw response: ", response_text)
        # Calculate the generated token count
        generated_token_count = completion_tokens

        # Print the results
        print(f"Prompt token count: {prompt_tokens}")
        print(f"Generated token count: {generated_token_count}")
        print(f"Total token count: {total_tokens}")

        # Calculate per token time for generated tokens
        per_token_time = response_time / generated_token_count if generated_token_count > 0 else float('inf')
        per_total_token_time = response_time / total_tokens if total_tokens > 0 else float('inf')
        print(f"Per generated token time: {per_token_time:.6f} seconds")
        print(f"Per total token time: {per_total_token_time:.6f} seconds")
        return response_text

    def get_montecarlo_return(self,state,depth):
        best_terminal_state = self.get_best_terminal_state(state,depth)
        complete_prompt = self.get_prompt_from_state(best_terminal_state)
        filteredGen = self.trim_with_stopwords(complete_prompt)
        score = self.getPromptScore(filteredGen)
        return score

    def get_return(self,state,depth):
        ##Sanity Check##
        if not self.is_done_state(state,depth):
            print("Serious error")
            exit(1)
        complete_prompt = self.get_prompt_from_state(state)
        score = self.getPromptScore(state)
        return score

    