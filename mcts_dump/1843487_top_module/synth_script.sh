#!/bin/bash

export ROOT_DIR=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS
#TMP EDIT
export MODULE_DIR=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/mcts_dump//1843487_top_module
export SCRIPTS_DIR=${ROOT_DIR}/scripts
export SYNTH_SCRIPT=${SCRIPTS_DIR}/yosys_simple_synth.tcl

#export SC_LIB=/home/abc586/tools/orfs/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
export SC_LIB=${SCRIPTS_DIR}/NangateOpenCellLibrary_typical.lib
#export ADDER_MAP_FILE=/home/abc586/tools/orfs/OpenROAD-flow-scripts/flow/platforms/nangate45/cells_adders.v
export ABC_DRIVER_CELL=BUF_X1
export ABC_LOAD_IN_FF=3.898

#export DESIGN_NICKNAME=gcd

#DESIGN_NAME and VERILOG_FILE will be changed to current tested module in LLMQueryEnv.py.
export DESIGN_NAME=top_module
export VERILOG_FILE=${MODULE_DIR}/1843487_top_module.v
export OUTPUT_NAME=${MODULE_DIR}/1843487_top_module.v
#TMP EDIT
export DUMP_DIR=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/mcts_dump//1843487_top_module
#export ABC_AREA=1
#export ABC_CLOCK_PERIOD_IN_PS=460

#echo "SYNTH_SCRIPT: $SYNTH_SCRIPT"
#echo "DUMP_DIR: $DUMP_DIR"

yosys -c ${SYNTH_SCRIPT} > ${DUMP_DIR}/yosys_synth.log 2>&1
