#packages
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from rdkit import Chem
from figure_functions import *	

colors = ["#1b9e77","#d95f02", "#7570b3","#e7298a","#66a61e", "#e6ab02", "#666666"]
sns.set_palette(sns.color_palette(colors))

chem = pd.read_csv('Chemical_Descriptors_PDB.csv')

for i in range(len(chem['Smile'].index)):
	try:
		mol = Chem.MolFromSmiles(chem.loc[i,'Smile'])
		chem.loc[i,'Molecular_Size'] = mol.GetNumAtoms()
	except:
		continue

print('Median Chemical Molecular Size:')
print(np.nanmedian(chem['Molecular_Size']))

print('Median Chem Name Count:')
print(np.median(chem['ChemName'].value_counts()))

fig = plt.figure()
sns.distplot(chem['Molecular_Size'], kde=False, label='')
plt.xlabel('Molecular_Size')
plt.ylabel('Number of Ligands')
plt.title('Ligand Size Distribution')
fig.savefig('ligand_size_distribution.png')

fig = plt.figure()
chemname_counts = chem['ChemName'].value_counts()[:30]
sns.barplot(chemname_counts.index, chemname_counts.values, alpha=0.8, palette=colors)
plt.title('Top 30 Frequent Ligands in Dataset')
plt.ylabel('Number of Ooccurrences')
plt.xlabel('Ligand PDB ID')
plt.xticks(rotation=45)
plt.show()
fig.savefig('chem_name_dist.png')





