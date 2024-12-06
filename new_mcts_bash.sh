#!/bin/bash
#SBATCH --job-name=sample_fix             # Job name
#SBATCH -o sample_fix.out          # output file name    
#SBATCH -e sample_fix.err          # error file name
#SBATCH --mail-type=ALL                  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=matthewdelorenzo@tamu.edu  # Where to send mail
#SBATCH --nodes=1                        # Use one node
#SBATCH --ntasks=1                       # Run a single task
#SBATCH --cpus-per-task=1                # Number of CPU cores per task
#SBATCH --partition=cpu-research                  # Partition/Queue to run in
#SBATCH --qos=olympus-cpu-research       # Set QOS to use
#SBATCH --time=24:00:00               # Time limit hrs:min:sec - set to 1 hour

# Define the common parameters

#Change
DUMPDIR="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/dump"
RUNID=0
SIM=100
EP=1
MODULE_NAME="top_module"
OP="mcts" #can also be "sample" for basic temp sampling

# Create an array of different values for --prompt_path, --tb_path, and --csv

#change to your system
PROMPT_PATHS=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/prompt_tb_files/adders/prompt1_adder_16.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/prompt_tb_files/mac/mac_16.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/prompt_tb_files/mult/multiplier_16.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/7420.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Andgate.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Bcdadd100.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Bcdadd4.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Count10.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Count_clock.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Dff_1.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Dualedge.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Edgedetect2.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Exams_2012_q1g.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Exams_m2014_q3.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Fsm_serialdata.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Fsm_serialdp.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Hadd.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Kmap3.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Kmap4.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Lfsr32.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Module_1.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Module_name.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Mux256to1v.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Popcount255.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Reduction.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Tb_clock.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_prompts/Tb_tff.v"
    # # Add more paths here...
)

#change these to your system
TB_PATHS=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/prompt_tb_files/adders/tb_adder_16.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/prompt_tb_files/mac/tb_mac_16.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/prompt_tb_files/mult/tb_multiplier_16.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/7420/7420_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Andgate/Andgate_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Bcdadd100/Bcdadd100_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Bcdadd4/Bcdadd4_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Count10/Count10_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Count_clock/Count_clock_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Dff_1/Dff_1_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Dualedge/Dualedge_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Edgedetect2/Edgedetect2_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Exams_2012_q1g/Exams_2012_q1g_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Exams_m2014_q3/Exams_m2014_q3_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Fsm_serialdata/Fsm_serialdata_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Fsm_serialdp/Fsm_serialdp_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Hadd/Hadd_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Kmap3/Kmap3_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Kmap4/Kmap4_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Lfsr32/Lfsr32_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Module_1/Module_1_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Module_name/Module_name_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Mux256to1v/Mux256to1v_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Popcount255/Popcount255_0_tb.v"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Reduction/Reduction_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Tb_clock/Tb_clock_0_tb.v"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/test_testbenches/Tb_tff/Tb_tff_0_tb.v"
    # # Add more paths here...
)

#change to wherever you want to be saved
CSV_FILES=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_adder16_demo.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_mac16_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_mult16_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_7420_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Andgate_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Bcdadd100_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Bcdadd4_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Count10_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Count_clock_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Dff_1_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Dualedge_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Edgedetect2_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Exams_2012_q1g_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Exams_m2014_q3_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Fsm_serialdata_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Fsm_serialdp_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Hadd_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Kmap3_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Kmap4_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Lfsr32_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Module_1_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Module_name_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Mux256to1v_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Popcount255_05_fix.csv"
    # "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/gpt4o_test3_sample_fix/new16_Reduction_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Tb_clock_05_fix.csv"
    # #"/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/new16_Tb_tff_05_fix.csv"
    

    # Add more filenames here...
)


# Loop through the arrays and execute the commands
for i in "${!PROMPT_PATHS[@]}"; do
    python main_og.py \
        --dumpdir "$DUMPDIR" \
        --runID "$RUNID" \
        --sim "$SIM" \
        --ep "$EP" \
        --prompt_path "${PROMPT_PATHS[i]}" \
        --tb_path "${TB_PATHS[i]}" \
        --module_name "$MODULE_NAME" \
        --op "$OP" \
        --csv "${CSV_FILES[i]}" \
        > "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/results/demo_adder.txt"  # Redirect output to individual text files
done

#alter .txt filepath if needed