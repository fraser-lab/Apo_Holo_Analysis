#!/usr/bin/env python

import os
import sys
from sys import stdout
import Bio
from Bio.PDB import PDBParser, PPBuilder, PDBIO

def get_sequence(pdb): #,chain='A'):
    pdb_parser = PDBParser(PERMISSIVE=0)                    # The PERMISSIVE instruction allows PDBs presenting errors.
    pdb_structure = pdb_parser.get_structure(pdb,pdb)
    chain=''
    chain_list=[]
    for chains in pdb_structure.get_chains():
        #ABC = chains.get_id()
        chain_list.append(chains.get_id())
    if 'A' in chain_list:
        chain='A'
    elif 'X' in chain_list:
        chain='X'
    elif 'B' in chain_list:
        chain='B'
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
    #print(">"+pdb[-8:-4]+chain)
    #len_seq = len(str(Sequence))
    if len(str(Sequence)) > 0:
       print(str(Sequence))
    else:
       print('no sequence obtained')
    #with open(pdb[-8:-4] + '_seq.txt', 'w') as file:
    #    file.write(str(Sequence))

if __name__ == '__main__':
    argc = len(sys.argv)
    if argc < 2 or argc > 3:
        print("Usage: /home/bio/getsequence.py Filename [Chain=A]")
    else:
        if argc == 2:
            get_sequence(sys.argv[1])
        else:
            get_sequence(sys.argv[1],sys.argv[2][0])
