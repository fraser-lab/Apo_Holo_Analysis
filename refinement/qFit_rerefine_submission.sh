#!/bin/bash
#$ -l h_vmem=6G
#$ -l mem_free=6G
#$ -t 1-150 #number of PDBs in list
#$ -l h_rt=20:00:00
#$ -pe smp 8
#$ -R yes
#$ -V

#!/bin/bash
#Stephanie Wankowicz
#https://stephaniewankowicz.github.io/
#Fraser Lab UCSF

'''
This script will submit seperate jobs to run qFit individually. 
'''

#____________________________________________SOURCE REQUIREMENTS____________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 
export OMP_NUM_THREADS=1

#________________________________________________INPUTS________________________________________________
base_dir='/location/you/would/like/folders/of/PDBs/to/exist/' #base folder (where you want to put folders/pdb files)
pdb_filelist=PDB_ID_2A_res.txt

#________________________________________________RUN QFIT________________________________________________
PDB=$(cat $PDB_file | head -n $SGE_TASK_ID | tail -n 1)
echo $PDB
qfit_protein composite_omit_map.mtz -l 2FOFCWT,PH2FOFCWT ${PDB}_updated.pdb.updated_refine_001.pdb -p 8

#________________________________________________RUN REREFINEMENT_________________________________________
if [[ -e ${PDB}_qFit.pdb ]]; then
   echo 'Refinement Done'
else
   qfit_final_refine_xray.sh ${PDB}.mtz multiconformer_model2.pdb
fi
   
