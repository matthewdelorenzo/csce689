#!/bin/bash
#SBATCH --job-name=test             # Job name
#SBATCH -o test.out          # output file name    
#SBATCH -e test.err          # error file name
#SBATCH --mail-type=ALL                  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=matthewdelorenzo@tamu.edu  # Where to send mail
#SBATCH --nodes=1                        # Use one node
#SBATCH --ntasks=1                       # Run a single task
#SBATCH --cpus-per-task=8                # Number of CPU cores per task
#SBATCH --gres=gpu:a100:1               # Type and number of GPUs 
#SBATCH --partition=gpu-research                  # Partition/Queue to run in
#SBATCH --qos=olympus-research-gpu       # Set QOS to use
#SBATCH --time=24:00:00                  # Time limit hrs:min:sec - set to 1 hour

python test_llama.py
done