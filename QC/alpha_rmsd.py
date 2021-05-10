'''
This script will take in RMSD information between the apo/holo structures and look at basic descriptions/outliers and plot their distribution. 
'''

#packages
import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt
import glob
from itertools import product
from figure_functions import *	

#read in pair information 
os.chdir('/Users/stephaniewankowicz/Downloads/qfit/pair_docs/')
pairs = pd.read_csv('ligand_supplementary_table1_QCed_updated_200422.txt', sep=' ', header=None)
pairs = pairs.rename(columns={0: "Apo", 1: "Apo_Res", 2: "Holo", 3: "Holo_Res", 5:"Ligand"})
pairs.drop_duplicates(inplace=True)

ah_key = create_AH_key(pairs) #this function creates a table of annotating each PDB with apo or holo. 


os.chdir('/Users/stephaniewankowicz/Downloads/qfit_paper/210426/') #directory where your files are located
path = os.getcwd()

#________READ IN BINDING SITE RMSD_______________-
all_files = glob.glob(path + "/*_rmsd_CA_subset.csv")
li = []
for filename in all_files:
    df = pd.read_csv(filename, index_col=0, sep=',')
    df['Holo'] = filename[54:58]
    df['Apo'] = filename[59:63]
    li.append(df)
rmsd_subset = pd.concat(li, axis=0, ignore_index=True)

#subset down to pairs we want to examine
rmsd_subset = rmsd_subset[rmsd_subset['Holo'].isin(pairs['Holo'])]
rmsd_subset = rmsd_subset[rmsd_subset['Apo'].isin(pairs['Apo'])]


#____________________CREATE BINDING SITE SUMMARY__________________________
summary = [] #holds tuples 
for i, j in set(product(rmsd_subset['Holo'], rmsd_subset['Apo'])): #for each unique combindation of apo/holo
    tmp = rmsd_subset[(rmsd_subset['Holo']==i) & (rmsd_subset['Apo']==j)]
    summary.append(tuple((i, j, tmp['RMSD'].mean())))

rmsd_summary = pd.DataFrame(summary, columns =['Holo', 'Apo', 'average_rmsd']) 
rmsd_summary.dropna(inplace=True)

#describe the average rmsd
print((rmsd_summary['average_rmsd'].describe()))

#output csv for further inspection
rmsd_summary.to_csv('rmsd_binding_site_summary.csv')

#__________________CREATE FIGURE BINDING SITE__________________
fig = plt.figure()
sns.distplot(rmsd_summary['average_rmsd'], kde=False)
plt.xlabel('Average Binding Site Alpha Carbon RMSD')
plt.legend()
plt.ylabel('Number of Pairs')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/alpha_carbon_rmsd_bindingsite.png')


#_________READ IN FULL PROTEIN RMSD_________________
all_files = glob.glob(path + "/*_rmsd.csv")
li = []
for filename in all_files:
    df = pd.read_csv(filename, sep=',', index_col=0)
    df['Holo'] = filename[54:58]
    df['Apo'] = filename[59:63]
    li.append(df)
rmsd_all = pd.concat(li, axis=0, ignore_index=True)

#subset down to pairs we want to examine
rmsd_all = rmsd_all[rmsd_all['Holo'].isin(pairs['Holo'])]
rmsd_all = rmsd_all[rmsd_all['Apo'].isin(pairs['Apo'])]


#_______________CREATE SUMMARY DATAFRAME_______________
summary = [] #holds tuples 
for i, j in set(product(rmsd_all['Holo'], rmsd_all['Apo'])): #for each unique combindation of apo/holo
    tmp = rmsd_subset[(rmsd_all['Holo']==i) & (rmsd_all['Apo']==j)] #subset dataframe
    summary.append(tuple((i, j, tmp['RMSD'].mean())))

rmsd_all_summary = pd.DataFrame(summary, columns =['Holo', 'Apo', 'average_rmsd']) 
rmsd_all_summary.dropna(inplace=True)


print((rmsd_sum['average_rmsd'].describe())) #describe RMSD distribution

#output csv for further inspection
rmsd_sum.to_csv('/Users/stephaniewankowicz/Downloads/qfit_paper/rsmd_all_summary.csv')


#__________________CREATE FIGURE BINDING SITE__________________
fig = plt.figure()
sns.distplot(rmsd_sum['average_rmsd'], kde=False)
plt.xlabel('Average Alpha Carbon RMSD [Entire Protein]')
plt.legend()
plt.ylabel('Number of Pairs')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/alpha_carbon_rmsd_entireprotein.png')

