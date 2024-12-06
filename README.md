# CSCE 689 Project - LLM-based High-Quality RTL Code Generation Using MCTS (Expansion) - Evaluation of Models and Strategies

In this project, the MCTS algorithm is applied to the LLM inference procedure to more effectively complete Verilog modules.
Through this frameowork, feedback (based on code functionality and PPA metrics) is found on each MCS iteration, enabling more effective paths to be explored.
In this branch of the project, GPT-4o is utilized as the base model. 
To explore how local models can be utilized (including VeriGen and Codellama), please see other branches including master (original MCTS formualtion), and line-by-line (an updated MCTS framework).

## Get Started
First, ensure that your Python version is >=3.8.
Then, you will need to download the associated Python modules within the requirements.txt file to your environment (pip install -r requirements.txt). Venv or conda environments are recommended for additional environment organization.
To utilize this project, you will first need an example Verilog prompt (.v) file, ideally containing an English description of the module along with its instantiation. This will serve as the input prompt to the LLM.
Along with this Verilog module, a Verilog testbench must also be provided to analyze the final generated module, enabling compilability and functionality to be determined.

Some examples of these are included in the repository for ease of use.

## Run the Code
Run the main_og.py file to test the project. This will require additional hyperparameters. These are listed below:

 --dumpdir (the filepath of a directory in which intermediate files can be stored).
 --sim (the number of MCTS iterations to run - at least 100 is recommended for best results).
 --ep (set to 1).
 --runID (set to 0).
 --prompt_path (the filepath of your Verilog (.v) prompt file).
 --tb_path (the filepath of your (.v) testbench file).
 --csv (set a filepath for a new csv file to be created, containing key results).
 --op (set to "mcts").

An example command is below:

> python main_og.py --dumpdir /dump --runID 0 --sim 3 --ep 1 --prompt_path /prompt_tb_files/adders/prompt1_adder_16.v --tb_path /prompt_tb_files/adders/tb_adder_16.v --csv /results/file_name.csv --op MCTS

Please also see the bash files (.sh) if you would like to run multiple hardware design prompts with MCTS.

The output results (including comparability, functionality, area (um^2) and delay (ps) for each iteration) will be stored to the new csv file.
