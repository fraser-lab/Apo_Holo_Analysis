mport pandas as pd
import logging
import sys
from collections import defaultdict
from six import iteritems
import Bio
from Bio import PDB
from Bio.PDB.DSSP import dssp_dict_from_pdb_file
from Bio.PDB.DSSP import residue_max_acc
from Bio.PDB.Polypeptide import aa1
from Bio.PDB.Polypeptide import one_to_three
log = logging.getLogger(__name__)

def get_dssp_df(pdb_file, pdb_name, dir, dssp_exec='dssp'):
    d = dssp_dict_from_pdb_file(pdb_file)
    appender = []
    for k in d[1]:
            to_append = []
            y = d[0][k]
            chain = k[0]
            residue = k[1]
            het = residue[0]
            resnum = residue[1]
            to_append.extend([chain, resnum])
            to_append.extend(y)
            appender.append(to_append)
   cols = ['chain', 'resnum',
                'aa', 'dssp_index', 'ss', 'exposure_rsa', 'phi', 'psi',
                'NH_O_1_relidx', 'NH_O_1_energy', 'O_NH_1_relidx',
                'O_NH_1_energy', 'NH_O_2_relidx', 'NH_O_2_energy',
                'O_NH_2_relidx', 'O_NH_2_energy')
    df = pd.DataFrame.from_records(appender, columns=cols)
    df['aa_three'] = df['aa'].apply(one_to_three)
    df = df[df['aa'].isin(list(aa1))]
    df['max_acc'] = df['aa_three'].map(residue_max_acc['Sander'].get)
    df[['exposure_rsa', 'max_acc']] = df[['exposure_rsa', 'max_acc']].astype(float)
    df['exposure_asa'] = df['exposure_rsa'] * df['max_acc']

    df.to_csv(pdb_name + '_sasa.csv')
    return df

if __name__ == '__main__':
     get_dssp_df(sys.argv[1], sys.argv[2], sys.argv[3])
