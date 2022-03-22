#REFINEMENT STATS
import glob
import pandas as pd
import numpy as np
import os
import argsparse



# functions

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


 parser = argparse.ArgumentParser()
    parser.add_argument('Holo_Log_File')
    parser.add_argument('Apo_Log_File')
    parser.add_argument('Holo')
    parser.add_argument('Apo')
    parser.add_argument('Step')
    args = parser.parse_args()

#__________________________________Read in reference file_____________________
pairs = pd.read_csv('PDB_pairs.txt', sep='\t', header=None)
pairs = pairs.rename(columns={0: "Apo", 1: "Apo_Res", 2: "Holo", 3: "Holo_Res", 5:"Ligand"})
AH_key = create_AH_key(pairs)


##______________________READ IN PRE REFINE DATA_____________________________
os.chdir('/Users/stephaniewankowicz/Downloads/qfit_paper/210127_preqfit/pre_refine')
path = os.getcwd()

all_files = glob.glob(path + "/*_rvalues.csv")
li = []
for filename in all_files:
    df = pd.read_csv(filename, index_col=None)
    li.append(df)
rvalues_PDB = pd.concat(li, axis=0, ignore_index=True)


PDB = rvalues_PDB.merge(AH_key)
holo = PDB[PDB['Apo_Holo']=='Holo']
apo = PDB[PDB['Apo_Holo']=='Apo']
test = holo.merge(AH_pairs, left_on='PDB', right_on='Holo')

PDB_AH = test.merge(apo, left_on='Apo', right_on='PDB') 
PDB_AH.drop_duplicates(inplace=True)



#removing any structures with no R values
PDB_AH= PDB_AH[(PDB_AH['Rfree_x']!='NULL ') & (PDB_AH['Rfree_y']!='NULL ') & (PDB_AH['Rwork_x']!='NULL ') & (PDB_AH['Rwork_y']!='NULL ')]

#converting Rvalues to numeric
cols = ['Rwork_x', 'Rwork_y', 'Rfree_x', 'Rfree_y']
PDB_AH[cols] = PDB_AH[cols].apply(pd.to_numeric, errors='coerce', axis=1)



###____________________READ IN POST REFINE, PRE QFIT_____________________________##
os.chdir('/Users/stephaniewankowicz/Downloads/qfit_paper/210127_preqfit/')
path=os.getcwd()


all_files = glob.glob(path + "/*_rvalues.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None)
    li.append(df)

rvalues_refine = pd.concat(li, axis=0, ignore_index=True)


###____________________READ IN POST QFIT_____________________________##
os.chdir('/Users/stephaniewankowicz/Downloads/qfit_paper/210426/')
path=os.getcwd()


all_files = glob.glob(path + "/*_rvalues.csv")

li = []
for filename in all_files:
    df = pd.read_csv(filename, index_col=None)
    li.append(df)

rvalues_postqfit = pd.concat(li, axis=0, ignore_index=True)


##__________________DIFFERENCES BETWEEN STEPS_______________________________
test = rvalues_PDB.merge(rvalues_refine, on='PDB') #combine original to refined rvalues
test.columns = ['PDB', 'Rwork_PDB', 'Rfree_PDB', 'Rwork_Refine', 'Rfree_Refine']
all_rvalues = test.merge(rvalues_postqfit) #combine original/refined rvalues with post qFit rvalues
all_rvalues.columns = ['PDB', 'Rwork_PDB', 'Rfree_PDB', 'Rwork_Refine', 'Rfree_Refine', 'Rwork_qFit', 'Rfree_qFit']
all_rvalues.drop_duplicates(inplace=True)

#removing all rows without original rvalue data
all_rvalues = all_rvalues[all_rvalues['Rwork_PDB']!='NULL ']
all_rvalues = all_rvalues[all_rvalues['Rfree_PDB']!='NULL ']
all_rvalues = all_rvalues[all_rvalues['Rfree_Refine']!='None\n']
all_rvalues.dropna(inplace=True)


#forcing Rvalue columns to be numeric
cols = ['Rwork_Refine', 'Rfree_Refine', 'Rwork_qFit', 'Rfree_qFit', 'Rwork_PDB', 'Rfree_PDB']
all_rvalues[cols] = all_rvalues[cols].apply(pd.to_numeric, errors='coerce', axis=1)

#calculating the difference in rvalues between each step
all_rvalues['Rfree_PDB_Refine'] = all_rvalues['Rfree_PDB'] - all_rvalues['Rfree_Refine']
all_rvalues['Rfree_Refine_qFit'] = all_rvalues['Rfree_Refine'] - all_rvalues['Rfree_qFit']

#labeling structures that will be removed due to high rfree values
all_rvalues['Rfree_PDB_Refine_YN'] = np.where(((all_rvalues['Rfree_PDB'] - all_rvalues['Rfree_Refine']) < -0.025), 1, 0)
all_rvalues['Rfree_Refine_qFit_YN'] = np.where(((all_rvalues['Rfree_Refine'] - all_rvalues['Rfree_qFit']) < -0.025), 1, 0)

#output initial rvalues to be removed.
all_rvalues[all_rvalues['Rfree_PDB_Refine_YN']==1].to_csv('/Users/stephaniewankowicz/Downloads/qfit_paper/rvalues_toremove_PDB.csv', index=False)

print('rvalue removed for refinement:')
print(len(all_rvalues[all_rvalues['Rfree_PDB_Refine_YN']==1].index))

all_rvalues = all_rvalues[all_rvalues['Rfree_Refine']<0.9]



all_rvalues2 = all_rvalues[all_rvalues['Rfree_PDB_Refine_YN']==0] #selecting structures that passed 

#Output structures that will be removed for poor rfree values
all_rvalues2[all_rvalues2['Rfree_Refine_qFit_YN']==1].to_csv('/Users/stephaniewankowicz/Downloads/qfit_paper/rvalues_toremove_qFit.csv', index=False)
print('rvalue removed for refinement (post qFit):')
print(len(all_rvalues2[all_rvalues2['Rfree_Refine_qFit_YN']==1].index))

all_rvalues2 = all_rvalues2[all_rvalues2['Rfree_qFit']<0.4]

all_rvalues2['Difference_qFit'] = all_rvalues2['Rfree_Refine'] - all_rvalues2['Rfree_qFit']

print('Difference qFit:')
print(len(all_rvalues2[all_rvalues2['Difference_qFit']>0].index))
print(len(all_rvalues2[all_rvalues2['Difference_qFit']<0].index))
print(len(all_rvalues2[all_rvalues2['Difference_qFit']==0].index))



#________________DIFFERENCE BETWEEN APO/HOLO STRUCTURES__________
all_rvalues3 = all_rvalues2[all_rvalues2['Rfree_Refine_qFit_YN']==0]


#adding on pair information
post_qfit = all_rvalues3.merge(AH_key) #we now want to look at the apo/holo pairs rather than individual sturctures; 

post_qfit_AH = merge_rvalues(post_qfit) 
post_qfit_AH.dropna(axis=0, inplace=True)

#label structures that have Rfree difference of 5% between Apo/Holo structures
post_qfit_AH['Rfree_Apo_Holo_YN'] = np.where((post_qfit_AH['Rfree_diff_qFit'] < -0.05) | (post_qfit_AH['Rfree_diff_qFit'] > 0.05), 1, 0)

#We are removing structures that have 
print('rvalue removed for difference Apo/Holo:')
print(len(post_qfit_AH[post_qfit_AH['Rfree_Apo_Holo_YN']==1].index))

#output list of final structures that have to be removed
post_qfit_AH[post_qfit_AH['Rfree_Apo_Holo_YN']==1].to_csv('/Users/stephaniewankowicz/Downloads/qfit_paper/PDB_toremove_AH.csv', index=False)
