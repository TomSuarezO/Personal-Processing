%% Startup
clearvars; close all;
myPath = "\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\DayNightProject\ctetSLC067_1L_210223_processed_suite2p";
addpath(genpath(myPath));
filename = ['ctetSLC067_1L_210223_suite2p_plane1' , '.bin']; %name of video
metadataFile = ['suite2p_1_ctetSLC067_1L_210223_2P_plane1_1.tif_info' , '.csv']; %name of csv file with metadata
filepath = fullfile(myPath,filename);
savename = ['Large_ctetSLC067_1L_210223_suite2p_plane1','.h5'];

if ~isfile(filepath)
    error('No file found on path. Please insert full path to file');
end

%% Read Supplemental Data
% [oldName , originalPath , width , height , nFrames , bitDepth , colorType] = ...
%     readvars(metadataFile);
width = 681;
height = 505;
nFrmaes = [];
bitDepth = 16;

%% Load and Reshape Bin Data
fileID_Read = fopen(filepath);
binData = fread(fileID_Read,['uint',num2str(bitDepth)]);
fclose(fileID_Read);

binData = cast(binData,['uint',num2str(bitDepth)]);
newImage = reshape(binData , [height width nFrames]);

%% Save as H5 File
h5create(savename,...
    '/g2/DS2'...
    ,size(newImage));
    
h5write(savename,...
    '/g2/DS2',...
    newImage);

