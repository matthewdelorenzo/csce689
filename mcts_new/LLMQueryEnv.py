import numpy as np
import gym # open ai gym
import os,re,shutil,argparse
import time
import torch
import random
import subprocess
import pandas as pd
from static_env import StaticEnv
from transformers import AutoTokenizer, AutoModelForCausalLM, StoppingCriteria
from datetime import datetime

def seed_everything(operation):  
    if(operation == "beam" or operation == "random"):
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
        print("Error in --op parameter. Please state 'mcts', 'random', or 'beam' as your decision.")

if torch.cuda.is_available():
    device = torch.device("cuda")
        #print("Using GPU")
else:
    device = torch.device("cpu")
#test

    
class StoppingCriteriaSub(StoppingCriteria):
    def __init__(self, stops=None, tokenizer=None, encounters=1):
        super().__init__()
        self.stops = [torch.tensor(stop).to("cuda") for stop in stops] if stops else []
        self.encounters = encounters
        self.tokenizer = tokenizer
    def __call__(self, input_ids: torch.LongTensor, scores: torch.FloatTensor):
        last_token = input_ids[0][-1]
        second_to_last_token = input_ids[0][-2]
        if "module" == self.tokenizer.decode(last_token) and "end" == self.tokenizer.decode(second_to_last_token):
            self.encounters -= 1
            if self.encounters <= 0:
                return True
        return False
    
class StoppingCriteriaSub2(StoppingCriteria):
    def __init__(self, stops=None, tokenizer=None, encounters=1):
        super().__init__()
        self.stops = [torch.tensor(stop).to("cuda") for stop in stops] if stops else []
        self.encounters = encounters
        self.tokenizer = tokenizer
    def __call__(self, input_ids: torch.LongTensor, scores: torch.FloatTensor):
        last_token = input_ids[0][-1]
        #if last_token == 13:
        if last_token == self.tokenizer.encode("\n"):
            self.encounters -= 1
            if self.encounters <= 0:
                return True
        return False

    def __len__(self):
        # Return the length of the stops list
        return len(self.stops)


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
        self.depth=0
        self.max_tokens = 2048
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
        print("Init state length: ", self.init_state.shape[1])
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


    # def isPromptComplete_old(self,currentState):
    #     #start_time = datetime.now()
    #     with torch.no_grad():
    #         torchState = torch.from_numpy(currentState).to(device)
    #         decoded = self.tokenizer.decode(currentState[0])    
    #     #print('Decoded state: ',repr(decoded))
    #     for w in sorted(self.stopwords, key=len, reverse=True):
    #         #if it current state ends with endmodule:
    #         if decoded.endswith(w):
    #             self.verilogFunctionalityCheck(currentState)
    #             if self.compilable:     #if compilable, finish prompt generation.
    #                 return True
    #             #elif self.non_compilable_attempts >= 2:    #if continued generation of module 2+ times, finish.
    #             #    return True
    #             elif b'Unknown module type' in self.compilation_output:    #if unknown module, continue generation.
    #                 #self.non_compilable_attempts += 1
    #                 return False
    #             else:   #if compilation error is of origin other than "undefined module", finish generation.
    #                 return True

    #             #return True
    #         else:
    #             return False
            
    def isPromptComplete(self,currentState):
        print("Calling isPromptComplete: ")
        with torch.no_grad():
            torchState = torch.from_numpy(currentState).to(device)
            decoded = self.tokenizer.decode(currentState[0], skip_special_tokens=True)    
        #print("IsPromptComplete: ", decoded)
        for w in sorted(self.stopwords, key=len, reverse=True):
            #if it current state ends with endmodule:
            if decoded.endswith(w):
                print("Ends with endmodule.")
                self.verilogFunctionalityCheck(currentState)
                    #return True
                if self.compilable:     #if compilable, finish prompt generation.
                    return True
                #elif self.non_compilable_attempts >= 2:    #if continued generation of module 2+ times, finish.
                #    return True
                elif b'Unknown module type' in self.compilation_output:    #if unknown module, continue generation.
                    #self.non_compilable_attempts += 1
                    return False
                else:   #if compilation error is of origin other than "undefined module", finish generation.
                    return True
            else:
                return False
        
            
    def verilogFunctionalityCheck(self, currentState):
        print("Running functionality check.")
        verilog_code = self.get_prompt_from_state(currentState)
        # Write the Verilog code to a temporary file - filenamed after module name.
        print(verilog_code)
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
        print("LOGGING VERILOG CODE.")
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
        if self.op == "mcts":
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
        #print(new_script_path)
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
            self.row_data['error'] = "Success"
            print("Output Verilog module compiles successfully.")
            return True
        except subprocess.CalledProcessError as e:
            # Compilation failed, get error message
            compile_output = e.output
            compile_exit_code = e.returncode
            print("Verilog compilation failed, error: ", compile_exit_code)
            print("Compilation output: ", compile_output)
            self.compilation_output = compile_output
            self.row_data['error'] = self.compilation_output
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
                self.row_data['error'] = simulation_output
                return True
            else:
                print("Some testbench tests failed.")
                print("Simulation output: ", simulation_output,end='\n\n')
                self.row_data['error'] = simulation_output
                return False
        else: 
            print("Verilog testbench simulation failed.")
            print("Simulation output: ", simulation_output,end='\n\n')
            self.row_data['error'] = simulation_output
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

    def next_state_old(self,state,action):
        #token_id = self.top_token_ids[action]

        #Getting the token ID at the sorted action
        nextState = np.append(state,np.array([[action]]),axis=-1)
        return nextState
    
    def next_state(self, state, sequence):
        #nextState = np.append(state, np.array(sequence))
        print("STATE: ", state)
        print("SEQUENCE: ", sequence)
        nextState = np.concatenate((state, sequence), axis=1)
        return nextState

    def is_done_state(self,state):
        print("Checking if done:")
        print("tokens generated: ", state.shape[1] - self.init_state.shape[1])
        if self.isPromptComplete(state):
            print("MCTS tree has reached the end.")
            return True
        #elif (state.shape[1] - self.init_state.shape[1]) >= self.max_tokens:
        elif (state.shape[1]) >= self.max_tokens + self.init_state.shape[1]:
            print("MCTS tree has reached the end - with max tokens.")
            self.verilogFunctionalityCheck(state)
            return True
        else:
            return False

    def get_prompt_from_state(self,state):
        with torch.no_grad():
            torchState = torch.from_numpy(state).to(device)
            prompt_from_state = self.tokenizer.decode(torchState[0], skip_special_tokens=True)
            return prompt_from_state
    
    def getLLMestimates(self, state):
        print("Calling getLLMEstimates.")
        output_ids = []
        output_texts = []
        length = 10
        input_ids = torch.from_numpy(state).to(device)
        my_stopping_criteria1 = StoppingCriteriaSub2(stops=None, tokenizer = self.tokenizer, encounters=1)
        for i in range(length):
            with torch.no_grad():
                output_id = self.model.generate(input_ids, 
                            #max_length=state.shape[1] + length, 
                            max_length=self.max_tokens+self.init_state.shape[1],
                            temperature=0.3,
                            do_sample=True,
                            top_p=0.9,
                            #eos_token_id=self.tokenizer.encode("\n")[0]
                            stopping_criteria=[my_stopping_criteria1])
                print("ID before: ", output_id)
                output_id  = output_id[:, state.shape[1]:]
                print("ID after")
                output_text = self.tokenizer.decode(output_id[0], skip_special_tokens=True)
                index = output_text.find("endmodule")
    
                if index != -1:
                    # If "endmodule" is found, extract the substring before and including it
                    output_text = output_text[:index + len("endmodule")]
                output_texts.append(output_text)
                output_id = self.tokenizer.encode(output_text, add_special_tokens=False)
                output_id = np.array([output_id])
                output_ids.append(output_id)
                print("LLMEstimate: ", output_text)
                print("Len tokens LLMEstimate: ", len(output_id))
        return output_ids
        

    def is_comment(self, token_id):
        # Implement a function to check if the token is a comment
        decoded_token = self.tokenizer.decode([token_id])
        return '//' in decoded_token or '/*' in decoded_token or '*/' in decoded_token
    

    def get_best_terminal_state(self,state):
        #start_time = datetime.now()
        #cumul_token_time = 0
        i = 0
        tokenized_end = self.tokenizer.encode("end")
        tokenized_module = self.tokenizer.encode("module")
        custom_stop_sequence = tokenized_end + tokenized_module
        my_stopping_criteria = StoppingCriteriaSub(stops=custom_stop_sequence, tokenizer = self.tokenizer, encounters=1)
        self.non_compilable_attempts = 0
        #print("Best terminal state. Max tokens: ", self.max_tokens)
        #print("init state length = ", self.init_state.shape[1])
        #print("current state length = ", state.shape[1])
        while not self.is_done_state(state):
            if (i == 0):
                print("generating terminal state (main module)")
            else:
                print("Terminal state not complete - generating additional module: ", i, " additonal module/s.")
            with torch.no_grad():
                torchState = torch.from_numpy(state).to(device)
                if(self.op == "random"):
                    print("Setting terminal state to random.")
                    output_id = self.model.generate(torchState, 
                                                    #max_length=(self.max_tokens - (state.shape[1] - self.init_state.shape[1])),
                                                    max_length=self.max_tokens+self.init_state.shape[1],
                                                    temperature=0.3, 
                                                    top_p=0.9,
                                                    do_sample=True,
                                                    stopping_criteria=[my_stopping_criteria])
                elif(self.op == "mcts"):
                    print("Getting random terminal state.")
                    output_id = self.model.generate(torchState, 
                                                    #max_length=(self.max_tokens - (state.shape[1] - self.init_state.shape[1])),
                                                    max_length=self.max_tokens+self.init_state.shape[1],
                                                    #temperature=0.3, 
                                                    #top_p=0.9,
                                                    do_sample=False,
                                                    stopping_criteria=[my_stopping_criteria])
                    
                #output_id  = output_id[:, state.shape[1]:]
                output_text = self.tokenizer.decode(output_id[0], skip_special_tokens=True)
                #index = output_text.find("endmodule")
                print("original text: ", output_text)
                output_id_update = self.tokenizer.encode(output_text, add_special_tokens=False)
                output_id_update = np.array([output_id_update])
                #print(output_id_update)
                #print(output_id)
            
                state = output_id_update
                i += 1
                #self.is_done_state(output_id_update)
                #print("ending total length: ", output_id_update.shape[1])
                #print("theoretical max length: ", self.max_tokens + self.init_state.shape[1])
            #return output_id_update
        print("Terminal state found - returning state.")
        del my_stopping_criteria
        return state
        

    def get_montecarlo_return(self,state):
        best_terminal_state = self.get_best_terminal_state(state)
        complete_prompt = self.get_prompt_from_state(best_terminal_state)
        #filteredGen = self.trim_with_stopwords(complete_prompt)
        score = self.getPromptScore(complete_prompt)
        return score

    def get_return(self,state):
        ##Sanity Check##
        if not self.is_done_state(state):
            print("Serious error")
            exit(1)
        complete_prompt = self.get_prompt_from_state(state)
        score = self.getPromptScore(complete_prompt)
        return score