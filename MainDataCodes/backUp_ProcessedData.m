%% Documentation
% This code is meant to backup output files from calcium imaging
% experiments in the Williamson lab. These include Suite2p output Fall.mat,
% Mouse-Track output initial_analysis, matching data output.

% The routine will start with a list with data (.csv or .xlsx), find all
% files within the path found there and copy to a new path.


%% Main data file

dataFile    = "W:\Data\Mask_ND\Mask_ND_CellTypes.xlsx";
newPath     = 'D:\Data\Mask_ND\';
% dataFile    = "W:\Data\Mask_ND\Mask_ND_Files.csv";
typeDict    = [".csv",".xlsx"];
[~,~,fExt]  = fileparts(dataFile);
fileFlag    = isfile(dataFile);
typeFlag    = find(strcmp(fExt,typeDict)); % 1 for csv, 2 for xlsx


%% Load all pages from data file

loadOpts = struct();
if typeFlag == 1
    nSheets = 1;
elseif typeFlag == 2
    sheets  = sheetnames(dataFile);
    nSheets = numel(sheets);
    [loadOpts(1:nSheets).Sheet] = deal(sheets{:});
end
[loadOpts.VariableNamingRule]   = deal('modify');
[loadOpts.TextType]             = deal('string');
[loadOpts.TreatAsMissing]       = deal('');

csvCell     = cell(nSheets,1);
allNames    = fieldnames(loadOpts)';
allArgs     = squeeze(struct2cell(loadOpts))';
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
for ii = 1:nSheets
    cArgs       = [allNames;allArgs(ii,:)];
    csvCell{ii} = readtable(dataFile,cArgs{:});
end
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
data_csv = cat(1,csvCell{:});


%% Make paths
[imaging_dir,impale_dir,tosca_dir,camera_dir,matching_dir,mat_dir]  = utils.parseExperiment(data_csv);
rootPath = unique(data_csv(:,:).MainPath);
if numel(rootPath) > 1
    error('Main Path is not unique. Modify the spreadsheet or this code to allow multiple paths')
end


%% Scan for already-copied files
% files to copy to new location:
    % Fall.mat
    % initial_analysis.mat
    % matching files
    % impale output

nExp        = size(data_csv,1);
newImaging  = strcat(imaging_dir,filesep,'**',filesep,'Fall.mat');
newImpale   = impale_dir;
newMouseT   = strcat(mat_dir,filesep,'initial_analysis.mat');
newMatch    = strcat(matching_dir,filesep,'**',filesep,'*ROICaT.mat');

toSearch    = [newImaging,newImpale,newMouseT,newMatch];
allFiles    = utils.searchFiles(toSearch);
newFiles    = strrep(allFiles,rootPath,newPath);
nFiles      = numel(allFiles);
equalFlag   = false(nFiles,1);

fprintf('Beginning scan: %i files in %i sessions\n',nFiles,nExp)
for ii = 1:nFiles
    % cSearch     = toSearch(ii,:)';
    % cFiles      = utils.searchFiles(cSearch);
    % newFiles    = strrep(cFiles,data_csv(ii,:).MainPath,newPath);
    cFlag           = utils.fileBitCompare(allFiles(ii),newFiles(ii));
    equalFlag(ii)   = cFlag;
    if rem(ii,50) == 0
        fprintf('\t%i files scanned\n',ii)
    end
end
fprintf('\t%i files scanned\n',ii)
fprintf('\t%i new files to be copied in root folder %s\n\n',sum(~equalFlag),newPath)


%% Copy to new path
all2Copy    = allFiles(~equalFlag);
new2Copy    = newFiles(~equalFlag);
n2Copy      = sum(~equalFlag);

fprintf('Beginning copy: %i files to be copied\n',n2Copy)
for ii = 1:n2Copy

    % make new folder
    [cPath,~,~] = fileparts(new2Copy(ii));
    if ~isfolder(cPath)
        mkdir(cPath)
    end

    % copy file
    copyfile(all2Copy(ii),new2Copy(ii))

    % print progress
    if rem(ii,10) == 0
        fprintf('\tFile %d/%d copied\n',ii,n2Copy)
    end
end
fprintf('\tFile %d/%d copied\n',ii,n2Copy)
fprintf('\t%i files copied in root folder %s\n\n',n2Copy,newPath)


%% Make new data sheet
[~,csvName,csvExt] = fileparts(dataFile);
newDataFile = strcat(newPath,csvName,csvExt);

writeOpts = struct();
if typeFlag == 1
    nSheets = 1;
elseif typeFlag == 2
    sheets  = sheetnames(dataFile);
    nSheets = numel(sheets);
    [writeOpts(1:nSheets).Sheet] = deal(sheets{:});
end
% [writeOpts.VariableNamingRule]   = deal('modify');
% [writeOpts.TextType]             = deal('string');
% [writeOpts.TreatAsMissing]       = deal('');

allNames    = fieldnames(writeOpts)';
allArgs     = squeeze(struct2cell(writeOpts));
for ii = 1:nSheets
    cArgs               = [allNames;allArgs(ii,:)];
    newCsv              = csvCell{ii};
    if isempty(newCsv)
        continue
    end
    newCsv.MainPath(:)  = newPath;
    writetable(newCsv,newDataFile,cArgs{:});
end
fprintf('New data sheet saved %s\n\n',newDataFile)