This folder contains the scripts used to select the original set of Apo/Holo pairs used in our analysis.

It started with a list of X-Ray Crystallography PDB IDs with a resolution better or equal than 2A.

Note that some of these scripts pull commands from qFit post analysis scripts. In those scripts you will see the activation of a conda environment at the top. To access these scripts, please install qFit 3.0 (https://github.com/ExcitedStates/qfit-3.0). 

To get to the final dataset, we used the following scripts (in this order): 

1) remove_nucleotides.sh         #This script removed any PDB IDs that contained RNA or DNA fragments. Uses qFit. 

Input: List of PDB IDs with resolution equal to or less than 2 angstroms.
Output: List of PDBs with resolution equal to or less than 2 angstroms and contain no nucelotide fragments.



2) determine_apo_or_holo.sh     #This script identifies the largest ligand in the PDB and determines if the PDB should be categorized as apo or holo. Apo structures are defined as having only ligands with less than 10 heavy atoms, excluding crystallographic additives. 

Input: List of PDBs with resolution equal to or less than 2 angstroms and contain no nucelotide fragments.
Output: List of PDBs classified as holo; List of PDBs classified as apo.



3) gather_seq.sh     #This script gathers the amino acid sequence of each PDB. This script calls the get_seq.py script also located in this folder.

Input: List of PDBs 
Output: PDB Ids + sequence



4) grab_space_unit.sh    #This script runs the phenix command phenix.mtz_dump (https://www.phenix-online.org/download/) to gather information on the unit cell and space group of the PDB. It then extracts the space group, unit cell information, and resolution for each PDB. 

Input: List of PDBs
Output: PDB Ids + Resolution + Space Group + Unit Cell Dimension + Unit Cell Angle



5) find_apo_holo.sh      #This script takes every PDB ID from the holo dataset and goes through every ID in the Apo data to determine if they match by: (1) Resolution, (2) Space Group, (3) Unit Cell Angle/Dimension, (4) Sequence.

Input: List of PDBs classified as holo; List of PDBs classified as apo, PDB Ids + Resolution + Space Group + Unit Cell Dimension + Unit Cell Angle, PDB Ids + sequence
Output: Paired List of Apo/Holo PDBs


6) select_for_qfit.sh.     #This script takes the Apo/Holo pairs and determines for every holo PDB, which Apo PDB is closest in resolution to move foward in the analysis.

Input: Paired list of Apo/Holo PDBs.
Output: Final paired list of Apo/Holo PDBs.

