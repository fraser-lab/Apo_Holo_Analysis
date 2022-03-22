#!/bin/bash


'''
This script will take the information on the cystallographic and sequence information of each holo and apo structure and decide if they are pairs.
INPUT: Apo PDB (from submit scipt, list of holo PDBs)
OUTPUT: Text file with a list of paired PDBs with the resolution of each of them.
'''

#____________________________________________SOURCE REQUIREMENTS____________________________________
source phenix_env.sh #source phenix (fill in phenix location)
source activate qfit #conda env with qFit 

base_dir=$2


apo_PDB=$1
if [ -f ${base_dir}/${apo_PDB}/${apo_PDB}.pdb ]; then
         RESO1=$(grep ${apo_PDB} ${base_dir}/space_unit_reso.txt | head -n 1 | awk '{print $2}')
         SPACE1=$(grep ${apo_PDB} ${base_dir}/space_unit_reso.txt | head -n 1 | awk '{print $3}')
         RESO1_lower=$(echo ${RESO1}-0.1 | bc -l)
         RESO1_upper=$(echo ${RESO1}+0.1 | bc -l)
         UNIT1=$(grep ${apo_PDB} ${base_dir}/space_unit_reso.txt | tail -n 1 | sed "s/[(),]//g" | awk '{print $4,$5,$6,$7,$8,$9}')
         UNIT1_out=$UNIT1
         UNIT1=( $UNIT1 )
         UNIT1_0_lower=$(echo ${UNIT1[0]}-1 | bc -l)
         UNIT1_0_upper=$(echo ${UNIT1[0]}+1 | bc -l)

         UNIT1_1_lower=$(echo ${UNIT1[1]}-1 | bc -l)
         UNIT1_1_upper=$(echo ${UNIT1[1]}+1 | bc -l)

         UNIT1_2_lower=$(echo ${UNIT1[2]}-1 | bc -l)
         UNIT1_2_upper=$(echo ${UNIT1[2]}+1 | bc -l)

         UNIT1_3_lower=$(echo ${UNIT1[3]}-1 | bc -l)
         UNIT1_3_upper=$(echo ${UNIT1[3]}+1 | bc -l)

         UNIT1_4_lower=$(echo ${UNIT1[4]}-1 | bc -l)
         UNIT1_4_upper=$(echo ${UNIT1[4]}+1 | bc -l)

         UNIT1_5_lower=$(echo ${UNIT1[5]}-1 | bc -l)
         UNIT1_5_upper=$(echo ${UNIT1[5]}+1 | bc -l)
         
         
   holo_file=holo_PDBs.txt
   while read holo_PDB; do 
      if [ -f ${base_dir}/${holo_PDB}/${holo_PDB}.pdb ]; then
         RESO2=$(grep ${holo_PDB} space_unit_reso.txt | head -n 1 | awk '{print $2}')
         SPACE2=$(grep ${holo_PDB} space_unit_reso.txt | head -n 1 | awk '{print $3}')
         if (( `echo ${RESO2}'<='${RESO1_upper} | bc` )) && (( `echo ${RESO2}'>='${RESO1_lower} | bc` )); then
           if [ $SPACE1 == $SPACE2 ]; then
             UNIT2=$(grep ${holo_PDB} space_unit_reso.txt | tail -n 1 | sed "s/[(),]//g" | awk '{print $4,$5,$6,$7,$8,$9}')
             UNIT2=( $UNIT2 )
             if (( $(echo "${UNIT2[0]} <= ${UNIT1_0_upper}" |bc -l) )) && (( $(echo "${UNIT2[0]} >= ${UNIT1_0_lower}" |bc -l) )) && (( $(echo "${UNIT2[1]} <= ${UNIT1_1_upper}" |bc -l) )) && (( $(echo "${UNIT2[1]} >= ${UNIT1_1_lower}" |bc -l) )) && (( $(echo "${UNIT2[2]} <= ${UNIT1_2_upper}" |bc -l) )) && (( $(echo "${UNIT2[2]} >= ${UNIT1_2_lower}" |bc -l) )); then
                if (( $(echo "${UNIT2[3]} <= ${UNIT1_3_upper}"|bc -l) )) && (( $(echo "${UNIT2[3]} >= ${UNIT1_3_lower}" |bc -l) )) && (( $(echo "${UNIT2[4]} <= ${UNIT1_4_upper}" |bc -l) )) && (( $(echo "${UNIT2[4]} >= ${UNIT1_4_lower}" |bc -l) )) &&  (( $(echo "${UNIT2[5]} <= ${UNIT1_5_upper}" |bc -l) )) && (( $(echo "${UNIT2[5]} >= ${UNIT1_5_lower}" |bc -l) )); then
                   echo ${holo_PDB} >> ${base_dir}/potential_pairs/${apo_PDB}_potential_pairs.txt
                fi
             fi
           fi
         fi
       fi
   done<$holo_file
   #now we have a list of potential pairs, and we are going to go through and match up the more difficult things 
   
   SEQ1=$(grep ${apo_PDB} ${base_dir}/sequences.txt | head -n 1 | awk '{print $2}')
   pot_pairs=${base_dir}/potential_pairs/${apo_PDB}_potential_pairs.txt
   for pair in $(cat $pot_pairs); do
       if [ ! -f ${base_dir}/${pair}/${pair}.pdb ]; then
          echo 'PDB not found'
          continue
       fi
       RESO2=$(grep ${pair} ${base_dir}/space_unit_reso.txt | head -n 1 | awk '{print $2}')
       UNIT2=$(grep ${pair} ${base_dir}space_unit_reso.txt | tail -n 1 | sed "s/[(),]//g" | awk '{print $4,$5,$6,$7,$8,$9}')
       SEQ2=$(grep ${pair} ${base_dir}/sequences.txt | head -n 1 | awk '{print $2}')
           if [[ -z ${SEQ1} ]]; then
              continue
           elif [[ -z ${SEQ2} ]]; then
              continue
           else
              if [ "$SEQ1" = "$SEQ2" ]; then
                 echo $line $line2 $RESO1 $RESO2 >> ${base_dir}/holo_apo_pairs.txt
              else
                 SEQ1_end5=${SEQ1:-5}
                 SEQ2_end5=${SEQ2:-5}
                 SEQ1_begin5=${SEQ1:5}
                 SEQ2_begin5=${SEQ2:5}
                 if [ "$SEQ1" = "$SEQ2_begin5" ] || [ "$SEQ1" = "$SEQ2_end5" ] || [ "$SEQ2" = "$SEQ1_end5" ] || [ "$SEQ2" = "$SEQ1_begin5" ]; then
                       echo $line $line2 $RESO1 $RESO2 >> ${base_dir}/holo_apo_pairs.txt
                 fi
              fi
           fi
   done
fi
    

