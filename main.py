
import time
import numpy as np
import matplotlib.pyplot as plt
from concurrent.futures import ThreadPoolExecutor,as_completed
import multiprocessing
from multiprocessing import set_start_method
from LLMQueryEnv import LLMQueryEnv
from mcts import execute_episode,test_episode,initialize_MCTS_tree
from trl import PPOTrainer, PPOConfig, AutoModelForCausalLMWithValueHead, create_reference_model
import argparse,os,re
import os.path as osp
import torch,shutil
import statistics,pickle
import csv
from mcts import MCTS
from transformers import AutoTokenizer, AutoModelForCausalLM
from torch.nn.parallel import DataParallel
from peft import PeftModel
from datetime import datetime
os.environ['TOKENIZERS_PARALLELISM'] = 'false'

class CsvLogger:
    def __init__(self, filename):
        self.filename = filename
        # Initialize the CSV file with the header
        with open(self.filename, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(["Area", "Delay", "Score", "Current Run", "Episode", "Verilog", "Error"])  # Add header row

    def log(self, data):
        # 'data' is expected to be a dictionary like:
        # {'area': 123.4, 'delay': 5.67, 'score': 8.9, 'currentRun': 10, 'episode': 1}
        with open(self.filename, 'a', newline='') as file:
            writer = csv.writer(file)
            # Make sure the order of keys matches the order of your CSV columns
            writer.writerow([data['area'], data['delay'], data['score'], data['currentRun'], data['episode'], data['verilog'], data['error']])




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
    parser.add_argument('--llm_path', type=str, required=True, default = "codellama/CodeLlama-13b-hf",
                        help = "Filepath of LLM (local or public (such as Huggingface.))")
    parser.add_argument('--peft', type=str, required=False, default = False,
                        help = "Boolean indicating if the LLM model is a peft model.")
    parser.add_argument('--llm_peft', type=str, required=False, default = False,
                        help = "filepath of llm peft model.")

    args = parser.parse_args()

    peft = args.peft
    llm_peft_filepath = args.llm_peft
    rootDumpDir = args.dumpdir
    runID = args.runID
    simulation_per_episode = args.sims
    num_episodes = args.ep
    num_processes = args.pr
    operation = args.op
    csv_name = args.csv
    csv_logger = CsvLogger(csv_name)
    row_data = {}

    prompt_filepath = args.prompt_path
    tb_filepath = args.tb_path
    module_name = args.module_name
    model_name = args.llm_path
    prompt_str = ""

    
    if not osp.exists(rootDumpDir):
        os.mkdir(rootDumpDir, mode=0o777 )
        
    
    if torch.cuda.is_available():
        device = torch.device("cuda")
        print("Using GPU")
    else:
        print("Using CPU")
        device = torch.device("cpu")

    print(prompt_filepath)
    try:
        with open(prompt_filepath, "r") as prompt_file:
            prompt_str = prompt_file.read()
            print("Prompt str: ", prompt_str)
    except:
        print("Main: Error reading prompt file.")
        exit(1)
        

    print("Loading LLM model...")
    if(peft == "True"):
        base_model = model_name
        model = AutoModelForCausalLM.from_pretrained(
        base_model,
        load_in_8bit=True,
        torch_dtype=torch.float16,
        device_map="auto",
        )
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = PeftModel.from_pretrained(model, llm_peft_filepath)
    elif(peft == "8bit"):
        print("Loading ppo model.")
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForCausalLMWithValueHead.from_pretrained(model_name)
    elif(peft == "ppo"):
        base_model = model_name
        model = AutoModelForCausalLM.from_pretrained(
            base_model,
            load_in_8bit=True,
            torch_dtype=torch.float16,
            device_map="auto",
        )
        #tokenizer = AutoTokenizer.from_pretrained("codellama/CodeLlama-13b-hf")
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        #model = PeftModel.from_pretrained(model, "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/rltf/new-code-llama13b-100/checkpoint-100/")

        #CHANGE FILEPATH BELOW!
        #model = PeftModel.from_pretrained(model, "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/rltf/aiman_llama/checkpoint-100/")
        model = PeftModel.from_pretrained(model, "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/rltf/ppo_new/save_pretrained/")
    else:
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForCausalLM.from_pretrained(model_name).to(device)
    
    print("Loaded LLM: ", model_name)
    print("Initializing MCTS tree/LLM env...")
    idx_ep = 0
    
    print("Episode not stated yet!")
    print("Simulations per episode: ", simulation_per_episode)
    #model = model.to(device)
    
    while idx_ep<num_episodes:
        print("********-- EPISODE-{}--************".format(idx_ep+1))
        start_time = datetime.now()
        if(operation == "mcts"):
            print("ORIG MODULE: ", module_name)
            print("--------MCTS-------")
            merged_tree = initialize_MCTS_tree(LLMQueryEnv(csv_logger, row_data, orig_prompt=prompt_str, op = operation, orig_module=module_name, file_path=prompt_filepath, tb_path = tb_filepath, dump_path = rootDumpDir,
                                                        model_name=model_name, tokenizer=tokenizer, model=model))
            merged_tree = execute_episode(merged_tree,simulation_per_episode)
            print("END ROBUST/MAX VALUES:")
            evalMctsRobustValue, evalMctsMaxValue = test_episode(merged_tree)
            end_time = datetime.now()
            time_difference = end_time - start_time
            seconds = time_difference.total_seconds()
            print("MCTS Total Time: ", seconds)

        elif (operation == "random"):
            start_time = datetime.now()
            env = LLMQueryEnv(csv_logger, row_data, orig_prompt=prompt_str, op = operation, orig_module=module_name, file_path=prompt_filepath, tb_path = tb_filepath, dump_path = rootDumpDir,
                                                            model_name=model_name, tokenizer=tokenizer, model=model)
            for i in range(simulation_per_episode):
                print("----RANDOM LLM OUTPUT - ITERATION: ", i, " ----")
                print("---------------")
                print("Done setting up env.")
                env.row_data['episode'] = idx_ep
                env.row_data['currentRun'] = i
                init_state = env.get_initial_state()
                finalState = env.get_best_terminal_state(init_state)
                promptGen = env.get_prompt_from_state(finalState)
                #filteredGen=env.trim_with_stopwords(promptGen)
                score = env.getPromptScore(promptGen)
                env.csv_logger.log(env.row_data)
            end_time = datetime.now()
            time_difference = end_time - start_time
            seconds = time_difference.total_seconds()
            print("MCTS total time: ")
        else:
            print("Error reading --op parameter. Please only state 'beam', 'greedy', or 'mcts' as your input.")
            exit(1)

        idx_ep+=1
    



    
