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


state = '''// You are given a module named mod_a that has 2 outputs and 4 inputs, in some order. 
// You must connect the 6 ports by name to your top-level module's ports:

// Port in mod_a	Port in top_module
// output out1	out1
// output out2	out2
// input in1	a
// input in2	b
// input in3	c
// input in4	d

// You are given the following module:

module mod_a ( output out1, output out2, input in1, input in2, input in3, input in4);


module top_module ( 
    input a, 
    input b, 
    input c,
    input d,
    output out1,
    output out2
);
    mod_a
'''
state_2 = '''// Create a module that implements an AND gate.

// Hint: Verilog has separate bitwise-AND (&) and logical-AND (&&) operators, like C. 
// Since we're working with a one-bit here, it doesn't matter which we choose.

module top_module( 
    input a, 
    input b, 
    output out );
assign'''
print("getLLMestimates: prior state:")
print(state_2)
completion = client.chat.completions.create(
model="gpt-4o",
messages=[
    # {"role": "system", "content": "You are a Verilog code generator. Analyze the Verilog module instructions provided in the prompt, and determine a correct implementation. \
    #             In your response, directly complete the rest of the top_module code such that the response Verilog can be directly appended to the provided code. \
    #             Do not generate any formatting tokens, such as ```verilog."},
     {"role": "system", "content": "You are a code completion model. \
            You must first analyze the provided information about the Verilog module and the incomplete Verilog module code (top_module()) \
            In your response, you must generate only the single next token that correctly continues the code sequence from the end of the prompt. \
            This token should be able to be directly be appended to the end of the Verilog in the prompt string without syntax issues. \
            (i.e. Make sure the token contains prepended spaces or newlines if needed). \
            Do not generate any formatting tokens, such as ```verilog or ```."},
                {"role": "user", "content": state_2}
],
logprobs=True,
top_logprobs=5,
max_tokens=1,
temperature=0
)
# selected_token = ""
# if completion.choices[0].logprobs.content[0].top_logprobs[0].token == "```":
#     if completion.choices[0].logprobs.content[1].top_logprobs[0].token == "ver":
#         if completion.choices[0].logprobs.content[2].top_logprobs[0].token == "ilog":
#             print("First tokens were ```verilog")
#             selected_token = completion.choices[0].logprobs.content[3]
#         else:
#             selected_token = completion.choices[0].logprobs.content[2]
#     else:
#         selected_token = completion.choices[0].logprobs.content[1]
# else:
#     selected_token = completion.choices[0].logprobs.content[0]



# for item in completion.choices[0].logprobs.content:
#     linear_probs = []
#     tokens = []
#     for value in item.top_logprobs:
#         linear_probs.append(np.round(np.exp(value.logprob) * 100, 2))
#         tokens.append(value.token)
#     print("Tokens:", tokens)
#     print("Probs:", linear_probs)

linear_probs = []
tokens = []
for item in completion.choices[0].logprobs.content[0].top_logprobs:
    linear_probs.append(np.round(np.exp(item.logprob) * 100, 2))
    tokens.append(item.token)

print(linear_probs)
print(tokens)
# linear_probs = []
# tokens = []
# for value in selected_token.top_logprobs:
#     linear_probs.append(np.round(np.exp(value.logprob) * 100, 2))
#     tokens.append(value.token)

# print("Tokens:", tokens)
# print("Probs:", linear_probs)
    