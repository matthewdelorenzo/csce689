DUMPDIR="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/dump/"
MODULE_NAME="top_module"
MODEL_NAME="shailja/fine-tuned-codegen-2B-Verilog"
CSV_FILES="/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/ver16b_vereval_mcts_test1.csv"
python -u main_og.py \
        --dumpdir "$DUMPDIR" \
        --module_name "$MODULE_NAME" \
        --model_name "$MODEL_NAME" \
        --csv "${CSV_FILES[i]}" \
        > "ver16b_vereval_mcts_test1.txt"  # Redirect output to individual text files