# -*- coding: utf-8 -*-
"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
data_path = [r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\DayNightProject\ctetSLC067_1L_210302_processed_suite2p\AlignedTiff"]
use_custom_ops = True # Logical for default options
filename = r"C:\Users\Opti9020_5\Documents\Tommy's Stuff\Suite2p Tests\Local Test Run\baseOpsTommy.npy" # Place full path and name to options file



# Import libraries. Numpy is for reading npy files (for now) and sys to add data path to Python
import numpy as np
import sys
sys.path.insert(0, r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\DayNightProject\ctetSLC067_1L_210302_processed_suite2p\AlignedTiff")

# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops
# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0 = np.load(filename , allow_pickle=True)
    ops = ops0.tolist()
else:
    ops = default_ops()

# Create Database
db = {
      'look_one_level_down': False, # whether to look in ALL subfolders when searching for tiffs
      'data_path': data_path, # a list of folders with tiffs
      #'tiff_list': ['suite2p_1_ctetSLC077_NC_210510_2P_plane1_1.tif']
    }

opsEnd = run_s2p(ops=ops, db=db)