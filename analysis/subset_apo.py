import numpy as np
import pandas as pd
import argparse
import os
import sys

def parse_args():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("holo", type=str, help="name of holo")
    p.add_argument("apo", type=str, help="name of apo")
    p.add_argument("-dist", type=str,
                   help="distance of close residues")
    p.add_argument("-qFit", type=str)
    p.add_argument("-lig", type=str)
    args = p.parse_args()
    return args

def main():
    args = parse_args()
    if not args.qFit == None:
            qFit = '_qFit'
    else:
            qFit = ''
    rmsd = None
    B_factor = None
    sasa = None
    rotamer = None
    order = None

    try:
        B_factor = pd.read_csv(args.apo + qFit + "__B_factors.csv")
    except IOError:
        pass
    try:
        sasa = pd.read_csv(args.apo + qFit + "_sasa.csv", index_col=0)
    except IOError:
        pass

    try:
        rmsf = pd.read_csv(args.apo + qFit + "_qfit_RMSF.csv")
    except IOError:
        pass

    try:
        rotamer = pd.read_csv(args.apo + qFit + "_rotamer_output.txt", sep = ':')
        split = rotamer['residue'].str.split(" ")
        for i in range(0,len(rotamer.index)-1):
            rotamer.loc[i,'chain'] = split[i][1]
            STUPID = str(rotamer.loc[i,'residue'])[3:8]
            rotamer.loc[i,'resi'] = [int(s) for s in STUPID.split() if s.isdigit()]
    except IOError:
        pass

    try:
        order = pd.read_csv(args.apo + qFit + '_methyl.out', sep=',')
    except IOError:
        pass
    close_res_holo = pd.read_csv(args.holo + "_" + args.lig + "_" + args.dist + "_closeresidue.txt", header=None)
    close_res_apo = pd.read_csv(args.apo + "_" + args.lig + "_" + args.dist + "_closeresidue.txt", header=None)
    close_res_f = [close_res_holo, close_res_apo]
    close_res = pd.concat(close_res_f)
    close_res.columns = ['chain', 'resid']
    close_res = close_res.drop_duplicates()
    if B_factor is not None:
        B_factor['AA'] = B_factor.AA.str.replace('[','')
        B_factor['AA'] = B_factor.AA.str.replace(']','')
        B_factor['Chain'] = B_factor.Chain.str.replace(']','')
        B_factor['Chain'] = B_factor.Chain.str.replace('[','')
        B_factor['resseq'] = B_factor.resseq.str.replace('[','')
        B_factor['resseq'] = B_factor.resseq.str.replace(']','')
        B_factor['Chain'] = B_factor.Chain.str.replace("\'", '')
        B_factor['resseq'] = B_factor['resseq'].astype(int)

    li_rmsd = []
    li_b = []
    li_rmsf = []
    li_r = []
    li_sasa = []
    li_rotamer = []
    li_order = []

    for i in close_res.chain.unique():
        output = close_res[close_res['chain']==i]
        residue = output.resid.unique()

        rmsf_s = rmsf[(rmsf['Chain'] == i) & (rmsf['resseq'].isin(residue))]
        li_rmsf.append(rmsf_s)
        
        if B_factor is not None:
          b_s = B_factor[(B_factor['Chain'] == i) & (B_factor['resseq'].isin(residue))]
          li_b.append(b_s)
          
        rot_s = rotamer[(rotamer['chain'] == i) & (rotamer['resi'].isin(residue))]
        li_rotamer.append(rot_s)

        sasa_s = sasa.loc[(sasa['chain'] == i) & (sasa['resnum'].isin(residue))]
        li_sasa.append(sasa_s)

        order_s = order[(order['chain'] == i) & (order['resi'].isin(residue))]
        li_order.append(order_s)

    rmsf_subset = pd.concat(li_rmsf, axis=0, ignore_index=True)
    order_subset = pd.concat(li_order, axis=0, ignore_index=True)
    if B_factor is not None:
       b_factor_subset = pd.concat(li_b, axis=0, ignore_index=True)
       b_factor_subset.to_csv(args.holo + '_' + args.dist + '_bfactor_subset.csv', index=False)
    rotamer_subset = pd.concat(li_rotamer, axis=0, ignore_index=True)
    sasa_subset = pd.concat(li_sasa, axis=0, ignore_index=True)
    rmsf_subset.to_csv(args.apo + '_' + args.dist + '_rmsf_subset.csv', index=False)
    rotamer_subset.to_csv(args.apo + '_' + args.dist + '_rotamer_subset.csv', index=False)
    sasa_subset.to_csv(args.apo + '_' + args.dist + '_sasa_subset.csv', index=False)
    order_subset.to_csv(args.apo + '_' + args.dist + '_order_param_subset.csv', index=False)
    close_res.to_csv(args.holo + '_' + args.apo + '_' + args.dist + '_closeresidues_union.csv', index=False)
main()
