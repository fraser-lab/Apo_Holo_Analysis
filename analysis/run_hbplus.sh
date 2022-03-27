#!/bin/bash
#$ -l h_vmem=4G
#$ -l mem_free=4G
#$ -t 1-1
#$ -l h_rt=10:00:00
#$ -R yes
#$ -V

#source /programs/sbgrid.shrc
#sbgrid-cli install hbplus
source phenix

PDB_file=AH_pairs.txt

for i in {2..1268}; do
  PDB=$(cat $PDB_file | awk '{ print $1 }' |head -n $i | tail -n 1)


  cd ${PDB} #go into folder where the multiconformer structure is

  #split multiconformer PDB
  python split_multiconf.py --pdb ${PDB}_qFit.pdb --pdb_name ${PDB}
  
  #run hbplus
  #hbplus ${PDB}_qFit_altA.pdb -h 3.2
  #hbplus ${PDB}_qFit_altB.pdb -h 3.2
  #hbplus ${PDB}_qFit_altC.pdb -h 3.2
  #hbplus $PDB}_qFit_altD.pdb -h 3.2
  #hbplus ${PDB}_qFit_altE.pdb -h 3.2
  
  #subset to a subset of residues (see example of close residues in folder). 
  python hbplus_subset.py ${PDB}_5.0_closeresidues.csv
done

