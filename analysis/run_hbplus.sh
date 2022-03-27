#!/bin/bash

#install hbplus
source phenix

PDB_dir = '/this/is/where/your/PDB/folders/are'
PDB_file=holo_apo_pairs.txt # this file should have holo PDBs in column 1, apo PDBs in column 2.


for i in {2..1268}; do
  holo=$(cat $PDB_file | awk '{ print $1 }' |head -n $i | tail -n 1)
  apo=$(cat $PDB_file | awk '{ print $2 }' | head -n $i | tail -n 1)
  echo $apo $holo
  
  #run Apo
  cd ${PDB_dir}/${apo} #go into folder where the multiconformer structure is
  #split multiconformer PDB
  python split_multiconf.py --pdb ${apo}_qFit.pdb --pdb_name ${apo}
  #hbplus ${apo}_qFit_altA.pdb -h 3.2
  #hbplus ${apo}_qFit_altB.pdb -h 3.2
  #hbplus ${apo}_qFit_altC.pdb -h 3.2
  #hbplus ${apo}_qFit_altD.pdb -h 3.2
  #hbplus ${apo}_qFit_altE.pdb -h 3.2
  
  #subset to a subset of residues (see example of close residues in folder). 
  python hbplus_subset.py ${holo}_${apo}_5.0_closeresidues.csv
  
  
  #run Holo
  cd ${PDB_dir}/${holo} #go into folder where the multiconformer structure is
  #split multiconformer PDB
  python split_multiconf.py --pdb ${holo}_qFit.pdb --pdb_name ${apo}
  
  #run hbplus
  #hbplus ${holo}_qFit_altA.pdb -h 3.2
  #hbplus ${holo}_qFit_altB.pdb -h 3.2
  #hbplus ${holo}_qFit_altC.pdb -h 3.2
  #hbplus $(holo}_qFit_altD.pdb -h 3.2
  #hbplus ${holo}_qFit_altE.pdb -h 3.2
  
  #subset to a subset of residues (see example of close residues in folder). 
  python hbplus_subset.py ${holo}_${apo}_5.0_closeresidues.csv
done

