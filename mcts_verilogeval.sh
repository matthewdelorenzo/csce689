DUMPDIR="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/dump/"
RUNID=0
SIM=300
EP=1
MODULE_NAME="top_module"
OP="mcts"

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