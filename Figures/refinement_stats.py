''''
This script will create figures to look at refinement stats (Rfree) between each step of our process: PDB structure, refinement, post-qFit refinement.
It will output graphs as well as csv files with the PDB IDs of the structure that should be removed from further analysis. 
''''
import glob
import pandas as pd
import numpy as np
import os
import seaborn as sns
import matplotlib.pyplot as plt
from figure_functions import *	
from matplotlib import cm

#Figure Colors
colors = ["#1b9e77","#d95f02", "#7570b3","#e7298a","#66a61e", "#e6ab02", "#666666"]
sns.set_palette(sns.color_palette(colors))
cmap = plt.cm.get_cmap('tab10')

pd.set_option('display.max_columns', None)

#reference files
os.chdir('/Users/stephaniewankowicz/Downloads/qfit/pair_docs/')
pairs = pd.read_csv('ligand_supplementary_table1.txt', sep=' ', header=None)
pairs = pairs.rename(columns={0: "Apo", 1: "Apo_Res", 2: "Holo", 3: "Holo_Res", 5:"Ligand"})
pairs.drop_duplicates(inplace=True)

AH_key = create_AH_key(pairs)


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


# PDB_AH['Rwork_diff'] = PDB_AH['Rwork_x'] - PDB_AH['Rwork_y']
# PDB_AH['Rfree_diff'] = PDB_AH['Rfree_x'] - PDB_AH['Rfree_y']

# fig=plt.figure()
# scatter_plot_with_linear_fit(PDB_AH['Rwork_x'], PDB_AH['Rwork_y'], slope=1, y_intercept=0)
# plt.xlabel('R Work Holo')
# plt.legend()
# plt.legend(loc = 'upper left')
# plt.ylabel('R Work Apo')
# plt.title('R Work Differences (Holo and Apo) (PDB Deposited Structures)')
# fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/PDB_rvalue_work.png')

# fig=plt.figure()
# scatter_plot_with_linear_fit(PDB_AH['Rfree_x'], PDB_AH['Rfree_y'], slope=1, y_intercept=0)
# plt.xlabel('R Free Holo')
# plt.legend()
# plt.legend(loc = 'upper left')
# plt.ylabel('R Free Apo')
# plt.title('R Free Differences (Holo and Apo) (PDB Deposited Structures)')
# fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/PDB_rfree.png')


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
test.columns = ['PDB', 'Rfree_PDB', 'Rwork_PDB', 'Rfree_Refine', 'Rwork_Refine']
all_rvalues = test.merge(rvalues_postqfit) #combine original/refined rvalues with post qFit rvalues
all_rvalues.columns = ['PDB', 'Rfree_PDB', 'Rwork_PDB', 'Rfree_Refine', 'Rwork_Refine', 'Rfree_qFit', 'Rwork_qFit']
all_rvalues.drop_duplicates(inplace=True)

#removing all rows without original rvalue data
all_rvalues = all_rvalues[all_rvalues['Rwork_PDB']!='NULL ']
all_rvalues = all_rvalues[all_rvalues['Rfree_PDB']!='NULL ']
all_rvalues = all_rvalues[all_rvalues['Rfree_Refine']!='None\n']
all_rvalues.dropna(inplace=True)


#forcing Rvalue columns to be numeric
cols = ['Rwork_Refine', 'Rfree_Refine', 'Rwork_qFit', 'Rfree_qFit', 'Rwork_PDB', 'Rfree_PDB']
all_rvalues[cols] = all_rvalues[cols].apply(pd.to_numeric, errors='coerce', axis=1)

#all_rvalues.drop_duplicates(inplace=True)

#calculating the difference in rvalues between each step
all_rvalues['Rfree_PDB_Refine'] = all_rvalues['Rfree_PDB'] - all_rvalues['Rfree_Refine']
all_rvalues['Rfree_Refine_qFit'] = all_rvalues['Rfree_Refine'] - all_rvalues['Rfree_qFit']

#labeling structures that will be removed due to high rfree values
all_rvalues['Rfree_PDB_Refine_YN'] = np.where(((all_rvalues['Rfree_PDB'] - all_rvalues['Rfree_Refine']) < -0.025), 1, 0)
all_rvalues['Rfree_Refine_qFit_YN'] = np.where(((all_rvalues['Rfree_Refine'] - all_rvalues['Rfree_qFit']) < -0.025), 1, 0)

#output initial rvalues to be removed.
all_rvalues[all_rvalues['Rfree_PDB_Refine_YN']==1].to_csv('/Users/stephaniewankowicz/Downloads/qfit/pair_docs/rvalues_toremove.csv', index=False)

print('rvalue removed for refinement:')
print(len(all_rvalues[all_rvalues['Rfree_PDB_Refine_YN']==1].index))


#________________RFREE SCATTERPLOT (qFit/Refinement)_____________
fig=plt.figure()
scatter_plot_with_linear_fit(all_rvalues['Rfree_PDB'], all_rvalues['Rfree_Refine'], slope=1, y_intercept=0, color=all_rvalues['Rfree_per_PDB_Refine_YN'])#, label=)
plt.xlabel('PDB Deposited Structure R-free')
plt.legend(loc = 'upper left')
plt.text(0.12, 0.25, 'Better PDB Structure') 
plt.text(0.24, 0.15, 'Better Post Refinement')
red_patch = mpatches.Patch(color=cmap(2), label='Remove')
blue_patch = mpatches.Patch(color=cmap(0), label='Keep')
plt.legend(handles=[red_patch, blue_patch], loc='upper left')
plt.ylabel('Post Refinement R-free')
plt.title('Rfree Differences: Deposited v. Refined Structures')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/Refine_PDB.png')


all_rvalues2 = all_rvalues[all_rvalues['Rfree_per_PDB_Refine_YN']==0] #selecting structures that passed 

#Output structures that will be removed for poor rfree values
all_rvalues2[all_rvalues2['Rfree_PDB_Refine_YN']==1].to_csv('/Users/stephaniewankowicz/Downloads/qfit/pair_docs/rvalues_toremove2.csv', index=False)
print('rvalue removed for refinement (post qFit):')
print(len(all_rvalues2[all_rvalues2['Rfree_per_Refine_qFit_YN']==1].index))


#________________RFREE SCATTERPLOT (qFit/Refinement)_____________
fig = plt.figure()
scatter_plot_with_linear_fit(all_rvalues2['Rfree_Refine'], all_rvalues2['Rfree_qFit'], slope=1, y_intercept=0, color=all_rvalues2['Rfree_per_Refine_qFit_YN'])
plt.xlabel('Post Refinement Rfree')
plt.text(0.12, 0.4, 'Better Refinement') 
plt.text(0.2, 0.15, 'Better qFit')
plt.ylabel('Post qFit Refinement Rfree')
red_patch = mpatches.Patch(color=cmap(2), label='Remove')
blue_patch = mpatches.Patch(color=cmap(0), label='Keep')
plt.legend(handles=[red_patch, blue_patch], loc='upper left')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/Refine_qFit.png')


#________________RFREE DIFFERENCE FIGURE_____________
all_rvalues2['Difference'] = all_rvalues2['Rfree_qFit'] - all_rvalues2['Rfree_Refine']

fig = plt.figure()
sns.distplot(all_rvalues2['Difference'], kde=False)
plt.text(0.02, 100, 'Better Refinement')
plt.text(-0.05, 100, 'Better qFit') 
plt.xlabel('Rfree Difference (qFit-Refinment)')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/Refine_qFit_hist.png')


#________________DIFFERENCE BETWEEN APO/HOLO STRUCTURES__________
all_rvalues3 = all_rvalues2[all_rvalues2['Rfree_per_Refine_qFit_YN']==0]


#adding on pair information
post_qfit = all_rvalues3.merge(AH_key) #we now want to look at the apo/holo pairs rather than individual sturctures; 

post_qfit_AH = merge_rvalues(post_qfit) 
post_qfit_AH.dropna(axis=0, inplace=True)

#label structures that have Rfree difference of 5% between Apo/Holo structures
post_qfit_AH['Rfree_per_Apo_Holo_YN'] = np.where((post_qfit_AH['Rfree_diff_qFit'] < -0.05) | (post_qfit_AH['Rfree_diff_qFit'] > 0.05), 1, 0)

#We are removing structures that have 
print('rvalue removed for difference Apo/Holo:')
print(len(post_qfit_AH[post_qfit_AH['Rfree_per_Apo_Holo_YN']==1].index))

#output list of final structures that have to be removed
post_qfit_AH[post_qfit_AH['Rfree_per_Apo_Holo_YN']==1].to_csv('/Users/stephaniewankowicz/Downloads/qfit_paper/PDB_toremove3.csv', index=False)


#________________DIFFERENCE BETWEEN APO/HOLO STRUCTURES FIGURE__________
fig=plt.figure()
scatter_plot_with_linear_fit(post_qfit_AH['Rfree_qFit_x'], post_qfit_AH['Rfree_qFit_y'], slope=1, y_intercept=0, label='Rfree', color=post_qfit_AH['Rfree_per_Apo_Holo_YN'])
plt.xlabel('Holo Rfree')
plt.legend(loc = 'upper left')
plt.text(0.12, 0.4, 'Better Holo') 
plt.text(0.4, 0.2, 'Better Apo')
plt.ylabel('Apo Rfree')
red_patch = mpatches.Patch(color=cmap(2), label='Remove')
blue_patch = mpatches.Patch(color=cmap(0), label='Keep')
plt.legend(handles=[red_patch, blue_patch], loc='upper left')
plt.title('R Free Differences (Holo and Apo) (qFit Structures)')
fig.savefig('/Users/stephaniewankowicz/Downloads/qfit_paper/post_qfit_AH_rfree.png')

