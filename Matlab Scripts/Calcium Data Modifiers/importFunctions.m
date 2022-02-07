function fData = importFunctions
% 07/19/21 Tomas Suarez Omedas - Script with function Database for
% postprocessing curated ps2p data. Each field of the structure fData will
% have fields Process fName and fPath Function is called without inputs to
% get the structure fData and all function paths added to MATLAB's path
% To add new functions to the pseudo-object fData add two pieces of info:
%     1) The name of the analysis in the "Analyses" variable (add it last)
%     2) The full name (both path and file name with extension) in the
%     "files" variable (add it last)
% Double check that the code works by calling fData = importFunctions from
% the command window

fData = struct('Process',[],'fFile',[],'fPath',[]);
Analyses = ["Fast Grating Response Matrix";
    "Single Session k-NN Classifier";
    "Cross-Session Registration";
    "dataOut Analysis";
    "Create Fall_out.mat"];
files = ["\\kuhlman-nas.bio.cmu.edu\projects\Tommy\Wheel_integrated_v210603\Run_fastGrating_Analysis.m";
    "\\kuhlman-nas.bio.cmu.edu\projects\Tommy\Classifier KNN\knnDecoder_PS2P_fastGratingStim_1SF.m";
    "\\kuhlman-nas.bio.cmu.edu\projects\Klab_Suite2P_processSuiteP_createDataOut\cross_session_registration\sessionRegistration_PS2P_affine_v210701.m";
    "\\kuhlman-nas.bio.cmu.edu\projects\Tommy\dataOut Main - PS2P\divergence_dataOut.m";
    "\\kuhlman-nas.bio.cmu.edu\projects\Tommy\KL-Nest\createFcell.m"];

for n = 1:length(files)
    fData(n).Process = Analyses(n);
    [fData(n).fPath , fData(n).fFile,~] = fileparts(files(n));
    fData(n).fFile = str2func(fData(n).fFile);
    addpath(fData(n).fPath);
end

end