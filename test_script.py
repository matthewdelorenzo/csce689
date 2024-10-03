import subprocess
import os

# Define the file names
verilog_file = "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/mux2to1v.v"
testbench_file = "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/testbench_vereval/mux2to1v_tb.sv"
vcd_file = 'wave.vcd'
executable = 'simulation'

# Compile the Verilog code and the testbench
compile_command = [
    'iverilog',
    '-o', executable,
    verilog_file,
    testbench_file
]

# Run the compilation
try:
    subprocess.run(compile_command, check=True)
    print("Compilation successful.")
except subprocess.CalledProcessError as e:
    print("Compilation failed.")
    print(e)
    exit(1)

# Run the simulation
simulate_command = [
    'vvp',
    executable
]

# Run the simulation
try:
    subprocess.run(simulate_command, check=True)
    print("Simulation successful.")
except subprocess.CalledProcessError as e:
    print("Simulation failed.")
    print(e)
    exit(1)

# Check if the VCD file was created
if os.path.exists(vcd_file):
    print(f"Waveform file created: {vcd_file}")
else:
    print("No waveform file created.")