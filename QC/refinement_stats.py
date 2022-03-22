#REFINEMENT STATS
import glob
import pandas as pd
import numpy as np
import os
import argsparse

def create_AH_key(AH_pairs):
    AH_key1 = AH_pairs[['Apo']]
    AH_key2 = AH_pairs[['Holo']]
    AH_key2.columns = ['PDB']
    AH_key1.columns = ['PDB']
    AH_key1['Apo_Holo'] = 'Apo'
    AH_key2['Apo_Holo'] = 'Holo'
    AH_key = pd.concat([AH_key1, AH_key2])
    return AH_key

def merge_rvalues(df):
    '''
    This function is used to merge the rvalues to correspond to the apo/holo pairs.
    '''
    holo = df[df['Apo_Holo']=='Holo']
    apo = df[df['Apo_Holo']=='Apo']
    test = holo.merge(AH_pairs, left_on='PDB', right_on='Holo')

    rvalue_AH = test.merge(apo, left_on='Apo', right_on='PDB') 
    rvalue_AH.drop_duplicates(inplace=True)
    rvalue_AH['Rwork_diff_qFit'] = rvalue_AH['Rwork_qFit_x']-rvalue_AH['Rwork_qFit_y']
    
    rvalue_AH['Rfree_diff_qFit'] = rvalue_AH['Rfree_qFit_x']-rvalue_AH['Rfree_qFit_y']
    return rvalue_AH

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('base_dir')
    parser.add_argument('PDB_file')
    args = parser.parse_args()
    return args
    

def read_file(base_dir, step):
     all_files = glob.glob(base_dir + '/*' + step + '.csv')
     li = []
     for filename in all_files:
         df = pd.read_csv(filename, index_col=None)
         li.append(df)
     rvalues = pd.concat(li, axis=0, ignore_index=True)
     cols = ['Rwork_x', 'Rwork_y', 'Rfree_x', 'Rfree_y']
     rvalues[cols] = rvalues[cols].apply(pd.to_numeric, errors='coerce', axis=1)
     return rvalues
     
def merge_AH(df):
    PDB = df.merge(AH_key)
    holo = PDB[PDB['Apo_Holo']=='Holo']
    apo = PDB[PDB['Apo_Holo']=='Apo']
    tmp = holo.merge(AH_pairs, left_on='PDB', right_on='Holo')
    PDB_AH = test.merge(apo, left_on='Apo', right_on='PDB')
    PDB_AH.drop_duplicates(inplace=True)
    return PDB_AH
    

#_____________________________Read in arguments______________________________
args = parse_args()

#__________________________________Read in reference file_____________________
pairs = pd.read_csv(args.PDB_file, sep='\t', header=None)
pairs = pairs.rename(columns={0: "Apo", 1: "Apo_Res", 2: "Holo", 3: "Holo_Res", 5:"Ligand"})
AH_key = create_AH_key(pairs)

#____________________________Read in refine values_____________
pre_qFit = read_file(args.base_dir, 'pre_qFit')
post_qFit = read_file(args.base_dir, 'post_qFit')

##__________________DETERMINE DIFFERENCES BETWEEN STEPS_______________________________
pre_post = pre_qFit.merge(post_qFit, on='PDB')
pre_post.columns = ['PDB', 'Rwork_pre', 'Rfree_pre', 'Rwork_post', 'Rfree_post']

#calculating the difference in rvalues between each step
pre_post['Rfree_pre_post'] = pre_post['Rfree_pre'] - pre_post['Rfree_post']

#labeling structures that will be removed due to high rfree values
pre_post['Rfree_PDB_Refine_YN'] = np.where(((pre_post['Rfree_PDB'] - pre_post['Rfree_Refine']) < -0.025), 1, 0)

#output initial rvalues to be removed.
pre_post[pre_post['Rfree_pre_post_YN']==1].to_csv('PDB_rvalues_toremove.csv', index=False)
pre_post_clean = pre_post[pre_post['Rfree_pre_post_YN'] == 0]

print('rvalue removed for refinement:')
print(len(pre_post[pre_post['Rfree_pre_post_YN']==1].index))

#________________DIFFERENCE BETWEEN APO/HOLO STRUCTURES__________
#adding on pair information
pre_post_AH = merge_AH(pre_post_clean)

#label structures that have Rfree difference of 5% between Apo/Holo structures
pre_post_AH['Rfree_AH_diff'] = pre_post_AH['Rfree_post_x'] - pre_post_AH['Rfree_post_y'] 

pre_post_AH['Rfree_Apo_Holo_YN'] = np.where((pre_post_AH['Rfree_AH_diff'] < -0.05) | (pre_post_AH['Rfree_AH_diff'] > 0.05), 1, 0)

#We are removing structures that have 
print('rvalue removed for difference Apo/Holo:')
print(len(pre_post_AH[pre_post_AH['Rfree_Apo_Holo_YN']==1].index))

#output list of final structures that have to be removed
pre_post_AH[pre_post_AH['Rfree_Apo_Holo_YN']==1].to_csv('PDB_toremove_rvalues_AH.csv', index=False)
