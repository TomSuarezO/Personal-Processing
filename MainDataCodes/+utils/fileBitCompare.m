function sameFile = fileBitCompare(file1,file2)
%% Documentation
% compare two files bit-wise to find if they are equal. Faster alternative
% to visdiff. This function does not need to load both files into memory


%% Main checks
% check if the files exists and if they have the same size
if ~isfile(file1) || ~isfile(file2)
    sameFile = false;
    return
end

info1 = dir(file1);
info2 = dir(file2);
if info1.bytes ~= info2.bytes
    sameFile = false;
    return
end


%% Open files in binary mode
fid1 = fopen(file1, 'rb');
fid2 = fopen(file2, 'rb');
if fid1 < 0 || fid2 < 0
    error('Cannot open one or both files.');
end


%% Compare files chunk-wise
blockSize   = 1e6; % size of chunk
sameFile    = true;
while ~feof(fid1) && ~feof(fid2)
    block1 = fread(fid1, blockSize, '*uint8');
    block2 = fread(fid2, blockSize, '*uint8');
    if ~isequal(block1, block2)
        sameFile = false;
        break
    end
end

fclose(fid1);
fclose(fid2);