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
import json

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
class LLMQueryEnv(gym.Env, StaticEnv):
    
    def __init__(self, csv_logger=None, task_name = None, row_data=None, op = "mcts", orig_prompt="def hello_world():", orig_module="hello_world", file_path = "", tb_path = "", dump_path = "",
                 model_name=None, tokenizer=None, model=None):
        self.op = op
        seed_everything(self.op)

        self.csv_logger = csv_logger
        self.row_data = row_data
        self.task_name = task_name
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

    def remove_prompt(self, output, prompt):
        # Check if the output starts with the prompt
        if output.startswith(prompt):
            # Remove the prompt from the beginning of the output
            print("Prompt in the output. Removing now:")
            return output[len(prompt):].strip()
        else:
            # If the prompt is not at the beginning, return the output as is
            print("Prompt not in output.")
            return output

    def trim_with_stopwords(self, currentState):
        for w in sorted(self.stopwords, key=len, reverse=True):
            if currentState.endswith(w):
                currentState = currentState[:-len(w)], w
                # print('Trimmed', repr(currentState))
                return currentState


    def isPromptComplete(self,currentState,depth):
        #print("Checking isPrompComplete...")
        #start_time = datetime.now()
        with torch.no_grad():
            torchState = torch.from_numpy(currentState).to(device)
            decoded = self.tokenizer.decode(currentState[0], skip_special_tokens=True)    
        #print('Decoded state: ',repr(decoded))
        for w in sorted(self.stopwords, key=len, reverse=True):
            if decoded.endswith(w):
                self.verilogFunctionalityCheck(currentState)
                if self.compilable:     #if compilable, finish prompt generation.
                    #print("Complete, compilable.")
                    return True
                #elif b'Unknown module type' in self.compilation_output:    #if unknown module, continue generation.
                #    return False
                else:   #if compilation error is of origin other than "undefined module", finish generation.
                    #print("Complete, not compilable.")
                    return True

                #return True
            else:
                #print("Not complete, compilable.")
                return False
            
    def verilogFunctionalityCheck(self, currentState):
        verilog_code = self.get_prompt_from_state(currentState)
        name = "mcts_vgen16b_2/"+self.orig_module + "_output.jsonl"
        with open(name, 'w') as output_file:
        # Iterate through the tasks and retrieve the associated prompt          
            # Write the output to the JSONL file
            verilog_code = self.remove_prompt(verilog_code, self.orig_prompt)
            output_data = {"task_id": self.orig_module, "completion": verilog_code}
            self.row_data['verilog'] = verilog_code
            output_file.write(json.dumps(output_data) + '\n')
        

            # Define the command as a list of arguments
        command = [
            'python', '/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/verilog-eval/verilog_eval/evaluate_functional_correctness.py', 
            name, '--problem_file', self.tb_path
        ]

        try:
            # Run the command and capture the output
            result = subprocess.run(
                command,
                capture_output=True,  # Captures both stdout and stderr
                text=True  # Ensures the output is returned as a string
            )

            # Combine stdout and stderr

        except Exception as e:
            print("Exception in process.")
        
        results_path = name + "_results.jsonl"

        # Open the file and read line by line
        with open(results_path, 'r') as file:
            for line in file:
                # Parse the JSON line
                data = json.loads(line)
                
                # Check if the 'passed' variable is true
                if data.get('passed'):
                    self.compilable = True
                    self.functional = True
                    print(f"Task {data['task_id']} passed.")
                    return 1
                else:
                    self.compilable = False
                    self.functional = False
                    print(f"Task {data['task_id']} did not pass.")
                    return -1

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
        
        self.row_data['area'] = 'N/A'
        self.row_data['delay'] = 'N/A'
        self.row_data['score'] = 1
        return  1
        


    def next_state(self,state,action):
        #token_id = self.top_token_ids[action]
        nextState = np.append(state,np.array([[action]]),axis=-1)
        return nextState

    def is_done_state(self,state,depth):
        #Check if generation is done.
        #If prompt is complete, return true (ends with endmodule).
        #Else, check if depth has exceeded. Check functionality and return true if so.
        #If depth has not been exceeded, return false.
        if self.isPromptComplete(state,depth):
            return True
        if depth>=self.depth:
            self.verilogFunctionalityCheck(state)
            print("Depth Exceeded: ", depth)
            return True
        else:
            return False

    def get_prompt_from_state(self,state):
        with torch.no_grad():
            torchState = torch.from_numpy(state).to(device)
            prompt_from_state = self.tokenizer.decode(torchState[0], skip_special_tokens=True)
            return prompt_from_state

    def getLLMestimates(self,state):
        #Retrieve the top 5 next token probabilities and IDs.
        
        with torch.no_grad():
            torchState = torch.from_numpy(state).to(device)
            output = self.model(input_ids=torchState)
            next_token_logits = output.logits[0, -1, :]
            next_token_probs = torch.softmax(next_token_logits, dim=-1)
            sorted_probs, sorted_ids = torch.sort(next_token_probs, dim=-1, descending=True)

            sorted_ids_arr = sorted_ids[:].detach().cpu().numpy()
            sorted_probs_arr = sorted_probs[:].detach().cpu().numpy()
            #CHANGED THIS TO BE NO COMMENTS! CAN CHANGE BACK BY UNCOMMENTING!
            non_comment_mask = np.array([not self.is_comment(token_id) for token_id in sorted_ids_arr])
            non_comment_all_ids = sorted_ids_arr[non_comment_mask]
            non_comment_ids = non_comment_all_ids[:self.n_actions]
            non_comment_probs = sorted_probs_arr[non_comment_mask][:self.n_actions]
            decoded_tokens = [self.tokenizer.decode([prob], skip_special_tokens=True) for prob in non_comment_all_ids]
            
            return non_comment_probs, non_comment_ids



    def is_comment(self, token_id):
        # Implement a function to check if the token is a comment
        decoded_token = self.tokenizer.decode([token_id], skip_special_tokens=True)
        return '//' in decoded_token or '/*' in decoded_token or '*/' in decoded_token
    
    def get_best_terminal_state(self,state,depth):
        start_time = datetime.now()
        #cumul_token_time = 0
        self.non_compilable_attempts = 0
        with torch.no_grad():
            torchState = torch.from_numpy(state).to(device)
            start_time = datetime.now()
            decoded = ""
            num_tokens = 0
            while not self.is_done_state(state,depth):
                output = self.model(input_ids=torchState)

                next_token_logits = output.logits[0, -1, :]
                next_token_prob = torch.softmax(next_token_logits, dim=-1)

                sorted_probs, sorted_ids = torch.sort(next_token_prob, dim=-1, descending=True)
                selected_token = sorted_ids[0].unsqueeze(0).unsqueeze(0)
                chosen_id = selected_token
                chosen_index = 0
                print_ids = sorted_ids[:5].cpu().numpy().tolist()
                decode_ids = [self.tokenizer.decode([token_id], skip_special_tokens=True) for token_id in print_ids]
                if(self.op == "mcts"):
                    while (self.is_comment(chosen_id.item()) and chosen_index < sorted_ids.size(-1)):
                        chosen_index += 1
                        chosen_id = sorted_ids[chosen_index].unsqueeze(0).unsqueeze(0)
                
                selected_token = chosen_id
                print_probs = sorted_probs[:5].cpu().numpy().tolist()
                print_probs =  [round(value, 2) for value in print_probs]
                torchState = torch.cat([torchState, selected_token], dim=-1)
                state = torchState.detach().cpu().numpy()
                decoded = self.tokenizer.decode(state[0], skip_special_tokens=True)    
                depth+=1
                num_tokens = torchState.size(1)
            #print("Tokens: ", i)
            print("Terminal state: ", decoded)
            #end_time = datetime.now()
            #time_difference = end_time - start_time
            print("Tokens in final state (with rollout): ", num_tokens)
            #seconds = time_difference.total_seconds()
            #print("LLM generates return in: ", seconds, " seconds")
            return state

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

    