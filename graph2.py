import numpy as np
import matplotlib.pyplot as plt

# Data
test_names = ['mux2to1v', 'm2014_q6b', 'Ringer', 'alwaysblock1', 'zero', 'circuit7', 'ece241_2014_q5a', 'fsm3']
log_probs_5 = [0.057032, 0.061737, 0.060273, 0.07113, 0.068191, 0.056059, 0.077363, 0.064938]
log_probs_10 = [0.066822, 0.073741, 0.058295, 0.072232, 0.053949, 0.06988, 0.063462, 0.070475]
no_log_probs = [0.112151, 0.067282, 0.063102, 0.055949, 0.066779, 0.064987, 0.05863, 0.063859]

# Set up the figure and axis
fig, ax = plt.subplots(figsize=(4.5, 4))

# Set the width of each bar
bar_width = 0.25

# Set the positions of the bars on the x-axis
r1 = np.arange(len(test_names))
r2 = [x + bar_width for x in r1]
r3 = [x + bar_width for x in r2]

# Plot the bar chart
ax.bar(r1, log_probs_5, color='skyblue', edgecolor='grey', width=bar_width, label='5 log-probs')
ax.bar(r2, log_probs_10, color='lightgreen', edgecolor='grey', width=bar_width, label='10 log-probs')
ax.bar(r3, no_log_probs, color='salmon', edgecolor='grey', width=bar_width, label='No log-probs')

# Add labels and title
ax.set_xlabel('Prompts (Verilog Modules)')
ax.set_ylabel('Per token exec. time (s/token)')
#ax.set_title('Comparison of Log-Prob Values for Different Tests')

# Add xticks on the middle of the group bars
ax.set_xticks([r + bar_width for r in range(len(test_names))])
ax.set_xticklabels(test_names)
plt.xticks(rotation=60)

# Add legend
ax.legend()

# Show the plot
plt.tight_layout()
plt.show()

# Save the plot as a PDF file
plt.savefig('log_prob_comparison_bar_char_f.pdf')