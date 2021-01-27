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
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

#________________________________________________SET PATHS________________________________________________#
source /wynton/group/fraser/swankowicz/phenix-installer-1.18rc7-3834-intel-linux-2.6-x86_64-centos6/phenix-1.18rc7-3834/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit3

#__________________________________DETERMINE RESOLUTION AND (AN)ISOTROPIC REFINEMENT__________________________________
PDB=$1
echo $PDB

mv "${PDB}-sf.mtz" ${PDB}.mtz
echo "here"
mtzmetadata=`phenix.mtz.dump ${PDB}.mtz`
resrange=`grep "Resolution range:" <<< "${mtzmetadata}"`

echo "${mtzmetadata}"
echo "${resrange}"

res=`echo "${resrange}" | cut -d " " -f 4 | cut -c 1-5`
res1000=`echo $res | awk '{tot = $1*1000}{print tot }'`

if (( $res1000 < 1550 )); then
  adp='adp.individual.anisotropic="not (water or element H)"'
else
  adp='adp.individual.isotropic=all'
fi

#________________________________________________RUN QFIT________________________________________________#
PDB=$1
echo $PDB

#RUN REFINEMENT
if [[ -e "${PDB}_updated.pdb.ligands.cif" ]]; then
       echo '________________________________________________________Running refinement with ligand.________________________________________________________'
         phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz ${PDB}_updated.pdb.ligands.cif /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/finalize_aniso.params refinement.input.xray_data.r_free_flags.generate=True "$adp" output.prefix="${PDB}_aniso" #refinement.input.xray_data.labels=$xray_data_labels output.prefix="${PDB}_aniso"
else
      echo '________________________________________________________Running refinement without ligand.________________________________________________________'
        phenix.refine ${PDB}_updated.pdb.updated.pdb ${PDB}.mtz /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/finalize_aniso.params refinement.input.xray_data.r_free_flags.generate=True "$adp" output.prefix="${PDB}_aniso" #refinement.input.xray_data.labels=$xray_data_labels output.prefix="${PDB}_aniso"
fi

#RUN COMPOSITE OMIT MAP
    echo 'Starting Composite Omit Map'
    if [[ -e composite_omit_map.mtz ]]; then
        echo 'composite omit map already created'
    else
        if [ ! -f ${PDB}.mtz ]; then
                echo 'No mtz file'
        else
                phenix.mtz.dump ${PDB}-sf.mtz > ${PDB}_mtzdump.out
                if grep -q FREE ${PDB}_mtzdump.out; then
                        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine nproc=1 
                else
                        phenix.composite_omit_map ${PDB}.mtz ${PDB}_updated.pdb.updated_refine_001.pdb omit-type=refine nproc=1 r_free_flags.generate=True
                fi
        fi
    fi
