"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
# Place each experiment ID and the server folder for each of them
expID = [r"WT322\041423",
         r"WT322\041523",
        ]
rawDataServer = [r"W:\Data\Mask_ND\Nonspecific\2P",
                 r"W:\Data\Mask_ND\Nonspecific\2P",
                ]
saveServer = r"W:\Data\Mask_ND\Nonspecific\2P" # path where new folder will be created
numberOfplanes = 1

use_custom_ops = True # Logical for default options
opsFile = r"W:\Data\Arousal_Project\Suite2P_1x_settings.npy" # Place full path and file name to options file - has to be in local drive


#------------------------------ DO NOT Edit Below this Line ------------------------------#
#---------------------------(unless you know what you are doing)--------------------------#


# Import Numpy for reading npy files and more
import numpy as np
# Import Suite2p commands and options. Run the package with run_s2p function
from suite2p import run_s2p, default_ops

# Choose default or custom ops base on input parameter use_custom_ops
if use_custom_ops:
    ops0    = np.load(opsFile , allow_pickle=True)
    ops     = ops0.tolist()
    ops["tau"]              = 1.00
    ops["fs"]               = 30
    ops["nplanes"]          = 1
    ops["move_bin"]         = 1
    ops["nchannels"]        = 1
    ops["allow_overlap"]    = True
    ops["do_registration"]  = 1
    ops['input_format']     = 'tif'
    print('Custom Ops Loaded')
else:
    ops = default_ops()
    print('Default Ops Loaded')


# Iterate through Database
for ii in range(len(expID)):
    data_path = rawDataServer[ii] + '\\' + expID[ii]
    save_path = saveServer + '\\' + expID[ii] + r"_procPS2P"
    ops["save_folder"] = save_path # Save custom savepath for each session in the batch
    db = {
          'look_one_level_down': True, # whether to look in ALL subfolders when searching for tiffs
          'data_path': [data_path], # a list of folders with tiffs
          'fast_disk': r"C:\Users\Williamson_Lab\Documents\Tommy\Ps2p Fast Disk"
        }
    print('\nExperiment ID: ' + expID[ii] + '\n Saved in folder:' + save_path + '\n')
    opsEnd = run_s2p(ops=ops, db=db)

    # Plotting of motion correction diagnosis
    # This plot in batch gets anomalies in some cases. Need further revision
    newOps = None
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
    plt.savefig(save_path + '\\MotionDiagnosis.png')


    # Send Slack for each iteration
    fPath   = r"C:\Users\Williamson_Lab\slackContactFile.txt"
    mssg    = ("Experiment " + expID[ii] + " ran successfully | " + str(ii+1) + " of " + str(len(expID)))
    iconURL = "https://raw.githubusercontent.com/MouseLand/suite2p/main/suite2p/logo/logo_unshaded.png"
    from sendSlackMssg import sendMssg
    sendMssg(fPath,mssg,iconURL)



# Send Slack for each iteration
fPath   = r"C:\Users\Williamson_Lab\slackContactFile.txt"
mssg    = ("Batch experiment ran successfully")
iconURL = "https://raw.githubusercontent.com/MouseLand/suite2p/main/suite2p/logo/logo_unshaded.png"
from sendSlackMssg import sendMssg
sendMssg(fPath,mssg,iconURL)