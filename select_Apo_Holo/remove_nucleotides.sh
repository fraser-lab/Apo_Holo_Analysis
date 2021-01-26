#!/bin/bash

file=/wynton/group/fraser/swankowicz/PDB_ID_2A_res.txt #list of PDBs
while read -r line; do
   line=$(echo ${line} | tr '[:upper:]' '[:lower:]')
   echo $line
   mid=$(echo ${line:1:2})
   if [ ! -f /wynton/group/fraser/swankowicz/mtz/191114/pdb${line}.ent ]; then
             cp /netapp/database/pdb/remediated/pdb/${mid}/pdb${line}.ent.gz /wynton/group/fraser/swankowicz/mtz/191114/
             gunzip /wynton/group/fraser/swankowicz/mtz/191114/pdb${line}.ent.gz
   fi
   echo ${line} >> /wynton/group/fraser/swankowicz/nucleotide_pdb_examined.txt
   remove_nucleotides /wynton/group/fraser/swankowicz/mtz/191114/pdb${line}.ent ${line} #this is a qfit script
done < $file
