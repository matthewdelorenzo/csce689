#source /opt/coe/synopsys/vcs/V-2023.12-1/setup.vcs.sh
source /mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/vcs_test/setup.vcs.sh
vlogan /mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/vcs_test/multiplier_64.v
vlogan /mnt/shared-scratch/Rajendran_J/matthewdelorenzo/research/mcts_new/vcs_test/tb_multiplier_64.v
vcs top
simv > vcs_test_log.log