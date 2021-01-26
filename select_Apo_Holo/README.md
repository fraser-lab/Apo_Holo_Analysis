This folder contains the scripts used to select the original set of Apo/Holo pairs used in our analysis.

It started with a list of X-Ray Crystallography PDB IDs with a resolution better or equal than 2A.

Note that some of these scripts pull commands from qFit post analysis scripts. In those scripts you will see the activation of a conda environment at the top. To access these scripts, please install qFit 3.0 (https://github.com/ExcitedStates/qfit-3.0). 

To get to the final dataset, we used the following scripts (in this order): 

1) remove_nucleotides.sh         #This script removed any PDB IDs that contained RNA or DNA fragments. Uses qFit. 
Input: List of PDB IDs with resolution equal to or less than 2 angstroms.
Output: List of PDBs with resolution equal to or less than 2 angstroms and contain no nucelotide fragments.

2) determine_apo_or_holo.sh.     #This script identifies the largest ligand in the PDB and determines if the PDB should be categorized as apo or holo. Apo structures are defined as having only ligands with less than 10 heavy atoms, excluding crystallographic additives. 
Input: List of PDBs with resolution equal to or less than 2 angstroms and contain no nucelotide fragments.
Output: List of PDBs classified as holo; List of PDBs classified as apo.
