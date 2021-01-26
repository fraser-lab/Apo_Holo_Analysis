#!/bin/bash

#source /wynton/home/fraserlab/swankowicz/phenix-installer-dev-3594-intel-linux-2.6-x86_64-centos6/phenix-dev-3594/phenix_env.sh
#export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
#source activate qfit3
#which python

#file=/wynton/group/fraser/swankowicz/PDB_2A_res_w_lig_191123_2001_2500.txt
#for line in $(cat $file); do
   line=$1
   if grep -Fxq ${line} /wynton/group/fraser/swankowicz/nomtz_191123.txt; then
      exit 1
   else
      line=$(echo ${line} | tr '[:upper:]' '[:lower:]')
      mid=$(echo ${line:1:2})
      echo $line
      if [ ! -f /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump ]; then
         echo $line >> /wynton/group/fraser/swankowicz/nomtz_191123.txt
         echo 'no mtz'
         exit 1
      else
         RESO1=$(grep ${line} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | head -n 1 | awk '{print $2}')
         SPACE1=$(grep ${line} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | head -n 1 | awk '{print $3}')
         RESO1_lower=$(echo ${RESO1}-0.1 | bc -l)
         RESO1_upper=$(echo ${RESO1}+0.1 | bc -l)
         UNIT1=$(grep ${line} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | tail -n 1 | sed "s/[(),]//g" | awk '{print $4,$5,$6,$7,$8,$9}')
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
   fi
   file2=/wynton/group/fraser/swankowicz/PDB_ID_2A_res_nonucleotide.txt
   for line21 in $(cat $file2); do
      line2=$(echo ${line21} | tr '[:upper:]' '[:lower:]')
      if grep -Fxq ${line2} /wynton/group/fraser/swankowicz/PDB_2A_res_w_lig_111419.txt; then
         continue
      else
         echo $line2 
         RESO2=$(grep ${line2} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | head -n 1 | awk '{print $2}')
         SPACE2=$(grep ${line2} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | head -n 1 | awk '{print $3}')
         if (( `echo ${RESO2}'<='${RESO1_upper} | bc` )) && (( `echo ${RESO2}'>='${RESO1_lower} | bc` )); then
           if [ $SPACE1 == $SPACE2 ]; then
             UNIT2=$(grep ${line2} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | tail -n 1 | sed "s/[(),]//g" | awk '{print $4,$5,$6,$7,$8,$9}')
             UNIT2=( $UNIT2 )
             if (( $(echo "${UNIT2[0]} <= ${UNIT1_0_upper}" |bc -l) )) && (( $(echo "${UNIT2[0]} >= ${UNIT1_0_lower}" |bc -l) )) && (( $(echo "${UNIT2[1]} <= ${UNIT1_1_upper}" |bc -l) )) && (( $(echo "${UNIT2[1]} >= ${UNIT1_1_lower}" |bc -l) )) && (( $(echo "${UNIT2[2]} <= ${UNIT1_2_upper}" |bc -l) )) && (( $(echo "${UNIT2[2]} >= ${UNIT1_2_lower}" |bc -l) )); then
                echo 'pair1' 
                if (( $(echo "${UNIT2[3]} <= ${UNIT1_3_upper}"|bc -l) )) && (( $(echo "${UNIT2[3]} >= ${UNIT1_3_lower}" |bc -l) )) && (( $(echo "${UNIT2[4]} <= ${UNIT1_4_upper}" |bc -l) )) && (( $(echo "${UNIT2[4]} >= ${UNIT1_4_lower}" |bc -l) )) &&  (( $(echo "${UNIT2[5]} <= ${UNIT1_5_upper}" |bc -l) )) && (( $(echo "${UNIT2[5]} >= ${UNIT1_5_lower}" |bc -l) )); then
                   echo 'pair2'
                   echo ${line2} >> /wynton/group/fraser/swankowicz/pairs/${line}_potential_pairs.txt
                fi
             fi
           fi
         fi
      fi
   done
   SEQ1=$(~/anaconda3/envs/qfit3/bin/python /wynton/group/fraser/swankowicz/get_seq.py /wynton/group/fraser/swankowicz/mtz/191114/pdb${line}.ent)
   file3=/wynton/group/fraser/swankowicz/pairs/${line}_potential_pairs.txt
   for line2 in $(cat $file3); do
       echo $line2
       if [ ! -f /wynton/group/fraser/swankowicz/mtz/191114/pdb${line}.ent ]; then
          cp /netapp/database/pdb/remediated/pdb/${mid}/pdb${line}.ent.gz /wynton/group/fraser/swankowicz/mtz/191114/
          gunzip pdb${line}.ent.gz
       fi
       RESO2=$(grep ${line2} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | head -n 1 | awk '{print $2}')
       UNIT2=$(grep ${line2} /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt | tail -n 1 | sed "s/[(),]//g" | awk '{print $4,$5,$6,$7,$8,$9}')
       SEQ2=$(~/anaconda3/envs/qfit3/bin/python /wynton/group/fraser/swankowicz/get_seq.py /wynton/group/fraser/swankowicz/mtz/191114/pdb${line2}.ent)
       echo $SEQ1
       echo $SEQ2
                if [[ -z ${SEQ1} ]]; then
                    echo 'no seq1'
                    exit 1
                elif [[ -z ${SEQ2} ]]; then
                   echo 'no seq2'
                   continue
                else
                   echo $SEQ2
                   if [ "$SEQ1" = "$SEQ2" ]; then
                      echo 'pair'
                     echo $line
                     echo $SEQ1
                     echo $line2
                     echo $SEQ2
                     echo $line $line2 $RESO1 $RESO2 >> /wynton/group/fraser/swankowicz/PDB_pairs_191123.txt
                   else
                     SEQ1_end5=${SEQ1:-5}
                     SEQ2_end5=${SEQ2:-5}
                     SEQ1_begin5=${SEQ1:5}
                     SEQ2_begin5=${SEQ2:5}
                     if [ "$SEQ1" = "$SEQ2_begin5" ] || [ "$SEQ1" = "$SEQ2_end5" ] || [ "$SEQ2" = "$SEQ1_end5" ] || [ "$SEQ2" = "$SEQ1_begin5" ]; then
                       echo 'pair'
                       echo $line $line2 $RESO1 $RESO2 >> /wynton/group/fraser/swankowicz/PDB_pairs_191123.txt
                     fi
                   fi
              fi
          fi
      fi
   done
  fi

    

