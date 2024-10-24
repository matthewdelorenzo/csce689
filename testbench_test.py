import subprocess, os


# def compilation_check(module_path, testbench_path=None):
#         # Compile the Verilog code using the iVerilog
#     print("Compilation check...")
#     try:
#         compile_output = subprocess.check_output(['iverilog', '-o', os.path.join('test_simulation'), testbench_path, module_path], stderr=subprocess.STDOUT)
#         compile_exit_code = 0  # Compilation successful
#         print("Output Verilog module compiles successfully.")
#         return True
#     except subprocess.CalledProcessError as e:
#         # Compilation failed, get error message
#         compile_output = e.output
#         compile_exit_code = e.returncode
#         print("Verilog compilation failed, error: ", compile_exit_code)
#         print("Compilation output: ", compile_output)
#         return False

# def functionality_check():
#     print("Functionality check...")
#     try:
#         sim_path = os.path.join('test_simulation')
#         simulation_output = subprocess.check_output(['vvp', sim_path], stderr=subprocess.STDOUT)
#         simulation_exit_code = 0
#     except subprocess.CalledProcessError as e:
#         simulation_output = e.output
#         simulation_exit_code = e.returncode

#     if simulation_exit_code == 0:
#         print("Verilog testbench simulation ran successfully.")
#         if b"all tests passed" in simulation_output or b"All tests passed" in simulation_output:
#             print("Simulation output: ", simulation_output, end='\n\n')
#             print("All testbench tests passed!")
#             return True
#         else:
#             print("Some testbench tests failed.")
#             print("Simulation output: ", simulation_output,end='\n\n')
#             return False
#     else: 
#         print("Verilog testbench simulation failed.")
#         print("Simulation output: ", simulation_output,end='\n\n')
#         return False
    

response_path = "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/ve_testbenches_human/always_if/always_if_correct.v"
testbench_path = "/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/github_mcts/MCTS/ve_testbenches_human/always_if/always_if_tb.v"


# compiled = compilation_check(response_path, testbench_path)
# if(compiled):
#     print("Compilable.")
#     functional = functionality_check()
#     if(functional):
#         print("functional")
#     else:
#         print("Not functional.")
# else:
#     print("Not compilable.")


proc = subprocess.run(["iverilog", "-o", "output_results", response_path, testbench_path],capture_output=True,text=True)
if proc.returncode != 0:
    status = "Error compiling testbench"
    print(status)
    print(proc.returncode)
    message = "The testbench failed to compile. Please fix the module. The output of iverilog is as follows:\n"+proc.stderr
    print(message)
elif proc.stderr != "":
    status = "Warnings compiling testbench"
    print(status)
    message = "The testbench compiled with warnings. Please fix the module. The output of iverilog is as follows:\n"+proc.stderr
    print(message)
else:
    proc = subprocess.run(["vvp", "output_results"],capture_output=True,text=True)
    result = proc.stdout.strip().split('\n')[-2].split()
    if result[-1] != 'passed!':
        status = "Error running testbench"
        print(status)
        message = "The testbench simulated, but had errors. Please fix the module. The output of iverilog is as follows:\n"+proc.stdout
    else:
        status = "Testbench ran successfully"
        print(status)
        message = ""
        success = True