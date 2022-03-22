import sys
from pymol import cmd


prot1, prot2 = sys.argv[1], sys.argv[2]
temp = prot1.split('.pdb')[0]
holo = temp.split('/')[-1]

temp = prot2.split('.pdb')[0]
apo = temp.split('/')[-1]

cmd.load(prot1, holo)
cmd.load(prot2, apo)
cmd.cealign(holo, apo)
time.sleep(1)
cmd.save(holo + '_refitted.pdb', holo, -1)
