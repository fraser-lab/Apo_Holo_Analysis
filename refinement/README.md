These scripts contain the workflow for refinement both before and after qFit. They all depend on Phenix.Refine. The phenix.refinement version used for pre-qFit refinement was 1.17 and the version used for post-qFit refinment was 1.19. Please note that phenix parameters can change with versions and certain PDBs needed individual attention in regards to refinement.




1) refinement_composite_omit.sh  #This script runs the pre-qFit refinement as well as creating the composite omit map which is used in qFit. This script was run using a wrapper script to submit to SGE server. 

Input: PDB file, MTZ file

Output: Refined PDB file/log, composite omit file


2) refinement_aniso_composite_omit.sh  #This script runs the pre-qFit refinement as well as creating the composite omit map for those PDBs in which both pairs had a resolution better than 1.5 angstroms. This script was run using a wrapper script to submit to SGE server. 

Input: PDB file, MTZ file

Output: Refined PDB file/log, composite omit file


3) finalize.params.  #This file is use in both refinement scripts with additional inputs that are consistent across all refinements. 
