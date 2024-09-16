#!/bin/bash
#SBATCH --job-name=mcts_16        # Job name
#SBATCH --mail-type=ALL                  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=matthewdelorenzo@tamu.edu  # Where to send mail
#SBATCH --nodes=1                        # Use one node
#SBATCH --ntasks=1                       # Run a single task
#SBATCH --cpus-per-task=8                # Number of CPU cores per task
#SBATCH --gres=gpu:a100:1               # Type and number of GPUs 
#SBATCH --partition=gpu-research                  # Partition/Queue to run in
#SBATCH --qos=olympus-research-gpu       # Set QOS to use
#SBATCH --time=96:00:00                  # Time limit hrs:min:sec - set to 1 hour

DUMPDIR="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/dump/"
MODULE_NAME="top_module"
MODEL_NAME="shailja/fine-tuned-codegen-16B-Verilog"
CSV_FILES="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/ver16b_vereval_mcts_test2.csv"
python -u main_og.py \
        --dumpdir "$DUMPDIR" \
        --module_name "$MODULE_NAME" \
        --model_name "$MODEL_NAME" \
        --csv "${CSV_FILES[i]}" \
        > "ver16b_vereval_mcts2.txt"  # Redirect output to individual text files