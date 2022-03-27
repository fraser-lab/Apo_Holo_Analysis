This folder contains scripts used to assess the dynamics and other properties of the structures in our dataset. 

Many of the analysis called within these scripts are from the [qFit repository] (https://github.com/ExcitedStates/qfit-3.0).

The analysis included in the wrapper script are:
1) Weighted B-Factor calculation
2) Root Mean Squared Flutations
3) Solvent Exposure
4) Order Parameters
5) Rotamer Assignment

To run all analysis scripts, use the analysis_wrapper.sh.
Note, [qFit] (https://github.com/ExcitedStates/qfit-3.0) will need to be installed.

You also have the option to subset any of these outputs based on a ligand in one of the structures.


Additionally, run_hbplus.sh can be used to look at hydrogen bond changes within multiconformer structures using [HBplus](https://www.ebi.ac.uk/thornton-srv/software/HBPLUS/). 


