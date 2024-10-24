
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

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "sk-Nk4FoBjiJLwSjR0mgsE3dhzBFcZAI1a3jZv3K8csIMT3BlbkFJbIJxQWwCHDJPhyP4wwUhdbcCqvk-geEM-1U0nez0QA"))

def get_completion(
    messages: list[dict[str, str]],
    model: str = "gpt-4",
    max_tokens=1,  # Single token at a time
    temperature=0,
    stop=None,
    seed=123,
    tools=None,
    logprobs=5,  # Set logprobs to get probabilities for top tokens
    top_logprobs=5,
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


def get_most_likely_token(state):
    """Gets the most likely next token based on the current prompt."""
    API_RESPONSE, response_time = get_completion(
        [
            {"role": "system", "content": "You are a professional computer hardware designer. Analyze the Verilog module instructions provided in the prompt, and determine a correct implementation. In your response, directly complete the rest of the top_module code (including any spaces, tabs, and newlines) such that the response can be directly appended to the provided code."},
            {"role": "user", "content": state}
        ],
        model="gpt-4",
        logprobs=True,  # Log probabilities for tokens
        max_tokens=1,   # Single token response
        top_logprobs=5,
    )
    
    # Extract token usage details
    usage = API_RESPONSE.usage
    prompt_tokens = usage.prompt_tokens
    completion_tokens = usage.completion_tokens
    total_tokens = usage.total_tokens
    response_text = API_RESPONSE.choices[0].message.content

    # Extract logprobs for the completion token
    logprobs = API_RESPONSE.choices[0].logprobs
    most_likely_token = None
    highest_prob = -np.inf  # Start with a very low probability

    # Parse the logprobs to find the most likely token
    for token, logprob in logprobs.top_logprobs[0].items():
        linear_prob = np.round(np.exp(logprob) * 100, 2)
        print(f"Token: {token}, Probability: {linear_prob}%")
        
        if logprob > highest_prob:
            highest_prob = logprob
            most_likely_token = token

    print(f"Most likely token: {most_likely_token}")
    return most_likely_token
    
def getLLMestimates(state):

    print("LLMEstimates: prior state: \n", state)
    API_RESPONSE, response_time = get_completion(
        [
                {"role": "system", "content": "You are a professional computer hardware designer. Analyze the Verilog module instructions provided in the prompt, and determine a correct implementation. \
            In your response, directly complete the rest of the top_module code (including any spaces, tabs, and newlines) such that the response can be directly appended to the provided code. \
                Make sure the code formatting would be correct (spaces, newlines, etc) if your response was directly added to the provided Verilog."},
            {"role": "user", "content": state}
        ],
        model="gpt-4",
        logprobs=True,
        max_tokens=1,
        top_logprobs=5,
        )
    
    # Extract the token usage details from the main response object
    usage = API_RESPONSE.usage
    prompt_tokens = usage.prompt_tokens
    completion_tokens = usage.completion_tokens
    total_tokens = usage.total_tokens
    response_text = API_RESPONSE.choices[0].message.content

    linear_probs = []
    tokens = []

    logprobs = API_RESPONSE.choices[0].logprobs
    for token_index, token_logprobs in enumerate(logprobs.content):
        print("Token index (should only be 1): ", token_index)
        for i, logprob in enumerate(token_logprobs.top_logprobs, start=1):
            linear_probs.append(np.round(np.exp(logprob.logprob) * 100, 2))
            print("Token:", logprob.token)
            tokens.append(logprob.token)
            print("Output token: ", i, " Token: ", logprob.token)
            print("linear prob: ", np.round(np.exp(logprob.logprob) * 100, 2))

    print("Token list: ", tokens)
    return tokens[0]

def generate_complete_code(initial_state):
    """Generate the complete code by appending tokens until the stop condition."""
    current_state = initial_state
    stop_tokens = ["endmodule"]  # Define stop conditions

    while True:
        # Get the most likely token
        most_likely_token = getLLMestimates(current_state)

        # Append the most likely token to the current state
        current_state += most_likely_token

        print("Updated prompt: ", current_state)

        # Check for stop tokens
        if any(stop_token in most_likely_token for stop_token in stop_tokens):
            print("Stop token reached.")
            break
    
    return current_state


try:
    with open("/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/7420.v", "r") as prompt_file:
        prompt_str = prompt_file.read() + "\n" + "assign"
        print("Initial prompt: ", prompt_str)
except:
    print("Main: Error reading prompt file.")
    exit(1)

# Generate the complete Verilog code
complete_code = generate_complete_code(prompt_str)
print("Generated Verilog Code: ", complete_code)