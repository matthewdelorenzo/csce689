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
from mcts import MCTS
from transformers import AutoTokenizer, AutoModelForCausalLM
from torch.nn.parallel import DataParallel
from peft import PeftModel

model_name = "shailja/fine-tuned-codegen-16B-Verilog"
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
#model = AutoModelForCausalLM.from_pretrained(model_name)
# output_id_update = tokenizer.encode("//Create a 4 bit adder below.", add_special_tokens=False)
# output_id_update = np.array([output_id_update])
# print(output_id_update)
# i = 0
# with torch.no_grad():
#     torchState = torch.from_numpy(output_id_update).to("cuda")
#     output_id = model.generate(torchState, 
#                                     #max_length=(self.max_tokens - (state.shape[1] - self.init_state.shape[1])),
#                                     max_length=40,
#                                     temperature=0.3, 
#                                     top_p=0.9,
#                                     do_sample=True)
    
#     output_text = tokenizer.decode(output_id[0], skip_special_tokens=True)
#     print("original text: ", output_text)
#     output_id_update = tokenizer.encode(output_text, add_special_tokens=False)
#     output_id_update = np.array([output_id_update])
#     #print(output_id_update)
#     print(output_id)

output_token0 = tokenizer.encode("\\n", add_special_tokens=False)
output_token1 = tokenizer.encode("\n", add_special_tokens=False)
output_token2 = tokenizer.encode("\\", add_special_tokens=False)
output_token3 = tokenizer.encode("n", add_special_tokens=False)

output_token4 = tokenizer.encode("endmodule", add_special_tokens=False)
output_token5 = tokenizer.encode("end", add_special_tokens=False)
output_token6 = tokenizer.encode("module", add_special_tokens=False)



output_token7 = tokenizer.decode([59, 77], skip_special_tokens=True)
output_token8 = tokenizer.decode([198], skip_special_tokens=True)
output_token9 = tokenizer.decode([59], skip_special_tokens=True)
output_token10 = tokenizer.decode([77], skip_special_tokens=True)
output_token11 = tokenizer.decode([437, 21412], skip_special_tokens=True)
output_token12 = tokenizer.decode([437], skip_special_tokens=True)
output_token13 = tokenizer.decode([21412], skip_special_tokens=True)
print(output_token0)
print(output_token1)
print(output_token2)
print(output_token3)
print(output_token4)
print(output_token5)
print(output_token6)
print("-")
print("[59, 77]:",output_token7)
print("198:",output_token8)
print("59:", output_token9)
print("77:",output_token10)
print("437, 21412:", output_token11)
print("437:", output_token12)
print("21412:", output_token12)