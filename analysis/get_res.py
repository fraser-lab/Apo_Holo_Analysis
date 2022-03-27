import pandas as pd
import os
import datetime
import argparse
import sys

def parse_log(log_file, pdb):
    Wilson = pd.DataFrame()
    Wilson.loc[1,'PDB'] = pdb
    log=open(log_file, 'r')
    for line in log:
        if line.startswith('REMARK   3   FROM WILSON PLOT'):
              wilson_value = line.split(':')[1][1:5]
              Wilson.loc[1,'Wilson_b_factor'] = line.split(':')[1][1:5]
        if line.startswith('REMARK   3   MEAN B VALUE'):
              Wilson.loc[1,'Mean_b_factor'] = line.split(':')[1][1:5]
        if line.startswith('REMARK   2 RESOLUTION.'):
              res = line[26:30]
              Wilson.loc[1,'Resolution'] = line[26:30]
        if line.startswith('REMARK   3   RESOLUTION RANGE HIGH (ANGSTROMS)'):
              res = (line.split(':')[1][1:6])
              Wilson.loc[1,'Resolution'] = line.split(':')[1][1:6]
    Wilson.to_csv('PDB_info_' + pdb + '.csv')
    return(res)
    
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('PDB')
    parser.add_argument('pdb_name')
    args = parser.parse_args()
    res = parse_log(args.PDB, args.pdb_name)
    print(res)
