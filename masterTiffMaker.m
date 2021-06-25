%% Documentation
%     Master Tiff Maker takes a binary file of an imaging session and
%     divides it into smaller-sized tiff files
%     
%     Metadata needed:
%         1) Height & Width of movie
%         2) Number of frames each tiff file will have. The vector
%         containing this information is "framesInTiff"
%         3) 
%     Modify "Read Metadata" section to match your data structure
%
%     Contact Tomas Suarez for more information about the code -
%     tsuarezo@andrew.cmu.edu

%% Startup
clearvars; close all;
myPath = 'C:\Users\tomsu\Documents\Codes\Python Scripts\Practice Python\Sample Tiff Data'; %path to binary file
filename = 'suite2p_1_ctetSLC067_1L_210223_2P_plane1_2'; %name of binary file without extension
csvname = ['suite2p_1_ctetSLC067_1L_210223_2P_plane1_2.tif_info' , '.csv'];
filepath = fullfile(myPath,[filename,'.bin']);
savepath = ['C:\Users\tomsu\Documents\CMU Research\Codes General','\sample Master Tiffs']; %path to save smaller tiffs

if ~isfolder(savepath) %Create folder for saving tiffs
    mkdir(savepath);
end

if ~isfile(filepath) %Checking for binary file
    error('No file found on path. Please insert full path to file');
end

%% Read Metadata
[~ , ~ , width , height , nFrames , ...
    bitDepth , colorType] = readvars(fullfile(myPath,csvname));
framesInTiff = [100,100,100,99,100,100,98,102,100,100]; %# of frames for each tiff

%% Read and Segment Binary File
fileID_Read = fopen(filepath);  %file ID for reading
% framesPerTiff = 111;
fseek(fileID_Read,0,'eof'); %Move to the end of file to find max bytes
maxBytes = ftell(fileID_Read); %total number of bytes in bin file
totalFrames = maxBytes/(width*height*2);
if totalFrames ~= sum(framesInTiff)
    error('Total number of frames and size of binary file do not match');
end

for k = 0:numel(framesInTiff)-1
    fseek(fileID_Read , (width*height*2)*sum(framesInTiff(1:k)) , 'bof');
    currentStack = uint16(fread(fileID_Read,...
        [1,height*width*framesInTiff(k+1)],'uint16'));
    currentStack = reshape(currentStack,height,width,framesInTiff(k+1));
    saveName = fullfile(savepath,[filename,sprintf('_Master_%i.tif',k)]);
    
    for n = 1:framesInTiff(k+1)
        if n == 1
            imwrite(currentStack(:,:,n) , saveName);
        else
            imwrite(currentStack(:,:,n) , saveName , 'writeMode','append')
        end
    end
    currentBytes = ftell(fileID_Read);
    fprintf('Saved %i Files of %i Frames | %i Bytes Read\n' ,...
        k+1 , framesInTiff(k+1) , currentBytes);
end

fclose(fileID_Read);

