#!/bin/bash

'''
This script will run all of the analysis for the apo and holo PDBs including:
B-factors
RMSF
Order Parameters
Solvent Exposure
Rotamer Analysis

It will then subset each analysis based on distance from the ligand. This distance is measured in angstroms.
'''
#____________________________________________SOURCE REQUIREMENTS____________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 

#________________________________________________INPUTS________________________________________________
PDB_dir='/location/you/would/like/folders/of/PDBs/to/exist/' #base folder (where you want to put folders/pdb files)
pdb_pairs=holo_apo_pairs.txt # this file should have holo PDBs in column 1, apo PDBs in column 2.
output_dir='/where/you/want/the/output/of/the/analysis/to/go/'


#________________________________________________RUN ANALYSIS________________________________________________#
for i in {2..100}; do
  holo=$(cat $pdb_pairs | awk '{ print $1 }' |head -n $i | tail -n 1)
  apo=$(cat $pdb_pairs | awk '{ print $2 }' | head -n $i | tail -n 1)
  echo 'Holo:' ${holo}
  echo 'Apo:' ${apo}
  cd $base_dir
  find_largest_lig ${PDB_dir}/${holo}/${holo}_qFit.pdb ${holo}
  lig_name=$(cat "${holo}_ligand_name.txt")
  if [ ! -f ${PDB_dir}/${holo}/${holo}_qFit.pdb ] || [ ! -f ${PDB_dir}/${apo}/${apo}_qFit.pdb ]; then
      echo 'PDBs not found!'     
  else
#HOLO STRUCTURE
   b_fac=$(b_factor.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb --pdb=${holo}_qFit) #get heavy atom b-factor
   qfit_RMSF.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb --pdb=${holo}_qFit
   phenix.rotalyze model=${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb outliers_only=False > ${output_dir}/${holo}_qFit_rotamer_output.txt
   python get_sasa.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb ${holo}_qFit ${output_dir}
   make_methyl_df.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb
   res=$(python get_res.py ${holo}.pdb ${holo})
   calc_OP.py ${output_dir}/${holo}_qFit_methyl.dat ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb ${output_dir}/${holo}_qFit_methyl.out -r ${res} -b ${b_fac}
   
#APO STRUCTURE
   b_fac=$(b_factor.py ${PDB_dir}/${apo}/${apo}_qFit.pdb --pdb=${apo}_qFit)
   qfit_RMSF.py ${PDB_dir}/${apo}/${apo}_qFit.pdb --pdb=${apo}_qFit
   phenix.rotalyze model=${PDB_dir}/${apo}/${apo}_qFit.pdb outliers_only=False > ${base_dir}/${apo}_qFit_rotamer_output.txt
   python get_sasa.py ${PDB_dir}/${apo}/${apo}_qFit.pdb ${apo}_qFit ${base_dir}
   make_methyl_df.py ${PDB_dir}/${apo}/${apo}_qFit.pdb
   res=$(python get_res.py ${apo}.pdb ${apo})
   calc_OP.py ${output_dir}/${apo}_qFit_methyl.dat ${PDB_dir}/${apo}/${apo}_qFit.pdb ${output_dir}/${apo}_qFit_methyl.out -r ${res} -b ${b_fac}
   fi
  
   python subset_apo.py ${holo} ${apo} -dist 10.0 -qFit=Y -lig ${lig_name}
   python subset_apo.py ${holo} ${apo} -dist 5.0 -qFit=Y -lig ${lig_name}
   python subset_holo.py ${holo} ${apo} -dist 10.0 -qFit=Y -lig ${lig_name}
   python subset_holo.py ${holo} ${apo} -dist 5.0 -qFit=Y -lig ${lig_name}
fi
done
