
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
os.environ['TOKENIZERS_PARALLELISM'] = 'false'


class CsvLogger:
    def __init__(self, filename):
        self.filename = filename
        with open(self.filename, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(["Area", "Delay", "Score", "Current Run", "Episode", "Verilog"])  # Add header row

    def log(self, data):
        with open(self.filename, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow([data['area'], data['delay'], data['score'], data['currentRun'], data['episode'], data['verilog']])




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
            prompt_str = prompt_file.read() + "\n"
            print("Prompt str: ", prompt_str)
    except:
        print("Main: Error reading prompt file.")
        exit(1)
        

    idx_ep = 0
    while idx_ep<num_episodes:
        print("********-- EPISODE-{}--************".format(idx_ep+1))
        start_time = datetime.now()
        if(operation == "mcts"):
            print("ORIG MODILE: ", module_name)
            print("--------MCTS-------")
            merged_tree = initialize_MCTS_tree(LLMQueryEnv(csv_logger, row_data, orig_prompt=prompt_str, op = operation, orig_module=module_name, \
                                                           file_path=prompt_filepath, tb_path = tb_filepath, dump_path = rootDumpDir, temp = 0))
            merged_tree = execute_episode(merged_tree,simulation_per_episode)
            print("END ROBUST/MAX VALUES:")
            evalMctsRobustValue, evalMctsMaxValue = test_episode(merged_tree)
            end_time = datetime.now()
            time_difference = end_time - start_time
            seconds = time_difference.total_seconds()
            print("MCTS Total Time: ", seconds)

        elif(operation == "sample"):
            env = LLMQueryEnv(csv_logger, row_data, orig_prompt=prompt_str, op = operation, orig_module=module_name, \
                                                           file_path=prompt_filepath, tb_path = tb_filepath, dump_path = rootDumpDir, temp = 1)
            start_time = datetime.now()
            for i in range(simulation_per_episode):
                print(simulation_per_episode)
                print("----GREEDY LLM OUTPUT - ITERATION: ", i, " ----")
                print("---------------")
                print("Done setting up env.")
                env.row_data['episode'] = idx_ep
                env.row_data['currentRun'] = i
                
                finalState = env.get_best_terminal_state(prompt_str, 0)
                #promptGen = env.get_prompt_from_state(finalState)
                filteredGen=env.trim_with_stopwords(finalState)
                score = env.getPromptScore()
                env.csv_logger.log(env.row_data)
            end_time = datetime.now()
            time_difference = end_time - start_time
            seconds = time_difference.total_seconds()
            print("Greedy Total Time: ", seconds)
            break

        else:
            print("Error reading --op parameter. Please only state 'beam', 'greedy', or 'mcts' as your input.")
            exit(1)

        idx_ep+=1
    



    
