#!/bin/bash
#Stephanie Wankowicz
#https://stephaniewankowicz.github.io/
#Fraser Lab UCSF

#This script takes in a list of PDB IDs, downloads the PDBs/MTZ files, extract crystallographic information, and extract sequence information.
#The folder structures for the PDBs will be /base_folder/PDB_ID/.

#____________________________________________SOURCE REQUIREMENTS____________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 


#_________________________________________DOWNLOAD PDB/MTZ FILES AND CREATE FOLDERS_________________________
  PDB=$1
  base_dir=$2
  if [ -d "/$PDB" ]; then
    echo "Folder exists." 
  else
    mkdir ${PDB}
  fi
  cd ${PDB}
  wget https://files.rcsb.org/download/${PDB}.pdb
  wget https://files.rcsb.org/download/${PDB}-sf.cif
  wget http://edmaps.rcsb.org/coefficients/${PDB}.mtz


#____________________________________RUN MTZ DUMP & EXTRACT CRYSTALLOGRAPHIC INFO____________________________
  phenix.cif_as_mtz ${PDB}-sf.cif --ignore_bad_sigmas --extend_flags --merge #transfer cif into mtz file
  phenix.mtz.dump ${PDB}-sf.mtz > ${PDB}.dump
  
#___________________________________ADD CRYSTALOGRAPHIC DATA TO TEXT FILE__________________________________
  SPACE1=$(grep "^Space group number from file:" ${PDB}.dump | awk '{print $6,$7}')
  UNIT1=$(grep "Unit cell:" ${PDB}.dump | tail -n 1 | sed "s/[(),]//g" | awk '{print $3,$4,$5,$6,$7,$8}')
  RESO1=$(grep "^Resolution" ${PDB}.dump | head -n 1 | awk '{print $4}')

  echo $line $RESO1 $SPACE1 $UNIT1 >> ${base_dir}/space_unit_reso.txt

#__________________________________________DETERMINE HOLO OR APO___________________________________________
  find_largest_lig.py ${PDB}.pdb ${PDB} #this script comes from qFit
  lig_name=$(cat ${PDB}_ligand_name.txt)
  if [ ! = ${lig_name} ]; then
      echo ${PDB} ${lig_name} >> ${base_dir}/PDB_Holo.txt.  #PDB has ligand that is considered a potential 'holo'
  else
      echo ${PDB} >> PDB_Apo.txt #PDB is considered apo.
  fi

#__________________________________________ GET SEQUENCE FROM PDB______________________________________________
  SEQ1=$(python get_seq.py ${PDB}.pdb) #get_seq.py can be found in this repository
  echo "> ${PDB} ${SEQ1}" >> ${base_dir}/sequences.txt
  
