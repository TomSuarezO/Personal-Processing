function sessionFolder = findExpFolder(baseFolder , expID)
% sessionFolder = findExpFolder(baseFolder , expID)
% 07/19/21 Tomas Suarez Omedas - This function uses the base folder for a
% researcher (example
% \\mousehive.ni.cmu.edu\kuhlmanlab\data1\ProcessedDataArchive\Tommy) and
% an experiment ID (example slc090_1L_210517) and will find the base data
% folder for that session. If more than one option exists then it will
% display a menu with the options

searchResult = dir([baseFolder,filesep,'**',filesep,expID,'*',filesep]);
searchList = strings(sum([searchResult.isdir]),1);
dirResult = 1;
for n = 1:length(searchResult)
    if searchResult(n).isdir
        searchList(dirResult) = string([searchResult(n).folder]);
        dirResult = dirResult + 1;
    end
end
searchList = unique(searchList);
deleteIndex = false(length(searchList),1);
for k = 1:length(searchList)
    uniqueFlag = contains(searchList,searchList(k));
    if sum(any(uniqueFlag))
        uniqueFlag(k) = false;
        deleteIndex = any([uniqueFlag,deleteIndex],2);
    end
end
searchList(deleteIndex) = [];
if isempty(searchList)
    error(['No Folder found under Experiment ID - ',expID,...
        '. Check spelling of Experiment ID and Base Folder']);
end

if length(searchList) == 1
    sessionFolder = char(searchList);
else
    message = ['Choose Session Folder with ID:   ',expID];
    selection = menu(message , searchList);
    sessionFolder = char(searchList(selection));
end
end