#!/bin/bash

export ROOT_DIR=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_old
#TMP EDIT
export MODULE_DIR=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_old/llama13b_intun_mcts_2k_dump/4067565_mac_32
export SCRIPTS_DIR=${ROOT_DIR}/scripts
export SYNTH_SCRIPT=${SCRIPTS_DIR}/yosys_simple_synth.tcl

#export SC_LIB=/home/abc586/tools/orfs/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
export SC_LIB=${SCRIPTS_DIR}/NangateOpenCellLibrary_typical.lib
#export ADDER_MAP_FILE=/home/abc586/tools/orfs/OpenROAD-flow-scripts/flow/platforms/nangate45/cells_adders.v
export ABC_DRIVER_CELL=BUF_X1
export ABC_LOAD_IN_FF=3.898

#export DESIGN_NICKNAME=gcd

#DESIGN_NAME and VERILOG_FILE will be changed to current tested module in LLMQueryEnv.py.
export DESIGN_NAME=mac_32
export VERILOG_FILE=${MODULE_DIR}/4067565_mac_32.v
export OUTPUT_NAME=${MODULE_DIR}/4067565_mac_32.v
#TMP EDIT
export DUMP_DIR=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_old/llama13b_intun_mcts_2k_dump/4067565_mac_32
#export ABC_AREA=1
#export ABC_CLOCK_PERIOD_IN_PS=460

#echo "SYNTH_SCRIPT: $SYNTH_SCRIPT"
#echo "DUMP_DIR: $DUMP_DIR"

yosys -c ${SYNTH_SCRIPT} > ${DUMP_DIR}/yosys_synth.log 2>&1
