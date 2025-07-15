%% Documentation
% Make a csv file with all the appropriate fields for using the SharePoint
% Migration Tool (SPMT).
% How it works: Select a folder and choose the main parameters. A csv file
% will be created with the necessary fields for migrating files


%% Main Folder
% List the main folders here. There can be more than one, the intended use
% is a list of the three main subfolders for each folder.
rootPath    = "W:\Data\Mask_ND\IT\";
mainFolders = ["W:\Data\Mask_ND\IT\2P";
    "W:\Data\Mask_ND\IT\Impale";
    "W:\Data\Mask_ND\IT\Widefield"];

sharePointURL = "https://pitt.sharepoint.com/sites/MaskND-Nonspecific";

csvFileName = "NonspecificMigration.csv";


%% Find and format source paths
allSearch   = arrayfun(@dir, mainFolders,'UniformOutput',false);
allStruct   = vertcat(allSearch{:});
parentFlag  = contains(string({allStruct.name})',[".",".."]);
allStruct(parentFlag) = [];

Source = string(arrayfun(@(x) fullfile(x.folder,x.name), allStruct, 'UniformOutput', false));
nJobs = size(Source,1);


%% Make TargetSubFolder field
TargetSubFolder = strrep({allStruct.folder}', rootPath, '');


%% SharePoint Directory
SourceDocLib    = repelem("",nJobs,1);
SourceSubFolder = repelem("",nJobs,1);
TargetWeb       = repelem(sharePointURL,nJobs,1);
TargetDocLib    = repelem("Documents",nJobs,1);
RegAsHubSite    = repelem("",nJobs,1);
HubURL          = repelem("",nJobs,1);


%% Make the table for csv
columnNames = ["Source";
    "Source DobLib";
    "Source SubFolder";
    "Target Web";
    "Target DocLib";
    "Target SubFolder";
    "RegisterAsHubSite";
    "AssociateWithHubURL"];
% csvTable    = cell2table(cell(0, numel(columnNames)), 'VariableNames', cellstr(columnNames));

csvTable = table(Source,SourceDocLib,SourceSubFolder,TargetWeb,TargetDocLib,TargetSubFolder,RegAsHubSite,HubURL);


%% Save csv file
csvFile = fullfile(rootPath,csvFileName);
writetable(csvTable,csvFile,'WriteVariableNames',false);