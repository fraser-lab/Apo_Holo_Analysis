#!/bin/bash

base_dir = '/this/is/where/your/PDB/folders/are'
pdb_pairs=holo_apo_pairs.txt # this file should have holo PDBs in column 1, apo PDBs in column 2.

for i in {2..100}; do
  holo=$(cat $PDB_file | awk '{ print $1 }' |head -n $i | tail -n 1)
  apo=$(cat $PDB_file | awk '{ print $2 }' | head -n $i | tail -n 1)
  echo 'Holo:' ${holo}
  echo 'Apo:' ${apo}
  cd $base_dir
  
  refinement_log_parser.py ${base_dir}/${holo}/${holo}_updated.pdb_refine_001.log ${base_dir}/${apo}/${apo}_updated.pdb_refine_001.log ${holo} ${apo} 'pre_qFit'
  refinement_log_parser.py ${base_dir}/${holo}/${holo}_qFit.log ${base_dir}/${apo}/${apo} ${holo} ${apo}_qFit.log 'post_qFit'

done <$PDB_file

python refinement_stats.py ${base_dir}
