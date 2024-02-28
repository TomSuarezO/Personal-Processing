"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
#mouseID = r"WT108"
#expDate = r"033022"  
experimentName = r"WT499\020724"
#experimentName = mouseID + "\\" expDate
rawDataServer = r"W:\Data\Mask_ND\Nonspecific\2P" # server path for raw data - just before session ID folder
saveServer = r"W:\Data\Mask_ND\Nonspecific\2P" # path where new folder will be created
print('\nExperiment ID: ' + experimentName + '\nSaved in server:' + saveServer + '\n')

use_custom_ops = True # Logical for default or custom options - Use True for options from file on next line
#opsFile = r"C:\Users\Williamson_Lab\Documents\Tommy\Ps2p Ops Files\WilliamsonLabMainOps_220601.npy" # Place full path and file name to options file - has to be in local drive
opsFile = r"W:\Data\Arousal_Project\Suite2P_1x_settings.npy" # Keith's parameters for suite2p


#------------------------------ DO NOT edit below this Line ------------------------------#
#---------------------------(unless you know what you are doing)--------------------------#

data_path = rawDataServer + '\\' + experimentName
#save_path = data_path + mouseID + expDate + r"_procPS2P"
save_path = saveServer + '\\' + experimentName + r"_procPS2P"

print('\nSave Path: ' + save_path + '\nData Path: ' + data_path + '\n')


# Import Numpy for reading npy files and more
import numpy as np
# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops

# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0    = np.load(opsFile , allow_pickle=True)
    ops     = ops0.tolist()
    ops["tau"]              = 0.7
    ops["fs"]               = 30
    ops["nplanes"]          = 1
    ops["move_bin"]         = 1
    ops["nchannels"]        = 1
    ops["do_registration"]  = 1
    ops["anatomical_only"]  = 0
    ops["diameter"]         = 12
    ops["threshold_scaling"] = 1.2
    ops["save_folder"]      = save_path
    ops['input_format']     = 'tif'
    print('Custom Ops Loaded')
    # ops['ignore_flyback'] = np.arange(4,48234,5 )
    #ops["do_bidphase"] = 1
else:
    ops = default_ops()
    print('Default Ops Loaded')

# Create Database
db = {
      'look_one_level_down': True, # whether to look in ALL subfolders when searching for tiffs
      'data_path': [data_path], # a list of folders with tiffs
      'fast_disk': r"D:\S2P Fast Disk"
      #'tiff_list': ['suite2p_1_ctetSLC077_NC_210510_2P_plane1_1.tif']
    }

print('############################## Beginning of Suite2p Processing ##############################')
opsEnd = run_s2p(ops=ops, db=db)
print('############################## End of Suite2p Processing ##############################')


# Make diagnostic motion correction figure
newOps = opsEnd
import matplotlib.pyplot as plt
plt.plot(newOps['xoff'])
plt.plot(newOps['yoff'])
plt.xlabel('Frames')
plt.ylabel('Correction (pixels)')
plt.legend({'X Shift','Y Shift'})
plt.grid()
plt.suptitle('Registration Motion')
maxX = round(newOps['Lx']*newOps['maxregshift'])
maxY = round(newOps['Ly']*newOps['maxregshift'])
titlestr = 'Max Allowed X Shift = '+str(maxX) +'  |  '+'Max Allowed Y Shift = '+str(maxY)
plt.title(titlestr)
plt.savefig(save_path + '\\' + 'MotionDiagnosis')




# Send Slack message upon completion
fPath   = r"C:\Users\Williamson_Lab\slackContactFile.txt"
mssg    = ("Experiment " + experimentName + " ran successfully")
iconURL = "https://raw.githubusercontent.com/MouseLand/suite2p/main/suite2p/logo/logo_unshaded.png"
from sendSlackMssg import sendMssg
sendMssg(fPath,mssg,iconURL)