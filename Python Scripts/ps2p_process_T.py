"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
experimentName = r"bp200\20200207\pass\TSeries-02072020-1043-2417"
rawDataServer = r"Z:\Christine\pvtdtomato" # server path for raw data - just before session ID folder
saveServer = r"Z:\Tommy\Processed Data" # path where new folder will be created
print('\nExperiment ID: ' + experimentName + '\nSaved in server:' + saveServer + '\n')

use_custom_ops = True # Logical for default or custom options - Use True for options from file on next line
opsFile = r"C:\Runyan Lab Codes and Data\Projects\Tommy-Personal-Processing\Ps2p Ops Files\RunyanLabMainOps_211130.npy" # Place full path and file name to options file - has to be in local drive

#------------------------------ DO NOT Edit Below this Line ------------------------------#
#---------------------------(unless you know what you are doing)--------------------------#


save_path = saveServer + '\\' + experimentName + r"_procPS2P"
data_path = rawDataServer + '\\' + experimentName

print('\nSave Path: ' + save_path + '\nData Path:' + data_path + '\n')


# Import Numpy for reading npy files and more
import numpy as np
# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops

# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0 = np.load(opsFile , allow_pickle=True)
    ops = ops0.tolist()
    ops["save_folder"] = save_path
    ops['input_format'] = 'bruker'
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
