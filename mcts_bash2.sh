#!/bin/bash

# Define the common parameters
DUMPDIR="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_dump"
RUNID=0
SIM=300
EP=1
MODULE_NAME="top_module"
OP="mcts"

# Create an array of different values for --prompt_path, --tb_path, and --csv
PROMPT_PATHS=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/7420.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Andgate.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Bcdadd100.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Bcdadd4.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Count10.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Count_clock.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Dff_1.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Dualedge.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Edgedetect2.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Exams_2012_q1g.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Exams_m2014_q3.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Fsm_serialdata.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Fsm_serialdp.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Hadd.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Kmap3.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Kmap4.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Lfsr32.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Module_1.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Module_name.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Mux256to1v.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Popcount255.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Reduction.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Tb_clock.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_prompts/Tb_tff.v"
    # Add more paths here...
)

TB_PATHS=(
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/7420/7420_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Andgate/Andgate_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Bcdadd100/Bcdadd100_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Bcdadd4/Bcdadd4_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Count10/Count10_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Count_clock/Count_clock_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Dff_1/Dff_1_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Dualedge/Dualedge_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Edgedetect2/Edgedetect2_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Exams_2012_q1g/Exams_2012_q1g_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Exams_m2014_q3/Exams_m2014_q3_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Fsm_serialdata/Fsm_serialdata_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Fsm_serialdp/Fsm_serialdp_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Hadd/Hadd_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Kmap3/Kmap3_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Kmap4/Kmap4_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Lfsr32/Lfsr32_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Module_1/Module_1_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Module_name/Module_name_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Mux256to1v/Mux256to1v_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Popcount255/Popcount255_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Reduction/Reduction_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Tb_clock/Tb_clock_0_tb.v"
    "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/codellama/test_testbenches/Tb_tff/Tb_tff_0_tb.v"
    # Add more paths here...
)

CSV_FILES=(
    "16b_mcts_old_results/fbase_log_7420.csv"
    "16b_mcts_old_results/fbase_log_Andgate.csv"
    "16b_mcts_old_results/fbase_Bcdadd100.csv"
    "16b_mcts_old_results/fbase_Bcdadd4.csv"
    "16b_mcts_old_results/fbase_Count10.csv"
    "16b_mcts_old_results/fbase_Count_clock.csv"
    "16b_mcts_old_results/fbase_Dff_1.csv"
    "16b_mcts_old_results/fbase_Dualedge.csv"
    "16b_mcts_old_results/fbase_Edgedetect2.csv"
    "16b_mcts_old_results/fbase_Exams_2012_q1g.csv"
    "16b_mcts_old_results/fbase_Exams_m2014_q3.csv"
    "16b_mcts_old_results/fbase_Fsm_serialdata.csv"
    "16b_mcts_old_results/fbase_Fsm_serialdp.csv"
    "16b_mcts_old_results/fbase_Hadd.csv"
    "16b_mcts_old_results/fbase_Kmap3.csv"
    "16b_mcts_old_results/fbase_Kmap4.csv"
    "16b_mcts_old_results/fbase_Lfsr32.csv"
    "16b_mcts_old_results/fbase_Module_1.csv"
    "16b_mcts_old_results/fbase_Module_name.csv"
    "16b_mcts_old_results/fbase_Mux256to1v.csv"
    "16b_mcts_old_results/fbase_Popcount255.csv"
    "16b_mcts_old_results/fbase_Reduction.csv"
    "16b_mcts_old_results/fbase_Tb_clock.csv"
    "16b_mcts_old_results/fbase_Tb_tff.csv"
    

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
        > "16b_mcts_old_results/fix_baseline_output_${i}.txt"  # Redirect output to individual text files
done