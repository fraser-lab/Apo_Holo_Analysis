import sys
import iotbx.pdb
from iotbx.pdb.amino_acid_codes import one_letter_given_three_letter

#print "#  r1 a1   r2 a2     S2   S2err    label"

aa_resnames = iotbx.pdb.amino_acid_codes.one_letter_given_three_letter
file_name = sys.argv[1]
pdb_obj = iotbx.pdb.hierarchy.input(file_name=file_name)
for model in pdb_obj.hierarchy.models():
  for chain in model.chains():
    for rg in chain.residue_groups():
      resname = rg.atom_groups()[0].resname
      if resname not in aa_resnames: continue
      else: 
        a1 = "HB2"
        a2 = "CB"
        if resname in ["THR", "ILE", "VAL"]:
          a1 = "HB"
          a2 = "CB"
        if resname == "GLY":
          a1 = "HA2"
          a2 = "CA"
        one_letter = one_letter_given_three_letter[resname]
        print("%s %s %s %s 1.0000 0.0000 %s %s %s") % \
          (rg.resseq, a1, rg.resseq, a2, chain.id, one_letter, rg.resseq.strip())
