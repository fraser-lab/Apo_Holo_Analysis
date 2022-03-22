#!/usr/bin/env python

import os
import sys
from sys import stdout
import Bio
from Bio.PDB import PDBParser, PPBuilder, PDBIO

def get_sequence(pdb):
    pdb_parser = PDBParser(PERMISSIVE=0)
    pdb_structure = pdb_parser.get_structure(pdb,pdb)
    chain=''
    chain_list=[]
    for chains in pdb_structure.get_chains():
        chain_list.append(chains.get_id())
    sorted_chains = sorted(chain_list)
    chain = sorted_chains[0]
    pdb_chain = pdb_structure[0][chain]
    for residue in pdb_chain:
        id = residue.id
        if id[0] != ' ':
            pdb_chain.detach_child(id)
        if len(pdb_chain) == 0:
            pdb_structure[0].detach_child(pdb_chain.id)
    # Using CA-CA
    ppb=PPBuilder()
    Sequence = ""
    for pp in ppb.build_peptides(pdb_chain):
        Sequence = Sequence + pp.get_sequence()
    if len(str(Sequence)) > 0:
       print(str(Sequence))
    else:
       print('no sequence obtained')

if __name__ == '__main__':
    argc = len(sys.argv)
    if argc != 2:
        print("Usage: get_seq.py PDB.pdb")
    else:
        if argc == 2:
            get_sequence(sys.argv[1])
