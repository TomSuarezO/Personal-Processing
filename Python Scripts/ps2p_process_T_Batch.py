# -*- coding: utf-8 -*-
"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
# User-input parameters
expID = [r"slc096_NC_210606",
         r"slc096_NC_210611",
         r"slc096_1R_210620",
         r"slc096_1R_210628_task",
         r"slc096_1L_210623_task",
         r"slc096_1L_210630_task",
        ]
rawDataServer = [r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Brian\slc096_NC",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Brian\slc096_NC",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Brian\slc096_1R",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Brian\slc096_1R",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Brian\slc096_1L",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Brian\slc096_1L",
                ]
saveServer = r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Brian\closed_loop_grating_discrimination\python_suite2p_processed"

use_custom_ops = True # Logical for default options
opsFile = r"C:\Users\kuhlmanlab\Documents\Tommy's Stuff\Personal-Processing\Ps2p Ops Files\secondComparisonOps_210630.npy" # Place full path and file name to options file


#------------------------------ DO NOT Edit Below this Line ------------------------------#
#---------------------------(unless you know what you are doing)--------------------------#


# Import Numpy for reading npy files and more
import numpy as np
# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops

# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0 = np.load(opsFile , allow_pickle=True)
    ops = ops0.tolist()
    ops['input_format'] = 'sbx'
    ops['delete_bin'] = False
#    ops['keep_movie_raw'] = True
    ops['maxregshift'] = 0.1
    print('Custom Ops Loaded')
else:
    ops = default_ops()

# Iterate through Database
for ii in range(len(expID)):
    data_path = rawDataServer[ii] + '\\' + expID[ii]
    save_path = saveServer + '\\' + expID[ii] + r"_procPS2P"
    db = {
          'look_one_level_down': False, # whether to look in ALL subfolders when searching for tiffs
          'data_path': [data_path], # a list of folders with tiffs
        }
    ops["save_folder"] = save_path # Save custom savepath for each session in the batch
    print('\nExperiment ID: ' + expID[ii] + '\n Saved in folder:' + saveServer + '\n')
    opsEnd = run_s2p(ops=ops, db=db)

    a = opsEnd
    import matplotlib.pyplot as plt
    plt.plot(a['xoff'])
    plt.plot(a['yoff'])
    plt.xlabel('Frames')
    plt.ylabel('Correction (pixels)')
    plt.legend({'X Shift','Y Shift'})
    plt.grid()
    plt.suptitle('Registration Motion')
    maxX = round(a['Lx']*a['maxregshift'])
    maxY = round(a['Ly']*a['maxregshift'])
    titlestr = 'Max Allowed X Shift = '+str(maxX) +'  |  '+'Max Allowed Y Shift = '+str(maxY)
    plt.title(titlestr)
    plt.savefig(save_path + '\\' + expID[ii] + '_MotionDiagnosis')
