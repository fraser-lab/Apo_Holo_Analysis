#!/bin/bash



#__________________SET PATHS________________________________________________#
source /wynton/group/fraser/swankowicz/phenix-installer-1.19.2-4158-intel-linux-2.6-x86_64-centos6/phenix-1.19.2-4158/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit

PDB_file=/wynton/group/fraser/swankowicz/script/text_files/qfit_pairs_191218.txt
output_dir='qfit_output/'
PDB_dir='/wynton/group/fraser/swankowicz/AWS_refine_done/'

#________________________________________________Qfit Analysis________________________________________________#
for i in {2..200}; do
  holo=$(cat $PDB_file | awk '{ print $1 }' |head -n $i | tail -n 1)
  apo=$(cat $PDB_file | awk '{ print $2 }' | head -n $i | tail -n 1)
  echo 'Holo:' ${holo}
  echo 'Apo:' ${apo}
  cd $base_dir
  find_largest_lig ${PDB_dir}/${holo}/${holo}_qFit.pdb ${holo}
  lig_name=$(cat "${holo}_ligand_name.txt")
  if [ ! -f ${PDB_dir}/${holo}/${holo}_qFit.pdb ] || [ ! -f ${PDB_dir}/${apo}/${apo}_qFit.pdb ]; then
      echo 'File not found'     
      continue
  else
   mv ${PDB_dir}/${holo}/${holo}_qFit_renamed_renmbered_refitted.pdb ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb
   mv ${PDB_dir}/${apo}/${apo}_qFit_renamed_renmbered.pdb ${PDB_dir}/${apo}/${apo}_qFit.pdb
   #rename_chain.py ${PDB_dir}/${apo}/${apo}_qFit.pdb ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb ${apo} ${holo}

   b_fac=$(b_factor.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb --pdb=${holo}_qFit) #get heavy atom b-factor
   qfit_RMSF.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb --pdb=${holo}_qFit
   phenix.rotalyze model=${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb outliers_only=False > ${output_dir}/${holo}_qFit_rotamer_output.txt
   python get_sasa.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb ${holo}_qFit ${output_dir}
   make_methyl_df.py ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb
   res=$(python /wynton/group/fraser/swankowicz/script/Wilson_b_extrac.py /wynton/group/fraser/swankowicz/mtz/191114/pdb${holo}.ent ${holo})
   calc_OP.py ${output_dir}/${holo}_qFit_methyl.dat ${PDB_dir}/${holo}/${holo}_qFit.pdb_fitted.pdb ${output_dir}/${holo}_qFit_methyl.out -r ${res} -b ${b_fac}
   
#APO STRUCTURE
   b_fac=$(b_factor.py ${PDB_dir}/${apo}/${apo}_qFit.pdb --pdb=${apo}_qFit)
   qfit_RMSF.py ${PDB_dir}/${apo}/${apo}_qFit.pdb --pdb=${apo}_qFit
   phenix.rotalyze model=${PDB_dir}/${apo}/${apo}_qFit.pdb outliers_only=False > ${base_dir}/${apo}_qFit_rotamer_output.txt
   python get_sasa.py ${PDB_dir}/${apo}/${apo}_qFit.pdb ${apo}_qFit ${base_dir}
   make_methyl_df.py ${PDB_dir}/${apo}/${apo}_qFit.pdb
   res=$(python /wynton/group/fraser/swankowicz/script/Wilson_b_extrac.py /wynton/group/fraser/swankowicz/mtz/191114/pdb${apo}.ent ${apo})
   calc_OP.py ${output_dir}/${apo}_qFit_methyl.dat ${PDB_dir}/${apo}/${apo}_qFit.pdb ${output_dir}/${apo}_qFit_methyl.out -r ${res} -b ${b_fac}
   fi
  
   python subset_output_apo.py ${holo} ${apo} -dist 10.0 -qFit=Y -lig ${lig_name}
   python subset_output_apo.py ${holo} ${apo} -dist 5.0 -qFit=Y -lig ${lig_name}
   python subset_output_holo.py ${holo} ${apo} -dist 10.0 -qFit=Y -lig ${lig_name}
   python subset_output_holo.py ${holo} ${apo} -dist 5.0 -qFit=Y -lig ${lig_name}
fi
done
