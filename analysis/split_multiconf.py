#!/usr/bin/env python

#packages
import io
import Bio
import Bio.PDB
import argparse
from Bio.PDB import *

def parse_args():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--pdb")
    p.add_argument("--pdb_name")
    p.add_argument("--alt")
    args = p.parse_args()
    return args
args = parse_args()

class removealts(Select):
    def accept_atom(self, atom):
        return atom.get_altloc() == alt or atom.get_altloc() == ' '


parser = Bio.PDB.PDBParser()
io = PDBIO()
s = parser.get_structure(args.pdb_name, args.pdb)
io.set_structure(s)

for alt in ['A', 'B', 'C', 'D', 'E']:
    io.save(args.pdb_name + "_qFit_alt" + alt + ".pdb", select=removealts())
