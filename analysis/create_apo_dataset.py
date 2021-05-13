'''
Cleaning and output of final apo/apo pairset for further analysis

INPUT: apo_pairs.txt #from selection pipeline
OUTPUT: Number of apo/apo pairs, csv file with apo/apo pairs for further analysis. 

'''
import pandas as pd
import os

#_____________IMPORT REFERENCE FILES_________
os.chdir('/Users/stephaniewankowicz/Downloads/qfit_paper/')
pairs = pd.read_csv('apo_pairs.txt', sep=' ', header=None)
pairs.columns = ['PDB1', 'PDB2', 'Res1', 'Res2']
pairs.drop_duplicates(inplace=True)


pairs = pairs[pairs['PDB1'] != pairs['PDB2']] #remove pairs in which the PDBs are the same

#remove additional duplicate pairs by comparing pairs
pairs['check_string'] = pairs.apply(lambda row: ''.join(sorted([row['PDB1'], row['PDB2']])), axis=1)
pairs.drop_duplicates(subset=['check_string'], inplace=True)

print(f"Number of Apo/Apo pairs: {len(pairs.index)}")

#output csv for further analysis.
pairs.to_csv('/Users/stephaniewankowicz/Downloads/qfit_paper/apo_pairs_final.csv', index=False)
