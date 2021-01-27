
#________________________________________________INPUTS________________________________________________#
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

#________________________________________________SET PATHS________________________________________________#
source phenix env
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit #qFit 

#__________________________________DETERMINE RESOLUTION AND (AN)ISOTROPIC REFINEMENT__________________________________
PDB=$1
echo $PDB


if [[ -e "${PDB}-sf.cif" ]]; then #if SF is in cif format, convert
  phenix.mtz_to_cif ${PDB}-sf.cif
  mv "${PDB}-sf.mtz" ${PDB}.mtz  #make sure all mtz files are named the same way.
fi

mtzmetadata=`phenix.mtz.dump ${PDB}.mtz`
resrange=`grep "Resolution range:" <<< "${mtzmetadata}"` #determine the resolution of the structure
echo ${resrange}


#_______________________________________________REFINEMENT PREP________________________________________________#



#________________________________________________RUN REFINEMENT________________________________________________#
if [[ -e "${PDB}_updated.pdb.ligands.cif" ]]; then
       echo '________________________________________________________Running refinement with ligand.________________________________________________________'
         phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif finalize.params refinement.input.xray_data.r_free_flags.generate=True output.prefix="${PDB}" refinement.input.xray_data.labels=$xray_data_labels
else
      echo '________________________________________________________Running refinement without ligand.________________________________________________________'
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz finalize.params refinement.input.xray_data.r_free_flags.generate=True output.prefix="${PDB}" refinement.input.xray_data.labels=$xray_data_labels
fi

#__________________________________________RUN COMPOSITE OMIT MAP
if [[ -e composite_omit_map.mtz ]]; then
        echo 'Composite omit map already created'
else
    if [ ! -f ${PDB}.mtz ]; then
         echo 'No mtz file'
    else
         if grep -q FREE ${PDB}_mtzdump.out; then #if there are r_free_flags, don't re-generate.
             phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine
         else
             phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine r_free_flags.generate=True
         fi
   fi
fi
