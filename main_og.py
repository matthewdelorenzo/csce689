
import time
import numpy as np
import matplotlib.pyplot as plt
from concurrent.futures import ThreadPoolExecutor,as_completed
import multiprocessing
from multiprocessing import set_start_method
from LLMQueryEnv_og import LLMQueryEnv
from mcts_og import execute_episode,test_episode,initialize_MCTS_tree
from trl import PPOTrainer, PPOConfig, AutoModelForCausalLMWithValueHead, create_reference_model
import argparse,os,re
import os.path as osp
import torch,shutil
import statistics,pickle
import csv
from mcts_og import MCTS
from transformers import AutoTokenizer, AutoModelForCausalLM
from torch.nn.parallel import DataParallel
from peft import PeftModel
from datetime import datetime
import json

os.environ['TOKENIZERS_PARALLELISM'] = 'false'

class CsvLogger:
    def __init__(self, filename):
        self.filename = filename
        # Initialize the CSV file with the header
        with open(self.filename, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(["Area", "Delay", "Score", "Current Run", "Episode", "Verilog"])  # Add header row

    def log(self, data):
        # 'data' is expected to be a dictionary like:
        # {'area': 123.4, 'delay': 5.67, 'score': 8.9, 'currentRun': 10, 'episode': 1}
        with open(self.filename, 'a', newline='') as file:
            writer = csv.writer(file)
            # Make sure the order of keys matches the order of your CSV columns
            writer.writerow([data['area'], data['delay'], data['score'], data['currentRun'], data['episode'], data['verilog']])




if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='MCTS+LLM')
    parser.add_argument('--dumpdir', type=str, required=True,default="dump",
                        help='DUMP directory for storing output files.')
    parser.add_argument('--model_name', type=str, required=True, default = "shailja/fine-tuned-codegen-16B-Verilog",
                    help = "Name of model (Huggingface filepath or local filepath) user for inferencing. (EX: shailja/fine-tuned-codegen-16B-Verilog)")
    parser.add_argument('--csv', type=str, required=True, default = "log.csv",
                    help = "Name of csv file to be created. (ex: log.csv)")

    parser.add_argument('--ep', type=int, required=False, default=1,
                    help='#Episodes of MCTS (how many times to run all <x> simulations.) Recommended: 1')
    parser.add_argument('--sims', type=int, required=False, default=100,
                    help='Iterations of MCTS to occur.')
    parser.add_argument('--op', type=str, required=False,default="mcts",
                    help = "Please state which operation to perform: 'mcts', 'beam', or 'greedy'.")
    parser.add_argument('--pr', type=int, required=False, default=1,
                        help='#processes executing MCTS. Default: 1')
    parser.add_argument('--module_name', type=str, required=False, default = "top_module",
                        help = "Name of the top module in your verilog prompt. Ex: counter")
    parser.add_argument('--task_name', type=str, required=False, default = "top_module",
                        help = "Name of file (or Verilog problem) in prompt for which the LLM will finish creating. Ex: counter")
    parser.add_argument('--runID', type=int, required=False, default=0,
                    help='Run ID')
    parser.add_argument('--prompt_path', type=str, required=False, default = "",
                        help = "Filepath of prompt file from current directory (ex: filepath/prompt1_counter.v)")
    parser.add_argument('--tb_path', type=str, required=False, default = "",
                        help = "Filepath of testbench file from current directory (ex: filepath/prompt1_counter.v)")

    args = parser.parse_args()

    def read_all_lines(file_path):
        with open(file_path, 'r') as file:
            lines = file.readlines()
        return lines
    
    description_strings = read_all_lines("/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/verilog-eval/VerilogDescription_Human.jsonl")
    prompt_strings = read_all_lines("/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/verilog-eval/VerilogEval_Human.jsonl")
    description_strings = {json.loads(line)['task_id']: json.loads(line) for line in description_strings}
    prompt_strings = {json.loads(line)['task_id']: json.loads(line) for line in prompt_strings}

    rootDumpDir = args.dumpdir
    runID = args.runID
    simulation_per_episode = args.sims
    num_episodes = args.ep
    num_processes = args.pr
    operation = args.op
    model_name = args.model_name
    csv_name = args.csv
    module_name = args.module_name
    task_name = args.task_name
    csv_logger = CsvLogger(csv_name)
    row_data = {}

    
    if not osp.exists(rootDumpDir):
        os.mkdir(rootDumpDir, mode=0o777)
        
    
    if torch.cuda.is_available():
        device = torch.device("cuda")
        print("Using GPU")
    else:
        print("Using CPU")
        device = torch.device("cpu")

        
    print("Loading LLM model...")

    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        #load_in_8bit=True,
        #torch_dtype=torch.float16,
        device_map="auto",
    )

    tokenizer = AutoTokenizer.from_pretrained(model_name)

    print("Loaded LLM: ", model_name)
    print("Initializing MCTS tree/LLM env...")
    idx_ep = 0
    
    print("Episode not stated yet!")
    print("Simulations per episode: ", simulation_per_episode)
    model = model.to(device)
    
    while idx_ep<num_episodes:
        print("********-- EPISODE-{}--************".format(idx_ep+1))
        start_time = datetime.now()
        if(operation == "mcts"):
            for index, (task_id, description) in enumerate(description_strings.items()):
                print("ORIG MODILE: ", task_id)
                print("--------MCTS-------")
                task_name = str(prompt_strings[task_id]['task_id']).strip()
                if task_id in prompt_strings:
                    description_comp = str(description['detail_description']).strip()
                    module_comp = str(prompt_strings[task_id]['prompt']).strip()
                    testbench = str(prompt_strings[task_id]['test']).strip()
                    print("Verilog prompt #: ", index, ": ", task_id)
                else:
                    print(f"Task ID {task_id} not found in prompts file")
                    continue

                full_prompt = description_comp + "\n" + module_comp
                prompt_filepath = f"prompts_vereval/{task_id}.v"
                testbench_filepath = f"testbench_vereval/{task_id}_tb.v"
                with open(prompt_filepath, 'w') as verilog_file:
                    verilog_file.write(full_prompt)

                # Write the testbench string to a Verilog file named <task_id>_tb.v
                with open(testbench_filepath, 'w') as testbench_file:
                    testbench_file.write(testbench)
            
                merged_tree = initialize_MCTS_tree(LLMQueryEnv(csv_logger, row_data, orig_prompt=full_prompt, op = operation, orig_module=module_name, task_name = task_name, file_path=prompt_filepath, tb_path = testbench_filepath, dump_path = rootDumpDir,
                                                            model_name=model_name, tokenizer=tokenizer, model=model))
                merged_tree = execute_episode(merged_tree,simulation_per_episode)

            print("END ROBUST/MAX VALUES:")
            evalMctsRobustValue, evalMctsMaxValue = test_episode(merged_tree)
            end_time = datetime.now()
            time_difference = end_time - start_time
            seconds = time_difference.total_seconds()
            print("MCTS Total Time: ", seconds)

        # elif (operation == "beam"):
        #     env = LLMQueryEnv(csv_logger, row_data, orig_prompt=prompt_str, op = operation, orig_module=module_name, file_path=prompt_filepath, tb_path = tb_filepath, dump_path = rootDumpDir,
        #                 model_name=model_name, tokenizer=tokenizer, model=model)
        #     start_time = datetime.now()
        #     for i in range(simulation_per_episode):
        #         print("----BEAM LLM OUTPUT - ITERATION: ", i, " ----")
        #         env.row_data['episode'] = idx_ep
        #         env.row_data['currentRun'] = i
        #         init_state = env.get_initial_state()
        #         output = env.beam_search(init_state)
        #         print("Output---")
        #         print(output)
        #         score = env.getPromptScore()
        #         env.csv_logger.log(env.row_data)
        #     end_time = datetime.now()
        #     time_difference = end_time - start_time
        #     seconds = time_difference.total_seconds()
        #     print("Beam Total Time: ", seconds)

        # elif (operation == "greedy"):
        #     env = LLMQueryEnv(csv_logger, row_data, orig_prompt=prompt_str, op = operation, orig_module=module_name, file_path=prompt_filepath, tb_path = tb_filepath, dump_path = rootDumpDir,
        #                                                     model_name=model_name, tokenizer=tokenizer, model=model)
        #     for i in range(simulation_per_episode):
        #         print("----GREEDY LLM OUTPUT - ITERATION: ", i, " ----")
        #         print("---------------")
        #         print("Done setting up env.")
        #         env.row_data['episode'] = idx_ep
        #         env.row_data['currentRun'] = i
        #         init_state = env.get_initial_state()
        #         finalState = env.get_best_terminal_state(init_state,0)
        #         promptGen = env.get_prompt_from_state(finalState)
        #         filteredGen=env.trim_with_stopwords(promptGen)
        #         score = env.getPromptScore(filteredGen)
        #         env.csv_logger.log(env.row_data)
        #     break
        else:
            print("Error reading --op parameter. Please only state 'beam', 'greedy', or 'mcts' as your input.")
            exit(1)

        idx_ep+=1
    



    
