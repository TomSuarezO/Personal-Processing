# -*- coding: utf-8 -*-
"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
experimentName = r"ctetSLC067_1L_210223"
rawDataServer = r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Tommy"
saveServer = r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\DayNightProject"

use_custom_ops = True # Logical for default options
opsFile = r"C:\Users\Opti9020_5\Documents\Tommy's Stuff\Personal-Processing\Ps2p Ops Files\secondComparisonOps_210630.npy" # Place full path and file name to options file
save_path = saveServer + '\\' + experimentName + r"_procPS2P"
data_path = rawDataServer + experimentName


#------------------------------ DO NOT Edit Below this Line ------------------------------#


# Import Numpy for reading npy files and more
import numpy as np
# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops

# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0 = np.load(opsFile , allow_pickle=True)
    ops = ops0.tolist()
    ops["save_folder"] = save_path
else:
    ops = default_ops()

# Create Database
db = {
      'look_one_level_down': False, # whether to look in ALL subfolders when searching for tiffs
      'data_path': data_path, # a list of folders with tiffs
      #'tiff_list': ['suite2p_1_ctetSLC077_NC_210510_2P_plane1_1.tif']
    }

opsEnd = run_s2p(ops=ops, db=db)