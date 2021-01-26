#!/bin/bash

#________________________________________________SET PATHS________________________________________________#
source /wynton/home/fraserlab/swankowicz/phenix-installer-dev-3594-intel-linux-2.6-x86_64-centos6/phenix-dev-3594/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit3
which python

#file=/wynton/group/fraser/swankowicz/test.txt
#while read -r line; do
   line=$1
   mid=$(echo ${line:1:2} | tr '[:upper:]' '[:lower:]')
   line=$(echo ${line} | tr '[:upper:]' '[:lower:]')
   #echo $mid
   echo $line
   if [[ ! -e /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump  ]]; then
      echo 'no mtz'
      echo $line >> /wynton/group/fraser/swankowicz/nomtz_111419.txt
   else
      if [[ -e /netapp/database/pdb/remediated/pdb/${mid}/pdb${line}.ent.gz ]]; then
         #echo 'pdb found'
         find_largest_lig /netapp/database/pdb/remediated/pdb/${mid}/pdb${line}.ent.gz $line
         lig_name=$(cat ${line}_ligand_name.txt)
         #echo $lig_name
         if [ ! -z "$lig_name" ]; then
            echo 'has ligand!'
            echo $lig_name
            echo $line >> /wynton/group/fraser/swankowicz/PDB_2A_res_w_lig_111419.txt
            echo $line >> /wynton/group/fraser/swankowicz/PDB_2A_lig_name_111419.txt
            echo $lig_name >> /wynton/group/fraser/swankowicz/PDB_2A_lig_name_111419.txt
         fi
      else
         echo 'pdb not found'
         echo $line >> /wynton/group/fraser/swankowicz/no_pdb_new.txt
      fi
   fi
#done < $file
