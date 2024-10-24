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

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "sk-Nk4FoBjiJLwSjR0mgsE3dhzBFcZAI1a3jZv3K8csIMT3BlbkFJbIJxQWwCHDJPhyP4wwUhdbcCqvk-geEM-1U0nez0QA"))

state = '''
        //The 7400-series integrated circuits are a series of digital chips with a few gates each. 
        //The 7420 is a chip with two 4-input NAND gates.

        // Create a module with the same functionality as the 7420 chip. It has 8 inputs and 2 outputs.

        //Hint: You need to drive two signals (p1y and p2y) with a value.

        module top_module ( 
            input p1a, p1b, p1c, p1d,
            output p1y,
            input p2a, p2b, p2c, p2d,
            output p2y );
        '''
completion = client.chat.completions.create(
  model="gpt-4o",
  messages=[
     {"role": "system", "content": "You are a professional computer hardware designer. Analyze the Verilog module instructions provided in the prompt, and determine a correct implementation. \
                In your response, directly complete the rest of the top_module code (including any spaces, tabs, and newlines) such that the response can be directly appended to the provided code. \
                   Make sure the code formatting would be correct (spaces, newlines, etc) if your response was directly added to the provided Verilog."},
                {"role": "user", "content": state}
  ],
  logprobs=True,
  top_logprobs=5
)

# print(completion.choices[0].message)
# print(completion.choices[0].logprobs.content[0].token)
# print(completion.choices[0].logprobs.content[0].logprob)
#print(completion.choices[0].logprobs.content[0].top_logprobs)
#content
for item in completion.choices[0].logprobs.content[0].top_logprobs:
   print(item.token, item.logprob)