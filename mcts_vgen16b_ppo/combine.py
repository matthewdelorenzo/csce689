import json

def combine_jsonl_files(input_files, output_file):
    with open(output_file, 'w') as outfile:
        for file in input_files:
            with open(file, 'r') as infile:
                for line in infile:
                    outfile.write(line)

# List of input JSONL files
input_files = ['output_all_circuit7.jsonl', 'output_all_vector2.jsonl', 'output_all_fsm3.jsonl',
               "output_all_zero.jsonl", "output_all_alwaysblock1.jsonl", "output_all_ringer.jsonl",
               "output_all_m2014_q6b.jsonl", "output_all_mux2to1v.jsonl"]  # Add your file names here

# Output JSONL file
output_file = 'combined.jsonl'

# Combine the files
combine_jsonl_files(input_files, output_file)

print(f"Combined {len(input_files)} files into {output_file}")