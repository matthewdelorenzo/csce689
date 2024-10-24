
import time
import numpy as np
import matplotlib.pyplot as plt
from concurrent.futures import ThreadPoolExecutor,as_completed
import multiprocessing
from multiprocessing import set_start_method
from LLMQueryEnv_og import LLMQueryEnv
from mcts_og import execute_episode,test_episode,initialize_MCTS_tree, MCTS
from trl import PPOTrainer, PPOConfig, AutoModelForCausalLMWithValueHead, create_reference_model
import argparse,os,re
import os.path as osp
import torch,shutil
import statistics,pickle
import csv
from transformers import AutoTokenizer, AutoModelForCausalLM
from torch.nn.parallel import DataParallel
from peft import PeftModel
from datetime import datetime
from openai import OpenAI
import subprocess
os.environ['TOKENIZERS_PARALLELISM'] = 'false'

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "sk-Nk4FoBjiJLwSjR0mgsE3dhzBFcZAI1a3jZv3K8csIMT3BlbkFJbIJxQWwCHDJPhyP4wwUhdbcCqvk-geEM-1U0nez0QA"))


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


def verilogFunctionalityCheck(self, currentState):
    verilog_code = currentState
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


def get_best_terminal_state(self,state,depth):
    print("Getting terminal state (rollout).")
    print("Current prompt:")
    print(state)
    API_RESPONSE, response_time = get_completion(
        [
                {"role": "system", "content": "You are a professional computer hardware designer. Analyze the Verilog module instructions provided in the prompt, and determine a correct implementation. \
            In your response, directly complete the rest of the top_module code (including any spaces, tabs, and newlines) such that the response can be directly appended to the provided code. \
                Make sure the code formatting would be correct (spaces, newlines, etc) if your response was directly added to the provided Verilog."},
            {"role": "user", "content": state}
        ],
        model="gpt-4",
        max_tokens=2048,
        temperature = 0.3,
    )
    
    # Extract the token usage details from the main response object
    usage = API_RESPONSE.usage
    prompt_tokens = usage.prompt_tokens
    completion_tokens = usage.completion_tokens
    total_tokens = usage.total_tokens
    response_text = API_RESPONSE.choices[0].message.content
    depth = depth + completion_tokens
    # if not (state.endswith(" ")  or state.endswith("\n") ) and not (response_text.startswith(" ") or response_text.startswith("\n")):
    #     state = state + " " + response_text
    # else:
    #     state = state + response_text
    state = state + response_text
    response_complete = self.is_done_state(state, depth)
    if not response_complete:
        print("Error - LLM did not provide effective response.")
    print("Rollout raw response: ", response_text)
    print("Depth of rollout: ", depth)

    return state


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='MCTS+LLM')
    parser.add_argument('--dumpdir', type=str, required=True,default="",
                        help='DUMP directory for storing output files.')
    parser.add_argument('--op', type=str, required=True,default="",
                        help = "Please state which operation to perform: 'mcts', 'beam', or 'greedy'.")
    parser.add_argument('--runID', type=int, required=False, default=0,
                        help='Run ID')
    parser.add_argument('--sims', type=int, required=True, default=1000,
                        help='Simulations per MCTS episode')
    parser.add_argument('--ep', type=int, required=True, default=50,
                        help='#MCTS episode')
    parser.add_argument('--pr', type=int, required=False, default=1,
                        help='#processes executing MCTS')
    parser.add_argument('--csv', type=str, required=False, default = "log.csv",
                        help = "Name of csv file. (ex: log.csv)")
    parser.add_argument('--prompt_path', type=str, required=True, default = "",
                        help = "Filepath of prompt file from current directory (ex: filepath/prompt1_counter.v)")
    parser.add_argument('--tb_path', type=str, required=True, default = "",
                        help = "Filepath of testbench file from current directory (ex: filepath/prompt1_counter.v)")
    parser.add_argument('--module_name', type=str, required=False, default = "top_module",
                        help = "Name of module in prompt for which the LLM will finish creating. Ex: counter")

    args = parser.parse_args()

    dump_path = args.dumpdir
    runID = args.runID
    simulation_per_episode = args.sims
    num_episodes = args.ep
    num_processes = args.pr
    operation = args.op
    csv_name = args.csv
    row_data = {}

    prompt_filepath = args.prompt_path
    tb_filepath = args.tb_path
    module_name = args.module_name
    
    prompt_str = ""

    base_name = os.path.basename(prompt_filepath)

    # Remove the .v extension
    file_name_without_extension = os.path.splitext(base_name)[0]
    
    
    if not osp.exists(dump_path):
        os.mkdir(dump_path, mode=0o777 )
        
    
    if torch.cuda.is_available():
        device = torch.device("cuda")
        print("Using GPU")
    else:
        print("Using CPU")
        device = torch.device("cpu")
    print(prompt_filepath)
    try:
        with open(prompt_filepath, "r") as prompt_file:
            prompt_str = prompt_file.read() + "\n"
            print("Prompt str: ", prompt_str)
    except:
        print("Main: Error reading prompt file.")
        exit(1)
        

    idx_ep = 0
    while idx_ep<simulation_per_episode:
        print("********-- EPISODE-{}--************".format(idx_ep+1))
        start_time_total = datetime.now()
        if(operation == "mcts"):
            start_time = datetime.now()
            print("ORIG MODILE: ", module_name)
            output = get_best_terminal_state(prompt_str, 0)
            print("Greedy output: ", output)
            end_time = datetime.now()
            time_difference_iteration = end_time - start_time
            seconds = time_difference_iteration.total_seconds()
            print("iteration: ", seconds)
            verilogFunctionalityCheck(output)
        else:
            print("Error reading --op parameter. Please only state 'beam', 'greedy', or 'mcts' as your input.")
            exit(1)

        idx_ep+=1
    end_time_total = datetime.now()
    time_difference_iteration = (start_time_total - end_time_total).total_seconds()
    print("Total time: ", time_difference_iteration)

