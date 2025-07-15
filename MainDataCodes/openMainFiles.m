function openMainFiles
allFiles = ["D:\Tommy - Code\Widefield-Analysis\getWidefieldMap.m"
    "D:\Tommy - Code\mouse-track\prepfolder_for_suite2p.m"
    "D:\Tommy - Code\mouse-track\mouseTrack.m"
    "D:\Tommy - Code\matchHub\makeROImatrix_Search.m"
    "D:\Tommy - Code\Single-Cell-Summaries\matchedComparison.m"];

for ii = 1:numel(allFiles)
    edit(allFiles(ii))
end