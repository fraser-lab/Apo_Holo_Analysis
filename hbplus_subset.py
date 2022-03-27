#packages
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import glob
import sys

all_files = glob.glob("*.hb2")
li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None,  skiprows=7, sep='\s+')
    df['PDB'] = filename[0:4]
    df['alt'] = filename[13:14]
    li.append(df)
hbplus = pd.concat(li, axis=0, ignore_index=True)

pdb = hbplus['PDB'].unique()[0]


resi1 = hbplus['n'].str.split("-", expand = True)
hbplus['resn1'] = resi1[1]
hbplus['chain1'] = resi1[0].astype(str).str[0]
hbplus['resi1'] = resi1[0].astype(str).str[1:].str.lstrip('0')
hbplus['resi1'] = pd.to_numeric(hbplus['resi1'])

resi2 = hbplus['type'].str.split("-", expand = True)
hbplus['resn2'] = resi2[1]
hbplus['chain2'] = resi2[0].astype(str).str[0]
hbplus['resi2'] = resi2[0].astype(str).str[1:].str.lstrip('0')
hbplus['resi2'] = pd.to_numeric(hbplus['resi2'])

#output water interactions
hbplus_wat = hbplus[hbplus['dist'].isin(['HS', 'SH', 'MH', 'HM', 'HH'])]
hbplus_wat_sub = hbplus_wat[['resn1', 'chain1', 'resi1', 'resn2', 'chain2', 'resi2', 'PDB', 'alt', 'typ']]
hbplus_wat_sub = hbplus_wat_sub[(hbplus_wat_sub['resn1']=='HOH') | (hbplus_wat_sub['resn2']=='HOH')]
hbplus_wat_sub.drop_duplicates(inplace=True)

#subset to non-hetero atoms
hbplus_pro = hbplus[hbplus['dist'].isin(['MS', 'SM', 'SS'])]
hbplus_pro_sub = hbplus_pro[['resn1', 'chain1', 'resi1', 'resn2', 'chain2', 'resi2', 'PDB', 'alt', 'typ']]
hbplus_pro_sub.drop_duplicates(inplace=True)


#read in close residues
close = pd.read_csv(sys.argv[1], sep=',')

h_a = sys.argv[1][51:60]

li_hb = []
for i in close.chain.unique():
        output = close[close['chain']==i]
        residue = output['resid']
        hbplus_s = hbplus_pro_sub[(hbplus_pro_sub['chain1'] == i) & (hbplus_pro_sub['resi1'].isin(output['resid']))]
        li_hb.append(hbplus_s)

        hbplus_s = hbplus_pro_sub[(hbplus_pro_sub['chain2'] == i) & (hbplus_pro_sub['resi2'].isin(output['resid']))]
        li_hb.append(hbplus_s)

hb_close_subset = pd.concat(li_hb, axis=0, ignore_index=True)

hb_close_subset.to_csv(pdb + '_hb_close_subset.csv', index=False)
hbplus_pro_sub.to_csv(pdb + '_hb_protein.csv', index=False)
hbplus_wat_sub.to_csv(pdb + '_hb_water.csv', index=False)
