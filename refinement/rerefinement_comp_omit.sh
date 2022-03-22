#!/bin/bash
#$ -l h_vmem=4G
#$ -l mem_free=4G
#$ -t 1-150
#$ -l h_rt=8:00:00
#$ -pe smp 1

#Stephanie Wankowicz
#https://stephaniewankowicz.github.io/
#Fraser Lab UCSF

'''
This script will run a re-refinement script under phenix version 1.18 as well as create a composite omit map for submisison to qFit.
The script may need to be updated for another version of Phenix. 
'''

#____________________________________________SOURCE REQUIREMENTS__________________________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 
export PHENIX_OVERWRITE_ALL=true #This allows phenix to overwrite the files outputted from a previous refinement run. 


#________________________________________________INPUTS__________________________________________________________
base_dir='/location/you/would/like/folders/of/PDBs/to/exist/' #base folder (where the folders containing pdb files)
pdb_filelist=PDB_ID_2A_res.txt


PDB=$(cat $PDB_file | awk '{ print $1 }' |head -n $SGE_TASK_ID | tail -n 1)
echo $PDB

#________________________________________________FIX INPUT PDBs________________________________________________#

CHANGE X Elements to C
file=${PDB}.pdb; while read -r line; do var="$(echo "$line" | cut -c 78-79)"; if [[ "$var" = "X" ]]; then echo "$line" | sed s/"$var"/'C'/g ;else echo "$line";fi; done < $file >> ${PDB}_updated.pdb

remove_duplicates ${PDB}_updated.pdb #this will remove duplicate atoms in the input PDBs

phenix.cif_as_mtz ${PDB}-sf.cif --extend_flags --merge 

mv ${PDB}-sf.mtz ${PDB}.mtz

#RUN READYSET
phenix.ready_set ${PDB}_updated.pdb.fixed

#__________________________________DETERMINE FOBS v IOBS v FP__________________________________
mtzmetadata=`phenix.mtz.dump "${PDB}.mtz"`

# List of Fo types we will check for
obstypes="FP FOBS F-obs I IOBS I-obs FC"

# Get amplitude fields
ampfields=`grep -E "amplitude|intensity" <<< "${mtzmetadata}"`
ampfields=`echo "${ampfields}" | awk '{$1=$1};1' | cut -d " " -f 1`

# Clear xray_data_labels variable

xray_data_labels=""

for field in ${ampfields}; do
  echo $field
  # Check field in obstypes
  if grep -F -q -w $field <<< "${obstypes}"; then
    echo "found obs"
    # Check SIGFo is in the mtz too!
    if grep -F -q -w "SIG$field" <<< "${mtzmetadata}"; then
      xray_data_labels="${field},SIG${field}";
      break
    fi
  fi
done

#______________________________________________________RUN REFINEMENT______________________________________________
if [[ -e "${PDB}_updated.pdb.updated_refine_001.pdb" ]]; then
    continue
else
    if [[ -e "${PDB}_updated.pdb.ligands.cif" ]]; then
       echo '________________________________________________________Running refinement with ligand.________________________________________________________'
if grep -F _refln.F_meas_au $PDB-sf.cif; then
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True --overwrite  
       else 
         phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True --overwrite 
       fi

    else
      echo '________________________________________________________Running refinement without ligand.________________________________________________________'
      if grep -F _refln.F_meas_au $PDB-sf.cif; then
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True --overwrite 
      else
phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True --overwrite 
      fi
    fi
fi


#___________________________________________RUN COMPOSITE OMIT MAP_________________________________________________
if [[ -e composite_omit_map.mtz ]]; then
     echo 'Composite omit map already created'
else
     phenix.mtz.dump ${PDB}.mtz > ${PDB}_mtzdump.out
     if grep -q FREE ${PDB}_mtzdump.out; then
        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine nproc=1
     else
        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine nproc=1 r_free_flags.generate=True
     fi
fi

