import numpy as np
import matplotlib.pyplot as plt

# Updated data
test_names = ['mux2to1v', 'm2014_q6b', 'ringer', 'alwaysblock1', 'zero', 'circuit7', 'fsm3', 'vector2']
average_times_baseline = [74.12, 7.64, 3.93, 1.91, 0.82, 15.56, 15.05, 6.07]
std_devs_baseline = [49.52/2, 2.83/2, 0.94/2, 0.07/2, 0.11/2, 3.82/2, 2.45/2, 2.86/2]

average_times_mcts = [1.59, 87.30, 8.14, 4.86, 1.44, 20.73, 154.27, 14.38]
std_devs_mcts = [1.75/2, 70.32/2, 3.78/2, 2.31/2, 0.70/2, 10.35/2, 5.02/2, 18.79/2]

# Set up the figure and axis
fig, ax = plt.subplots(figsize=(4.5, 5))

# Set the width of each bar
bar_width = 0.35

# Set the positions of the bars on the x-axis
r1 = np.arange(len(test_names))
r2 = [x + bar_width for x in r1]

# Plot the bar chart with error bars for baseline sampling
ax.bar(r1, average_times_baseline, yerr=std_devs_baseline, capsize=3, color='skyblue', edgecolor='grey', width=bar_width, label='Baseline Sampling', error_kw=dict(lw=1))

# Plot the bar chart with error bars for MCTS
ax.bar(r2, average_times_mcts, yerr=std_devs_mcts, capsize=3, color='lightgreen', edgecolor='grey', width=bar_width, label='MCTS', error_kw=dict(lw=1))

# Add labels and title
ax.set_xlabel('Prompts (Verilog Modules)')
ax.set_ylabel('Average Time (s)')
#ax.set_title('Average Inference Time (100 iterations) of Verigen16B - w/ and w/out MCTS')

# Add xticks on the middle of the group bars
ax.set_xticks([r + bar_width/2 for r in range(len(test_names))])
ax.set_xticklabels(test_names)

# Rotate x-axis labels to fit within the width of the figure
plt.xticks(rotation=45)

# Add legend
ax.legend()

# Show the plot
plt.tight_layout()
plt.show()

# Save the plot as a PDF file
plt.savefig('test_performance_bar_chart.pdf')