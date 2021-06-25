%% Startup
clearvars; close all;
myPath = "C:\Users\Opti9020_5\Documents\Tommy's Stuff\Local Test Run\Trial DayNight";
addpath(genpath(myPath));
filename = ['suite2p_1_ctetSLC067_1L_210223_2P_plane1_1' , '.tif']; %name of video
filepath = fullfile(myPath,filename);
savename = ['suite2p_1_ctetSLC067_1L_210223_2P_plane1_1','.bin'];

if ~isfile(filepath)
    error('No file found on path. Please insert full path to file');
end

%% Read Video
info = imfinfo(filepath);
Frames = zeros(info(1).Height , info(1).Width , length(info));
for n = 1:length(info)
    Frames(:,:,n) = imread(filename,n);
end

if ~isa(Frames , 'uint8') && ~isa(Frames , 'uint16')
    Frames = cast(Frames,['uint',num2str(info(1).BitDepth)]);
end

%% Save to Bin
fileID_Write = fopen(savename,'w');
fwrite(fileID_Write , Frames,'uint16');
fclose(fileID_Write);

%% Save Additional Data
atributes.Name = filename;
atributes.OriginalPath = myPath;
atributes.Width = info(1).Width;
atributes.Height = info(1).Height;
atributes.N_Frames = length(info);
atributes.BitDepth = info.BitDepth;
atributes.ColorType = info.ColorType;
T = struct2table(atributes);
writetable(T , [filename,'_info.csv']);