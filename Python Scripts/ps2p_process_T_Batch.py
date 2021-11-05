"""
Created on Thu Jun 24 11:46:14 2021

@author: Tomas Suarez Omedas
"""

# User-input parameters
# Place each experiment ID and the server folder for each of them
expID = [r"ctetSLC024_NC_200803",
         r"ctetSLC024_NC_200901",
         r"ctetSLC025_1R_200804",
         r"ctetSLC025_1R_200902",
         r"ctetSLC026_NC_200807",
         r"ctetSLC026_NC_200904",
         r"ctetSLC032_1L_200913",
         r"ctetSLC032_1L_201012",
         r"ctetSLC038_1R_200922",
         r"ctetSLC038_1R_201019",
         r"ctetSLC056_1R_210118",
         r"ctetSLC056_1R_210217",
         r"ctetSLC038_1R1L_200923",
         r"ctetSLC038_1R1L_201020",
        ]
rawDataServer = [r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                 r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\RawCaDataArchive\Jack",
                ]
saveServer = r"\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Jack" # path where new folder will be created
numberOfplanes = 1

use_custom_ops = True # Logical for default options
opsFile = r"C:\Users\kuhlmanlab\Documents\PS2P Files\Ps2p Ops Files\KLabMainOps_211103.npy" # Place full path and file name to options file - has to be in local drive


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
    ops["nplanes"] = numberOfplanes
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

    # Plotting of motion correction diagnosis
    # This plot in batch gets anomalies in some cases. Need further revision
    a = None
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
