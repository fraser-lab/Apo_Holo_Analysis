#!/bin/bash

'''
This script will align two PDBs with the same sequence on top of each other. 
Based on that alignement, it will then re-name chain IDs if needed and re-number each chain so chain A, residue 1 is referring to the same chain in each PDBs.
All will be aligned to the apo structure. 

It will then calculate the RMSD between the apo and holo structure. 
This will output a csv file of RMSD for each residue in the Base Directory which can be used to determine average RMSD or RMSD of specific parts of the protein. 
'''


#____________________________________________SOURCE REQUIREMENTS____________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 
source pymol

#________________________________________________INPUTS________________________________________________
base_dir='/location/you/would/like/folders/of/PDBs/to/exist/' #base folder (where you want to put folders/pdb files)
pdb_pairs=holo_apo_pairs.txt # this file should have holo PDBs in column 1, apo PDBs in column 2.

for i in {2..100}; do
  holo=$(cat $PDB_file | awk '{ print $1 }' |head -n $i | tail -n 1)
  apo=$(cat $PDB_file | awk '{ print $2 }' | head -n $i | tail -n 1)
  echo 'Holo:' ${holo}
  echo 'Apo:' ${apo}
  cd $base_dir
  if [ ! -f ${PDB_dir}/${holo}/${holo}_qFit.pdb ] || [ ! -f ${PDB_dir}/${apo}/${apo}_qFit.pdb ]; then
      echo 'file not found'     
      continue
  else
    pymol -c python_pymol.py -- ${PDB_dir}/${holo}/${holo}_qFit.pdb ${PDB_dir}/${apo}/${apo}_qFit.pdb
    relabel_chain.py ${PDB_dir}/${holo}/${holo}_qFit_refitted.pdb ${PDB_dir}/${apo}/${apo}_qFit.pdb ${holo} ${apo}
    congregate_chain.py ${PDB_dir}/${apo}/${apo}_qFit_modified.pdb ${apo}
    python renumber.py -1 ${PDB_dir}/${holo}/${holo}_qFit_refitted_renamed_modified_chain_renamed.pdb > ${PDB_dir}/${holo}/${holo}_qFit_renamed_renmbered.pdb
    python renumber.py -1 ${PDB_dir}/${apo}/${apo}_qFit_chain_renamed.pdb > ${PDB_dir}/${apo}/${apo}_qFit_renamed_renmbered.pdb
    
    #now that you have aligned PDBs, determine the RMSD between their alpha carbons
    alpha_carbon_rmsd.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb ${PDB_dir}/${apo}/${apo}_qFit.pdb ${holo} ${apo}
  fi
done
