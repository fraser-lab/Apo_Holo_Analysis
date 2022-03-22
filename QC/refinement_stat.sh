#!/bin/bash

base_dir = '/this/is/where/your/PDB/folders/are'
PDB_file=PDB.txt #this is a list of each PDB that completed re-refinement, qFit, post qFit refinement

while read PDB; do 
  echo ${PDB}
  
done <$PDB_file
