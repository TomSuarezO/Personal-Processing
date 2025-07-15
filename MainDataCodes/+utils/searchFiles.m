function allFiles = searchFiles(toSearch)

allSearch   = arrayfun(@dir, toSearch,'UniformOutput',false);
allStruct    = vertcat(allSearch{:});
allStruct([allStruct.isdir]) = [];

allFiles = string(arrayfun(@(x) fullfile(x.folder,x.name),allStruct,'UniformOutput',false));