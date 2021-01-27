#!/bin/bash

#________________________________________________SET PATHS________________________________________________#
source phenix env

PDB=$1
echo $PDB

#__________________________________DETERMINE RESOLUTION AND (AN)ISOTROPIC REFINEMENT__________________________________

if [[ -e "${PDB}-sf.cif" ]]; then #if SF is in cif format, convert
  phenix.mtz_to_cif ${PDB}-sf.cif
  mv "${PDB}-sf.mtz" ${PDB}.mtz  #make sure all mtz files are named the same way.
fi

mtzmetadata=`phenix.mtz.dump ${PDB}.mtz`
resrange=`grep "Resolution range:" <<< "${mtzmetadata}"` #determine the resolution of the structure
echo ${resrange}


#__________________________________DETERMINE FOBS v IOBS v FP__________________________________
# List of Fo types we will check for
obstypes="FP FOBS F-obs IOBS"

# Get amplitude fields
ampfields=`grep "amplitude" <<< "${mtzmetadata}"`
ampfields=`echo "${ampfields}" | awk '{$1=$1};1' | cut -d " " -f 1`

# Clear xray_data_labels variable
xray_data_labels=""

# Is amplitude an Fo?
for field in ${ampfields}; do
  # Check field in obstypes
  if grep -F -q -w $field <<< "${obstypes}"; then
    # Check SIGFo is in the mtz too!
    if grep -F -q -w "SIG$field" <<< "${mtzmetadata}"; then
      xray_data_labels="${field},SIG${field}";
      break
    fi
  fi
done
if [ -z "${xray_data_labels}" ]; then
  echo >&2 "Could not determine Fo field name with corresponding SIGFo in .mtz.";
  echo >&2 "Was not among ${obstypes}. Please check .mtz file\!";
  exit 1;
else
  echo "data labels: ${xray_data_labels}"
fi


#_________________________________________DETERMINE R FREE FLAGS_________________________________________________#
gen_Rfree=True
rfreetypes="FREE R-free-flags"
for field in ${rfreetypes}; do
  if grep -F -q -w $field <<< "${mtzmetadata}"; then
    gen_Rfree=False;
    echo "Rfree column: ${field}";
    break
  fi
done

#_______________________________________________REFINEMENT PREP________________________________________________#
phenix.ready_set pdb_file_name=${PDB}.pdb


#________________________________________________RUN REFINEMENT________________________________________________#
if [[ -e "${PDB}_updated.pdb.ligands.cif" ]]; then
       echo '________________________________________________________Running refinement with ligand.________________________________________________________'
         phenix.refine ${PDB}.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif finalize.params refinement.input.xray_data.r_free_flags.generate=True output.prefix="${PDB}" refinement.input.xray_data.labels=$xray_data_labels
else
      echo '________________________________________________________Running refinement without ligand.________________________________________________________'
        phenix.refine ${PDB}.updated.pdb ${PDB}.mtz finalize.params refinement.input.xray_data.r_free_flags.generate=True output.prefix="${PDB}" refinement.input.xray_data.labels=$xray_data_labels
fi


#________________________________________________________RUN COMPOSITE OMIT MAP________________________________________________________#
    if [[ -e composite_omit_map.mtz ]]; then
        echo 'composite omit map already created'
    else
        if [ ! -f ${PDB}.mtz ]; then
                echo 'No mtz file'
        else
                phenix.mtz.dump ${PDB}.mtz > ${PDB}_mtzdump.out
                if grep -q FREE ${PDB}_mtzdump.out; then
                        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine
                else
                        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine r_free_flags.generate=True
                fi
        fi
    fi


