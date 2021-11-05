"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
experimentName = r"slc096_NC_210901"
rawDataServer = r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Tommy" # server path for raw data - just before session ID folder
saveServer = r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\Bilayer Imaging" # path where new folder will be created
numberOfplanes = 1
print('\nExperiment ID: ' + experimentName + '\n Saved in folder:' + saveServer + '\n')

use_custom_ops = True # Logical for default or custom options - Use True for options from file on next line
opsFile = r"C:\Users\kuhlmanlab\Documents\PS2P Files\Ps2p Ops Files\KLabMainOps_211103.npy" # Place full path and file name to options file - has to be in local drive


#------------------------------ DO NOT Edit Below this Line ------------------------------#
#---------------------------(unless you know what you are doing)--------------------------#


save_path = saveServer + '\\' + experimentName + r"_procPS2P"
data_path = rawDataServer + '\\' + experimentName

# Import Numpy for reading npy files and more
import numpy as np
# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops

# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0 = np.load(opsFile , allow_pickle=True)
    ops = ops0.tolist()
    ops["save_folder"] = save_path
    ops["nplanes"] = numberOfPlanes
    ops['input_format'] = 'sbx'
    # For future releases, sbx deadcolumns and deadrows might be improved
    #ops['sbx_list'] = ['slc097_1L_210806_000_004.sbx','slc097_1L_210806_000_005.sbx','slc097_1L_210806_000_006.sbx']
    #ops['sbx_ndeadcols'] = 100
    #ops['sbx_ndeadrows'] = 32
    print('Custom Ops Loaded')
else:
    ops = default_ops()
    print('Default Ops Loaded')

# Create Database
db = {
      'look_one_level_down': False, # whether to look in ALL subfolders when searching for tiffs
      'data_path': [data_path], # a list of folders with tiffs
      #'tiff_list': ['suite2p_1_ctetSLC077_NC_210510_2P_plane1_1.tif']
    }

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
plt.savefig(save_path + '\\' + experimentName + '_MotionDiagnosis')
