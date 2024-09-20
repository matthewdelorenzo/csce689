import re
import numpy as np

# Initialize an empty list to store the extracted numerical values
values = []

# Read the text file
with open('ver16b_vereval_mcts2.txt', 'r') as file:
    for line in file:
        # Use regular expression to find lines with the specific format and extract the numerical value
        match = re.search(r'Iteration TIME \(sec\):\s+(\d+\.\d+)', line)
        if match:
            values.append(float(match.group(1)))

# Calculate the total number of values
total_values = len(values)
print(f'Total number of values: {total_values}')

# Function to calculate average and standard deviation for chunks of 100 values
def calculate_stats(values, chunk_size=100):
    stats = []
    for i in range(0, len(values), chunk_size):
        chunk = values[i:i + chunk_size]
        average = np.mean(chunk)
        std_deviation = np.std(chunk)
        stats.append((average, std_deviation, len(chunk)))
    return stats

# Calculate the statistics
stats = calculate_stats(values)

# Print the average, standard deviation, and total number of values for each chunk
for i, (average, std_deviation, count) in enumerate(stats):
    print(f'Chunk {i + 1}: Average = {average}, Standard Deviation = {std_deviation}, Total values = {count}')
