#!/bin/bash

base_dir = '/this/is/where/your/PDB/folders/are'
PDB_file=PDB.txt #this is a list of each PDB that completed re-refinement, qFit, post qFit refinement

while read PDB; do 
  echo ${PDB}
  refinement.py ${base_dir}/${holo}/${holo} ${base_dir}/${apo}/${apo} ${holo} ${apo} 'pre_qFit'
  refinement.py ${base_dir}/${holo}/${holo} ${base_dir}/${apo}/${apo} ${holo} ${apo} 'post_qFit'
  
done <$PDB_file
