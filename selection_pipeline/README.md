# PDB selection pipeline

The pipeline starts with a list of PDB IDs with your specification (type of experiment, resolution, ect). This can be obtained from the [PDB](https://www.rcsb.org/). 

Pipeline Requirements:
[Phenix](https://phenix-online.org/documentation/install-setup-run.html)<br/> 
[qFit](https://github.com/ExcitedStates/qfit-3.0)

Conda enviornment that contains the following packages (you can install these packages into the same conda env that qFit sits in):

os<br/> 
sys<br/> 
pandas<br/>
Bio.PDB


This repository contains a list of scripts that can be used to find and create isomorphous PDB pairs with the same sequence. The original intent was to select ligand bound and ligand unbound structures however this can be adapted to look for other PDB pairs. 


1) The first scripts will take an input of a text file of PDB IDs (one PDB per line [example](https://github.com/stephaniewankowicz/PDB_selection_pipeline/blob/master/PDB_ID_2A_res.txt)).

    a) Use get_PDB_info.sh if you want to run the script serially (ie going through each PDB at one time).

    b) Use get_PDB_info_parallel_submit.sh if you want to use a SGE server to submit jobs one by one to look at PDB info.



2) This second set of scripts will go through and match up each holo structure with potential apo structures based on resolution, unit cell, and space group. The second half of the script will them compare the potential pairs by sequence. 
    a) Use find_apo_holo.sh if you want to run the script serially (ie going through each PDB at one time).
    b) Use find_apo_holo_parallel_submit.sh if you want to use a SGE server to submit jobs one by one to look at PDB info.


3) select_for_qfit.py: OPTIONAL! This script will subset down your pairs to a list of only one apo structure for every holo structure, selecting for the closest in resolution


Other scripts in this directory:

1) get_seq.py: This script will use Bio.PDB to get the sequence directly from the PDBs we are looking to compare (this will be a more accurate way to gather sequences and include gaps/missing residues.)

