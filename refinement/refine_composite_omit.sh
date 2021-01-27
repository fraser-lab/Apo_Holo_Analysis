#!/bin/bash
#$ -l h_vmem=2G
#$ -l mem_free=2G
#$ -t 1-1 #307
#$ -l h_rt=10:00:00
#$ -pe smp 1


#this script will run qfit based on the input PDB names you have.

#________________________________________________INPUTS________________________________________________#
#PDB_file=/wynton/group/fraser/swankowicz/COVID19/structure/COVID-19/PDB2.txt
#working_dir='/wynton/group/fraser/swankowicz/COVID19/structure/COVID-19/' #where the folders are located
echo $working_dir

#________________________________________________SET PATHS________________________________________________#
source /wynton/group/fraser/swankowicz/phenix-installer-1.19-4092-intel-linux-2.6-x86_64-centos6/phenix-1.19-4092/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit

#________________________________________________RUN QFIT________________________________________________#
PDB=$1
echo $PDB


#cp -R ${working_dir}/${PDB}/ $TMPDIR/
#cd $TMPDIR
#cd $PDB

#CHANGE X Elements to C
file=${PDB}.pdb; while read -r line; do var="$(echo "$line" | cut -c 78-79)"; if [[ "$var" = "X" ]]; then echo "$line" | sed s/"$var"/'C'/g ;else echo "$line";fi; done < $file >> ${PDB}_updated.pdb

remove_duplicates ${PDB}_updated.pdb

phenix.cif_as_mtz ${PDB}-sf.cif --extend_flags --merge

mv ${PDB}-sf.mtz ${PDB}.mtz

#RUN READYSET
phenix.ready_set ${PDB}_updated.pdb.fixed

#__________________________________CHECK_____________________________________________________________
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

#RUN REFINEMENT
if [[ -e "${PDB}_updated.pdb.updated_refine_001.pdb" ]]; then
    continue
else
    if [[ -e "${PDB}_updated.pdb.ligands.cif" ]]; then
       echo '________________________________________________________Running refinement with ligand.________________________________________________________'
       if grep -F _refln.F_meas_au $PDB-sf.cif; then
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True #refinement.input.xray_data.r_free_flags.label=R-free-flags #refinement.input.xray_data.labels="FOBS,SIGFOBS"
       else
        echo 'IOBS'   
         phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True #refinement.input.xray_data.r_free_flags.label=R-free-flags #refinement.input.xray_data.labels="IOBS,SIGIOBS"
       fi

    else
      echo '________________________________________________________Running refinement without ligand.________________________________________________________'
      if grep -F _refln.F_meas_au $PDB-sf.cif; then
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True --overwrite #refinement.input.xray_data.r_free_flags.label=R-free-flags #refinement.input.xray_data.labels="FOBS,SIGFOBS"
      else
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/finalize.params refinement.input.xray_data.labels="${field},SIG${field}" refinement.input.xray_data.r_free_flags.generate=True --overwrite #refinement.input.xray_data.r_free_flags.label=R-free-flags #refinement.input.xray_data.labels="IOBS,SIGIOBS"
      fi
    fi      
fi

#RUN COMPOSITE OMIT MAP
    echo 'Starting Composite Omit Map'
    if [[ -e composite_omit_map.mtz ]]; then
        echo 'composite omit map already created'
    else
        if [ ! -f ${PDB}.mtz ]; then
                echo 'No mtz file'
        else
                phenix.mtz.dump ${PDB}.mtz > ${PDB}_mtzdump.out
                if grep -q FREE ${PDB}_mtzdump.out; then
                        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine nproc=1 #input.xray_data.r_free_flags.label=R-free-flags
                else
                        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine nproc=1 r_free_flags.generate=True
                fi
        fi
    fi


#cp -R ${TMPDIR}/${PDB}/ ${working_dir}

