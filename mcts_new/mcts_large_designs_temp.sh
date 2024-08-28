#!/bin/bash
#SBATCH --job-name=mcts_large_llama             # Job name
#SBATCH -o mcts_large_llama2.out          # output file name    
#SBATCH -e mcts_large_llama2.err          # error file name
#SBATCH --mail-type=ALL                  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=matthewdelorenzo@tamu.edu  # Where to send mail
#SBATCH --nodes=1                        # Use one node
#SBATCH --ntasks=1                       # Run a single task
#SBATCH --cpus-per-task=8                # Number of CPU cores per task
#SBATCH --gres=gpu:a100:1               # Type and number of GPUs 
#SBATCH --partition=gpu-research                  # Partition/Queue to run in
#SBATCH --qos=olympus-research-gpu       # Set QOS to use
#SBATCH --time=24:00:00                  # Time limit hrs:min:sec - set to 1 hour

# Define the common parameters
DUMPDIR="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/llama_dump2"
RUNID=0
SIM=100
EP=1
OP="mcts"

# Create an array of different values for --prompt_path, --tb_path, and --csv
PROMPT_PATHS=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/adder/prompt1_adder_64.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/adder/prompt1_adder_32.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mult/multiplier_64.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mult/multiplier_32.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mac/mac_64.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mac/mac_32.v"
    # Add more paths here...
)

TB_PATHS=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/adder/tb_adder_64.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/adder/tb_adder_32.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mult/tb_multiplier_64.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mult/tb_multiplier_32.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mac/tb_mac_64.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/mac/tb_mac_32.v"
    # Add more paths here...
)

MODULE_NAMES=(
    "adder_64"
    "adder_32"
    "multiplier_64"
    "multiplier_32"
    "mac_64"
    "mac_32"
)
CSV_FILES=(
    "llama_large_results2/adder64.csv"
    "llama_large_results2/adder32.csv"
    "llama_large_results2/multiplier_64.csv"
    "llama_large_results2/multiplier_32.csv"
    "llama_large_results2/mac_64.csv"
    "llama_large_results2/mac_32.csv"
    
#"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/prompt_tb_files/adder/prompt1_adder_64.v"
    # Add more filenames here...
)

# Loop through the arrays and execute the commands
for i in "${!PROMPT_PATHS[@]}"; do
    python main.py \
        --dumpdir "$DUMPDIR" \
        --runID "$RUNID" \
        --sim "$SIM" \
        --ep "$EP" \
        --prompt_path "${PROMPT_PATHS[i]}" \
        --tb_path "${TB_PATHS[i]}" \
        --module_name "${MODULE_NAMES[i]}" \
        --op "$OP" \
        --csv "${CSV_FILES[i]}" \
        > "llama_large_results2/new16_output_${i}.txt"  # Redirect output to individual text files
done
