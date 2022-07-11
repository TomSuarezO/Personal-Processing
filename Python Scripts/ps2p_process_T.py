"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
#mouseID = r"WT108"
#expDate = r"033022"
experimentName = r"Tlx3_PL56_46\062322"
#experimentName = mouseID + "\\" expDate
rawDataServer = r"W:\Data\Arousal_Project\IT\2P" # server path for raw data - just before session ID folder
saveServer = r"W:\Data\Arousal_Project\IT\2P" # path where new folder will be created
print('\nExperiment ID: ' + experimentName + '\nSaved in server:' + saveServer + '\n')

use_custom_ops = True # Logical for default or custom options - Use True for options from file on next line
#opsFile = r"C:\Users\Williamson_Lab\Documents\Tommy\Ps2p Ops Files\WilliamsonLabMainOps_220601.npy" # Place full path and file name to options file - has to be in local drive
opsFile = r"W:\Data\Arousal_Project\Suite2P_1x_settings.npy" # Keith's parameters for suite2p

#------------------------------ DO NOT Edit Below this Line ------------------------------#
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
    ops0 = np.load(opsFile , allow_pickle=True)
    ops = ops0.tolist()
    ops["tau"] = 1.0
    #ops["spatial_hp_reg"] = 42
    #ops["nplanes"] = 1
    #ops["do_bidphase"] = 1
    ops["nchannels"] = 1
    ops["save_folder"] = save_path
    ops['input_format'] = 'tif'
    print('Custom Ops Loaded')
else:
    ops = default_ops()
    print('Default Ops Loaded')

# Create Database
db = {
      'look_one_level_down': True, # whether to look in ALL subfolders when searching for tiffs
      'data_path': [data_path], # a list of folders with tiffs
      'fast_disk': r"C:\Users\Williamson_Lab\Documents\Tommy\Ps2p Fast Disk"
      #'tiff_list': ['suite2p_1_ctetSLC077_NC_210510_2P_plane1_1.tif']
    }

print('############################## Beginning of Suite2p Processing ##############################')
opsEnd = run_s2p(ops=ops, db=db)
print('############################## End of Suite2p Processing ##############################')

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
plt.savefig(save_path + '\\' + 'MotionDiagnosis')


# Send Slack message upon completion
import json
import sys
import random
import requests
if __name__ == '__main__':
    url = "https://hooks.slack.com/services/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"
    message = ("Experiment "' + experimentName + '" ran successfully'")
    #title = (f"New Incoming Message :zap:")
    slack_data = {
        "username": "Suite2p",
        "icon_emoji": ":1234:",
        #"channel" : "#somerandomcahnnel",
        "attachments": [
            {
                "color": "#9733EE",
                "fields": [
                    {
                        #"title": title,
                        "value": message,
                        "short": "false",
                    }
                ]
            }
        ]
    }
    byte_length = str(sys.getsizeof(slack_data))
    headers = {'Content-Type': "application/json", 'Content-Length': byte_length}
    response = requests.post(url, data=json.dumps(slack_data), headers=headers)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
