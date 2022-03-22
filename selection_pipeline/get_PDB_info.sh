#!/bin/bash
#Stephanie Wankowicz
#https://stephaniewankowicz.github.io/
#Fraser Lab UCSF

#This script takes in a list of PDB IDs, downloads the PDBs/MTZ files, extract crystallographic information, and extract sequence information.
# The folder structures for the PDBs will be /base_folder/PDB_ID/.

#____________________________________________SOURCE REQUIREMENTS____________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 

#________________________________________________INPUTS________________________________________________
base_dir='/location/you/would/like/folders/of/PDBs/to/exist/' #base folder (where you want to put folders/pdb files)
pdb_filelist=PDB_ID_2A_res.txt

#_________________________________________DOWNLOAD PDB/MTZ FILES AND CREATE FOLDERS_________________________
while read -r line; do
  PDB=$line
  cd ${base_dir}
  if [ -d "/$PDB" ]; then
    echo "Folder exists." 
  else
    mkdir ${PDB}
  fi
  cd ${PDB}
  phenix.fetch_pdb ${PDB}
  phenix.fetch_pdb -x ${PDB}


#____________________________________RUN MTZ DUMP & EXTRACT CRYSTALLOGRAPHIC INFO__________________________
  phenix.cif_as_mtz ${PDB} --ignore_bad_sigmas --extend_flags --merge #transfer cif into mtz file
  phenix.mtz.dump ${PDB}.mtz >${PDB}.dump #run mtz dump

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
      echo ${PDB} >> ${base_dir}/PDB_Apo.txt #PDB is considered apo.
  fi

#__________________________________________ GET SEQUENCE FROM PDB____________________________________________
  SEQ1=$(python get_seq.py ${PDB}.pdb) #get_seq.py can be found in this repository
  echo "> ${PDB} ${SEQ1}" >> ${base_dir}/sequences.txt
  
done < $pdb_filelist
