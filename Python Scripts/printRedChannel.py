import os
import numpy as np
import matplotlib.pyplot as plt

baseDir = r'W:\Data\Mask_ND\IT_ET\2P\Tlx099\032423\1-2-RLF\1-2-RLF_procPS2P'
opsPaths = []

for root, dirs, files in os.walk(baseDir):
    for name in files:
        if name.endswith(("ops.npy")):
            pInd = root.find('plane')
            currentPlane = pInd+5
            if pInd > 0:
                # opsPaths[currentPlane] = root
                opsPaths.append(root + '\\' + 'ops.npy')


for ii in range(len(opsPaths)):
    currentOps = np.load(opsPaths[ii],allow_pickle=True)

ops = currentOps.tolist()

plt.imshow(ops['meanImg_ch2'])