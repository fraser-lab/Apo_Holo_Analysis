#packages
import pandas as pd
import numpy as np
import os
import seaborn as sns
import statistics
from statistics import median
import matplotlib.pyplot as plt
from figure_functions import *	

#Figure Colors
colors = ["#007BA7", "#FFAA1D"]
sns.set_palette(sns.color_palette(colors))

#reference files
os.chdir('/Users/stephaniewankowicz/Downloads/qfit/pair_docs/')
pairs = pd.read_csv('ligand_supplementary_table1_QCed_updated_200422.txt', sep=' ')
pairs.drop_duplicates(inplace=True)

AH_key = create_AH_key(pairs)

#forcing Resolution columns to be numeric
cols = ['Apo_Res', 'Holo_Res']
pairs[cols] = pairs[cols].apply(pd.to_numeric, errors='coerce', axis=1)

paired_wilcoxon(pairs['Apo_Res'], pairs['Holo_Res'])

print('Median All:')
all_res = pairs['Apo_Res'].append(pairs['Holo_Res'], ignore_index=True)
all_res = pd.to_numeric(all_res, errors='coerce').dropna()
print(all_res.describe())

print('Mann Whitney U-test Apo v. Holo:')
print(stats.mannwhitneyu(pairs['Apo_Res'], pairs['Holo_Res']))
print(f"Apo Res: {pairs['Apo_Res'].median()}")
print(f"Holo Res: {pairs['Holo_Res'].median()}")

pairs['Difference'] = pairs['Holo_Res'] - pairs['Apo_Res']

fig = plt.figure()
sns.distplot(pairs['Difference'], label='')
plt.xlabel('Resolution Difference (Holo-Apo)')
plt.legend()
plt.ylabel('Number of Pairs')
plt.title('Resolution Difference Between Pairs')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/resolution_difference_all_pairs.png')

print('Differences')
print(pairs['Difference'].median())
print(pairs['Difference'].std())

