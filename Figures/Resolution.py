#packages
import pandas as pd
import numpy as np
import os
import statistics
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.pyplot as plt
from figure_functions import *	

#reference files
pairs = pd.read_csv('ligand_supplementary_table1_QCed.txt', sep=' ', header=None) #Paired Dataset
pairs = pairs.rename(columns={0: "Apo", 1: "Apo_Res", 2: "Holo", 3: "Holo_Res", 5:"Ligand"})

AH_key = create_AH_key(AH_pairs) #Create Key to Identify PDB IDs as Apo or Holo

#SUBSET DOWN TO PAIRS
pair_subset = pd.read_csv('merged_order_5.csv')
AH_pairs = AH_pairs.loc[(AH_pairs['Apo'].isin(pair_subset['Apo'])) & (AH_pairs['Holo'].isin(pair_subset['Holo']))]

make_dist_plot_AH(AH_pairs['Holo_Res'], AH_pairs['Apo_Res'], 'Resolution', 'Number of Structures', 'Resolution', 'FullResolution')

print('Difference of s2calc on only Polar Side Chains between Holo/Apo [Entire Protein]')
paired_ttest(AH_pairs['Apo_Res'], AH_pairs['Holo_Res'])

print('Median All:')
all_res = AH_pairs['Apo_Res'].tolist() + AH_pairs['Holo_Res'].tolist()
print(statistics.median(all_res))

fig = plt.figure()
AH_pairs['Difference'] = AH_pairs['Holo_Res'] - AH_pairs['Apo_Res']
sns.kdeplot(AH_pairs['Difference'], label='Resolution Difference (Holo-Apo)', bw=0.02)
fig.savefig('resolution_difference.png')
