
"""

    mcOPA: multi-conformer Order Parameter Analysis
    R. Bryn Fenwick, Henry van den Bedem, James S. Fraser, Peter Wright
    e-mail: wright@scripps.edu 

 
        Copyright (C) 2013 The Scripps Research Institute

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License. 

"""
import numpy as np
from sys import exit
import pandas as pd
from argparse import ArgumentParser

pi = 3.14159265359

def parse_args():
    p = ArgumentParser(description=__doc__)
    p.add_argument("data_file", type=str,
                   help="this is the output from step one")
    p.add_argument("pdb", type=str, help="pdb file to extract order parameters from")
    p.add_argument("file_out", type=str, help="output file name")
    p.add_argument("model", type=str, help="Methyl or NH")
    p.add_argument("-r", "--Resolution", type=float, help="Resolution of PDB")
    p.add_argument("-b", "--Bfactor", type=float, help="Mean B Factor of Heavy atoms of PDB")
    args = p.parse_args()
    return args


def calc_p2(c1,c2,c3,c4):
  cxij = c2[0] - c1[0]
  cyij = c2[1] - c1[1]
  czij = c2[2] - c1[2]
  cxkl = c4[0] - c3[0]
  cykl = c4[1] - c3[1]
  czkl = c4[2] - c3[2]
  rij  = ( ( cxij*cxij ) + ( cyij*cyij ) + ( czij*czij ) )**0.5
  rkl  = ( ( cxkl*cxkl ) + ( cykl*cykl ) + ( czkl*czkl ) )**0.5
  sx2 = cxij*cxij 
  sy2 = cyij*cyij
  sz2 = czij*czij
  sxy = cxij*cyij
  sxz = cxij*czij
  syz = cyij*czij
  ssx2 = cxkl*cxkl
  ssy2 = cykl*cykl
  ssz2 = czkl*czkl
  ssxy = cxkl*cykl
  ssxz = cxkl*czkl
  ssyz = cykl*czkl
  part1 = ((sx2 + sy2 + sz2)**0.5) * ((ssx2 + ssy2 + ssz2)**0.5)
  part2 = ((cxij*cxkl)+(cyij*cykl)+(czij*czkl))
  cosTheta = (part2/part1)  
  cos2Theta = cosTheta*cosTheta 
  p2 = (( 3.0 * (cos2Theta) ) - 1.0 ) / 2.0 
  return p2    

def get_coords(pdb_file,r,a,ch): #pdb, residue, atom, chain 
  coords = {} 
  weight = {} 
  bfacts = {}
  sum_weight = 0.0
  fh_pdb = open(pdb_file)
  for line in fh_pdb:
    if "ATOM" == line[0:4]:
      res = int(line[22:26])
      atom = line[12:16].strip()
      chain = line[21:22].strip() 
      if chain == ch:
       if res == r:
        if atom == a:
         c = line[16:17]
         x = float(line[30:38]) #coord
         y = float(line[38:46]) #coord
         z = float(line[46:54]) #coord
         w = float(line[54:60])  #occupancy
         b = float(line[60:66]) #bfactors
         coords[c] = [x,y,z] #coords.append([x,y,z])
         weight[c] = w #weight.append(w)
         bfacts[c] = b #bfacts.append(b)
         sum_weight += w
  fh_pdb.close()
 
  if len(coords) == 0:
    print("  .. Warning: missing coodinates %i %s %s"%(r,a,pdb_file))
  coordslist = []
  weightlist = []
  bfactslist = []
  for c in sorted(coords):
    coordslist.append(coords[c])
    weightlist.append(weight[c])
    bfactslist.append(bfacts[c])
  if sum_weight != 1.0:
    for p in range(len(weightlist)):
      weightlist[p] = weightlist[p]/sum_weight
  #return coords,weight,bfacts
  return coordslist,weightlist,bfactslist

def calc_S2(pdb_file, data_mat, res):
  s2_calc = [] 		# final result
  s2_ang = []  		# s2 angular
  s2_ortho = [] 	# s2 ortho
  p2_mat = []           # p2
  prob_mat = []		# probabilities of each state
  struc_mat = []	# number of structures (states)
  b_mat = []		# B-factors
  for d in data_mat: #for everyline
    coord1, weight1, bfac1 = get_coords(pdb_file,d[0],d[1],d[6]) #pdb, residue, atom, chain
    coord2, weight2, bfac2 = get_coords(pdb_file,d[2],d[3],d[6]) #pdb, residue, atom, chain 
    # Check and correct some simple data consitencies
    if weight1 != weight2:
      #if ((len(weight1) >1) and (len(weight2) >1)):
      if ((len(weight1) >1.001) and (len(weight2) >1.001)) \
      and (abs(sum(weight1)-sum(weight2)) > 0.0001):
        print("  .. Warning: unequal weights",d[0],":",weight1,weight2)
      elif ((len(weight1) ==1) and (len(weight2) >1)):
        weight1 = weight2 
        for p in range(len(weight2)-1):
          coord1.append(coord1[0])
          bfac1.append(bfac1[0])
      elif ((len(weight2) ==1) and (len(weight1) >1)):
        weight2 = weight1 
        for p in range(len(weight1)-1):
          coord2.append(coord2[0])
          bfac2.append(bfac2[0])
    else:
      # this is the normal behaviour, i.e. same number and occupancy for states
      pass 

    # Start calculations
    struc = 0
    S2ang = 0.0 
    S2ortho = 1.0
    p = weight1 
    p2_list = []
    b_list = []
    for i in range(len(p)): #for every occupancy
      p2_row = []
      if model == "nh":
        # this is for riding motion between the Ca --- Ca axis and H
        # we assume that all motion is due to the 1D GAF and that it
        # is proportional to the distance from the axis.
        # bfac1 should be the proton bfactor
        S2ortho -= ((bfac1)/(8*pi*pi)) * p[i] #bfac1[i]
      elif model == "methyl":
        # this is for uncorrelated motion between the two points
        S2ortho -= ((((bfac1[i] + bfac2[i])/(8*pi*pi)) * p[i]) * b)/(res*10)
      b_list.append([bfac1,bfac2])
      struc+=1
      for j in range(len(weight1)): #for every occupancy
        P2 = calc_p2(coord1[i], coord2[i],coord1[j],coord2[j]) 
        S2ang += ( p[i] * p[j] * P2 )
        p2_row.append(P2)
      p2_list.append(p2_row)
    b_mat.append(b_list)
    p2_mat.append(p2_list) 

    prob_mat.append(p)
    s2_ortho.append(S2ortho)
    s2_ang.append(S2ang)

    s2_calc.append(S2ang*S2ortho)
    struc_mat.append(struc)
  return s2_calc,struc_mat,p2_mat,s2_ortho,s2_ang,prob_mat,b_mat 


def parse_input_data(data_file):
  data_mat = []
  s2_mat = []
  resi_array = []
  resn_array = []
  chain_array = []
  fh_data = open(data_file)
  for line in fh_data:
    if line[0] == "#":pass
    elif line.strip() =="":pass
    else:
      data = line.split()
      r1 = int(data[0])
      a1 = data[1]
      r2 = int(data[2])
      a2 = data[3]
      s2_expt = float(data[4])
      s2_expt_err = float(data[5])
      chain = data[6]
      chain_array.append(data[6])
      resn = data[7]
      resi = data[8]
      resn_array.append(data[7])
      resi_array.append(data[8])
      #print(resi)
      data_mat.append([r1, a1, r2, a2, s2_expt, s2_expt_err, chain, resn, resi])
      s2_mat.append(s2_expt)
  fh_data.close()
  #print(data_mat)
  return data_mat,s2_mat, resi_array, resn_array, chain_array



if __name__=="__main__":
  args = parse_args()
 
  data_file = args.data_file
  pdb_file = args.pdb
  data_out = args.file_out
  model = args.model
  if args.Resolution == None:
     resolution = 1
  else:
     resolution = args.Resolution
  if args.Bfactor == None:
     b = 1
  else:
     b = args.Bfactor 
  output_s2_ortho_and_ang = False
  #if len(argv) >= 6 and argv[5] in ["T", "1", "True", "true"]:
  #  output_s2_ortho_and_ang = True

  data_mat, s2_expt, resi, resn, chain = parse_input_data(data_file)
  
  s2_calc, struc_mat, p2_mat, s2_ortho, s2_ang, prob_mat, b_mat = calc_S2(pdb_file, data_mat, resolution) 

  output = pd.DataFrame(columns=['s2calc', 's2ortho', 's2ang', 'resn', 'resi', 'chain'])
 
  output['s2calc'] = s2_calc
  output['s2ortho'] = s2_ortho
  output['s2ang'] = s2_ang
  output['resn'] = resn
  output['resi'] = resi
  #print(output['resi'])
  output['chain'] = chain
  #print(output.head())
  output.to_csv(data_out, index=False)

