function createFcell(suite2pDataPath , saveName)
% Create Fcell mat file - all variables with file-by-file data
% saveName is the name of the first ".mat" from ps2p - usually Fall.mat
load(fullfile(suite2pDataPath,saveName) , 'F' , 'Fneu' , 'spks' , 'ops');
frameIndex = cumsum([0 , ops.nframes_per_folder]);

Fcell = cell(1,numel(ops.nframes_per_folder));
FcellNeu = cell(1,numel(ops.nframes_per_folder));
Fspks = cell(1,numel(ops.nframes_per_folder));

for k = 1:length(frameIndex)-1
    frameInterval = frameIndex(k)+1 : frameIndex(k+1);
    Fcell{k} = F(: , frameInterval);
    FcellNeu{k} = Fneu(: , frameInterval);
    Fspks{k} = spks(: , frameInterval);
end

savename = fullfile(suite2pDataPath,'Fall_out.mat');
if ~isfile(savename)
    save(savename , 'Fcell' , 'FcellNeu' , 'Fspks');
else
    save(savename , 'Fcell' , 'FcellNeu' , 'Fspks' , '-append');
end