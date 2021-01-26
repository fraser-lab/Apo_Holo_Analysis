#!/bin/bash

source #Phenix Env

file=test.txt
while read -r line; do
      pdb=$(echo ${line} | tr '[:upper:]' '[:lower:]')     
      phenix.cif_as_mtz /wynton/group/fraser/swankowicz/mtz/191114/r${pdb}sf.ent.gz --ignore_bad_sigmas --extend_flags --merge
      phenix.mtz.dump /wynton/group/fraser/swankowicz/mtz/191114/r${pdb}sf.mtz > ${pdb}.dump
      
      SPACE1=$(grep "^Space group number from file:" /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump | awk '{print $6,$7}')
      UNIT1=$(grep "Unit cell:" /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump | tail -n 1 | sed "s/[(),]//g" | awk '{print $3,$4,$5,$6,$7,$8}')
      RESO1=$(grep "^Resolution" /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump | head -n 1 | awk '{print $4}')
      echo $line $RESO1 $SPACE1 $UNIT1 >> /wynton/group/fraser/swankowicz/space_unit_reso.txt
done < $file
