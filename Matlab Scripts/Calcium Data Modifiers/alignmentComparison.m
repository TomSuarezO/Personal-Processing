%% Documentation
% This script checks if the order of movies in a suite2p processed binary
% file is the same as in the original aligned tiffs. Code by Tomas Suarez

%% Input Parameters
% use full path and filenames
firstTiff = '\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\DayNightProject\ctetSLC067_1L_210302_processed_suite2p\AlignedTiff\suite2p_1_ctetSLC067_1L_210302_2P_plane1_1.tif';
alignedBin = '\\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy\DayNightProject\ctetSLC067_1L_210302_processed_suite2p\suite2p\plane0\data.bin';

%% Read Tiff file
stackInfo = imfinfo(firstTiff);
tiffStack = zeros([stackInfo(1).Height , stackInfo(1).Width , length(stackInfo)]);
for n = 1:length(stackInfo)
    tiffStack(:,:,n) = (imread(firstTiff,n));
end
tiffStack = cast(tiffStack,'uint16');
fprintf('Tiff File Read\n');

%% Read equivalent in binary file
fid = fopen(alignedBin);
readSize = stackInfo(1).Height * stackInfo(1).Width * length(stackInfo);
binStack = fread(fid , [1,readSize] , 'uint16');

fclose(fid);
binStack = uint16(reshape(binStack , stackInfo(1).Height , stackInfo(1).Width , length(stackInfo)));

%% Compare Movies
equalResult = isequal(tiffStack,binStack);
fprintf('The Movies are equal: %s\n' , mat2str(equalResult));