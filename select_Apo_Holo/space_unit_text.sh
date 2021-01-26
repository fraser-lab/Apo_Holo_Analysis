#!/bin/bash

#source /wynton/home/fraserlab/swankowicz/phenix-installer-dev-3594-intel-linux-2.6-x86_64-centos6/phenix-dev-3594/phenix_env.sh
#export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
#source activate qfit3
#which python

line=$(echo $1 | tr '[:upper:]' '[:lower:]')
mid=$(echo ${line:1:2})
SPACE1=$(grep "^Space group number from file:" /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump | awk '{print $6,$7}')
UNIT1=$(grep "Unit cell:" /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump | tail -n 1 | sed "s/[(),]//g" | awk '{print $3,$4,$5,$6,$7,$8}')
RESO1=$(grep "^Resolution" /wynton/group/fraser/swankowicz/mtz/191114/${line}.dump | head -n 1 | awk '{print $4}')

echo $line $RESO1 $SPACE1 $UNIT1 >> /wynton/group/fraser/swankowicz/space_unit_reso_191118.txt
