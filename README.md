# CSCE 689 Project - LLM-based High-Quality RTL Code Generation Using MCTS (Expansion) - Evaluation of Models and Strategies

In this project, the MCTS algorithm is applied to the LLM inference procedure to more effectively complete Verilog modules. Through this framework, feedback (based on analyzing the LLM generated Verilog codes for functionality and PPA metrics) is found on each MCTS iteration, enabling more effective paths to be explored. In this branch of the project, GPT-4o is utilized as the base model. To explore how local models can be utilized (including VeriGen and Codellama), please see other branches including master (original MCTS formulation), and line-by-line (an updated MCTS framework).

## Get Started

1. **Ensure Python Version**: Ensure that your Python version is >=3.8.
2. **Install Dependencies**: Download the associated Python modules within the `requirements.txt` file to your environment:
   ```bash
   pip install -r requirements.txt
   ```
   Venv or conda environments are recommended for additional environment organization.
3. **Prepare Verilog Files**: You will need an example Verilog prompt (.v) file, ideally containing an English description of the module along with its instantiation. This will serve as the input prompt to the LLM. Along with this Verilog module, a Verilog testbench must also be provided to analyze the final generated module, enabling compilability and functionality to be determined.

   Some examples of these are included in the repository for ease of use.

## Run the Code

Run the `main_og.py` file to test the project. This will require additional hyperparameters. These are listed below:

- `--dumpdir`: The filepath of a directory in which intermediate files can be stored.
- `--sim`: The number of MCTS iterations to run (at least 100 is recommended for best results).
- `--ep`: Set to 1.
- `--runID`: Set to 0.
- `--prompt_path`: The filepath of your Verilog (.v) prompt file.
- `--tb_path`: The filepath of your (.v) testbench file.
- `--csv`: Set a filepath for a new CSV file to be created, containing key results.
- `--op`: Set to "mcts".

### Example Command

```bash
python main_og.py --dumpdir /dump --runID 0 --sim 3 --ep 1 --prompt_path /prompt_tb_files/adders/prompt1_adder_16.v --tb_path /prompt_tb_files/adders/tb_adder_16.v --csv /results/file_name.csv --op MCTS
```

Please also see the bash files (.sh) if you would like to run multiple hardware design prompts with MCTS.

The output results (including comparability, functionality, area (um²), and delay (ps) for each iteration) will be stored in the new CSV file.
