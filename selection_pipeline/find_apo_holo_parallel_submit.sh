#$ -l mem_free=2G
#$ -t 1-100
#$ -l h_rt=100:00:00
#$ -R yes
#$ -V

#Stephanie Wankowicz
#https://stephaniewankowicz.github.io/
#Fraser Lab UCSF

#This script takes in a list of PDB IDs. For each PDB, it will spit out its own processes, which will run get_PDB_info_paralell.sh.
#The folder structures for the PDBs will be /base_folder/PDB_ID/.

#________________________________________________INPUTS________________________________________________
apo_file=PDB_Apo.txt
holo_file=PDB_Holo.txt
base_dir='/location/you/would/like/folders/of/PDBs/to/exist/'



cd ${base_dir}
mkdir potential_pairs

#________________________________________________SET DEPENDENCY PATHS__________________________________
source phenix_env.sh
source activate qfit

#________________________________________________RUN SCRIPT____________________________________________
PDB=$(cat $apo_file | head -n $SGE_TASK_ID | tail -n 1)

sh find_apo_holo_parallel.sh ${PDB} ${base_dir} ${PDB_Holo}
