function d = extract_experimental_data(exp, func)

% Rebecca Krall 1/25/21
%
% This function is designed to extract and align all the relevant data
% for a given 2P experiment and return it as a structure. Its adapted
% from create_results_struct.
%
% Inputs:
%   exp - a struct containing a field for each column in the
%    project spreadsheet. At minimum, exp needs the following fields:
%       MainPath - directory of data i.e.
%         W:\Data\Sensory_Characterization_and_Behavioral_State\
%       CellType - subdirectory of MainPath, cell type of experiment
%       Animal - animal ID and subdirectory of cell type
%       Date - number in the format MDDYY or MMDDYY - also a
%         subdirectory
%       Suite2PParameterFile - subdirectory in 2P and parameter file
%         for suite2p for experiment
%       ImpaleParameterFile - subdirectory in Impale and impale
%         parameter file
%       Zoom - zoom of the experiment
%       day - day of the experiment
%       FolderMergeNumber - number indicating if that experiment merged
%         into another folder based on something I don't understand
%       stim_software - Impale or Tosca
%
%   func - an optional boolean. If true it loads fall_functional.mat,
%   if false it loads fall_anatomical.mat, if not passed it simply
%   loads fall.mat - 3/29/22 edit RK
%
% Outputs:
%   d - a struct containing relevant information about the experiment
%     and its raw data. Designed to match the output of
%     create_results_struct

% Updated 4/14/22 to handle Tosca data - Nathan A. Schneider


% First find the directories of all the data - requires a consistent
% folder structure that is natively generated by our software
if (exp.Date) < 100000
    session_dir = [exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\0', num2str(exp.Date), '\'];
    imaging_dir = [exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\0', num2str(exp.Date), '\',exp.Suite2PParameterFile];
    impale_dir  = strcat(exp.MainPath, exp.CellType, '\Impale\', exp.Animal, '\0', num2str(exp.Date));
    tosca_dir   = strcat(exp.MainPath, exp.CellType, '\Tosca\', exp.Animal, "\Session ", num2str(exp.ToscaSession));
    camera_dir  = strcat(exp.MainPath, exp.CellType, '\Camera\', exp.Animal, '\0', num2str(exp.Date));
else
    session_dir = [exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\', num2str(exp.Date), '\'];
    imaging_dir = [exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\', num2str(exp.Date), '\',exp.Suite2PParameterFile];
    impale_dir  = strcat(exp.MainPath, exp.CellType, '\Impale\', exp.Animal, '\', num2str(exp.Date));
    tosca_dir   = strcat(exp.MainPath, exp.CellType, '\Tosca\', exp.Animal, "\Session ", num2str(exp.ToscaSession));
    camera_dir  = strcat(exp.MainPath, exp.CellType, '\Camera\', exp.Animal, '\', num2str(exp.Date));
end


% Pull out information from the parameter file name and the exp struct
impaleName = split(exp.ImpaleParameterFile,{'-'});
impaleIndex = impaleName{2};
if isequal(exp.stim_software,'Impale')
    d.Parameter = impaleName{end};
elseif isequal(exp.stim_software,'Tosca')
    d.Parameter = exp.ToscaParameterFile;
end

d.zoom  = exp.Zoom;
d.day   = exp.Day;

if isnan(exp.nPlanes) % set number of planes to 1 if not specified
    exp.nPlanes = 1;
end

% Find the relevant files in the directories determined above - uses
% dir2 to look into subdirectories - if causing errors,  you might need
% to make sure other files aren't being pulled out due to unexpected
% similarities (i.e. another .xml file saved in the 2P directories)
if nargin == 1
    data_raw = dir2(imaging_dir, '*Fall', 2, '/s');
elseif func
    data_raw = dir2(imaging_dir, '*Fall_functional', 2, '/s');
else
    data_raw = dir2(imaging_dir, '*Fall_anatomical', 2, '/s');
end

% If doing volumetric imaging, check if there are multiple Fall files (one
% for each plane). Otherwise use only the first Fall file.
if exp.nPlanes > 1
    if any(contains(data_raw,'combined'))
        data_raw = data_raw(1);
    else
        if exp.nPlanes ~= length(data_raw)
            error('Incorrect number of Fall.mat files for the given number of planes')
        end
    end
else
    data_raw = data_raw(1);
end
d.files.data_raw = data_raw;

data_xml            = dir2(imaging_dir, '.xml', 2, '/s');
d.files.data_xml    = data_xml{1};

if isequal(exp.stim_software,'Impale')
    data_stim = dir2(impale_dir, ['*',exp.ImpaleParameterFile],'/s');
    d.files.data_stim = data_stim{1};

elseif isequal(exp.stim_software,'Tosca')

    % Allow multiple Tosca files during one imaging session.
    
    % Pull out the session and run numbers
    numbers = regexp(exp.ImpaleParameterFile, '\d+', 'match');

    if exp.ToscaRun ~= str2double(numbers{end})
        if ~contains(exp.ToscaParameterFile, 'multiple')
            warning('Tosca run number does not match parameter file name. Check the CSV entries.')
        else
            idx = 1;
            for ii = str2double(numbers{end}):exp.ToscaRun
                data_stim{idx} = strcat(tosca_dir, '\', exp.Animal, '-Session', num2str(exp.ToscaSession), '-Run', num2str(ii), '.txt');
                idx = idx + 1;
            end
            d.files.data_stim = data_stim;
        end

    else
        data_stim = strcat(tosca_dir, '\', exp.Animal, '-Session', num2str(exp.ToscaSession), '-Run', num2str(exp.ToscaRun), '.txt');
        d.files.data_stim = data_stim{1};
    end
end


% The sync folder must match the second number of the parameter file.
% The folder always has three digits so this figures out the folder
% name before looking for the .h5 file
if str2double(impaleIndex) > 99
    sync_folder = '\SyncData';
elseif str2double(impaleIndex) > 9
    sync_folder = '\SyncData0';
else
    sync_folder = '\SyncData00';
end

if (exp.Date) < 100000
    thorFolder = [exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\0', num2str(exp.Date) sync_folder, impaleIndex];
else
    thorFolder = [exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\', num2str(exp.Date) sync_folder, impaleIndex];
end

data_sync = dir2(thorFolder, '.h5', '/s');
d.files.data_sync = data_sync{1};

d.files.folder_camera = camera_dir;

% Extract the ThorSync and Calcium data - same as what extractData uses
disp('Loading sync data');
[syncInfo] = extract_ThorSyncData(data_sync{1},exp.stim_software,exp.nPlanes);

fluor = extract_CalciumData(data_raw,exp.FolderMergeNumber);

if isequal(exp.stim_software,'Impale')
    stim_data           = grabImpaleData(data_stim{1});

    d.outer_sequence    = stim_data.outer_sequence;
    d.inner_sequence    = stim_data.inner_sequence;
    d.outer_index       = stim_data.outer_index;
    d.inner_index       = stim_data.inner_index;

    fluor.stimData = stim_data;

    % number of frames per second
    if stim_data.frame_rate ~= 30
        % res = input('Detected framerate from Impale not equal to 30. Force 30 fr/sec? [y/n]   ','s');
        res = 'y'; % use the line above if you want to force impale's frame readout to 30fps
        if strcmp(res,'y')
            stim_data.frame_rate = 30;
        end
    end

    % Account for different frame rates with multiplane imaging
    if exp.nPlanes > 1
        if isnan(exp.nFlybackFrames)
            exp.nFlybackFrames = 0;
        end
        nFrames = exp.nPlanes + exp.nFlybackFrames;
        newFr   = find_fr_multiPlane(syncInfo,nFrames);
        d.fr    = newFr;
        fluor.nUniqueFrames = nFrames;
    else
        d.fr = round(stim_data.frame_rate);
        fluor.nUniqueFrames = 1;
    end

    % number of seconds prior to sound onset
    stim_delay          = stim_data.stimChans{1,1}.Gate.Delay / 1000;
    stim_length         = stim_data.stimChans{1,1}.Gate.Width /1000;

    % the index of the first frame where the sound plays
    d.stim_onset_frame  = round(stim_delay * d.fr); % used to be floor, changed by Tomas Suarez Omedas to allow lower rate volumetric to work
    d.spike_traces      = align_Spike_Traces(fluor,d.fr,syncInfo);
    d.calcium_traces    = align_Calcium_Traces(fluor,d.fr,syncInfo,2);


elseif isequal(exp.stim_software,'Tosca')

    if iscell(data_stim)
        disp(['Found ' num2str(length(data_stim)) ' Tosca files. Concatenating...']);
        [stim_data, param_seq, param_idx] = concatenate_tosca_logs(data_stim);

        d.param_seq = param_seq;
        d.param_idx = param_idx;

    else
        stim_data = tosca_create_log(data_stim);
    end

    fluor.stimData = stim_data;

    % Account for different frame rates with multiplane imaging
    if exp.nPlanes > 1
        if isnan(exp.nFlybackFrames)
            exp.nFlybackFrames = 0;
        end
        nFrames = exp.nPlanes + exp.nFlybackFrames;
        newFr   = find_fr_multiPlane(syncInfo,nFrames);
        d.fr    = newFr;
        fluor.nUniqueFrames = nFrames;
    else
        d.fr = round(stim_data.params.Tosca.Imaging.FrameRateHz);
        fluor.nUniqueFrames = 1;
    end
    
    % number of seconds prior to sound onset
    [stim_delay, stim_length] = tosca_find_onset(stim_data);
    stim_offset = stim_delay + stim_length;

    d.stim_onset_frame    = round(stim_delay * d.fr);
    d.stim_offset_frame   = round(stim_offset * d.fr);
    d.spike_traces_full   = align_Spike_Traces(fluor,d.fr,syncInfo);
    d.calcium_traces_full = align_Calcium_Traces(fluor,d.fr,syncInfo,0);
end

% Added second column to notate the imaging plane
d.suite2p_ROI = uint16([fluor.iscell-1 fluor.cell_plane]);


% Generate zscores based on the overall mean and std of the baseline
% period across all traces. This generally assumes that the spontaneous
% activity is largely consistent across the course of the experiment.
if isequal(exp.stim_software,'Impale')
    d.spike_zscores = zeros(size(d.spike_traces));
    for i = 1:size(d.spike_traces,1)

        baseline_avg = mean(d.spike_traces(i,1:d.stim_onset_frame-1,:),'all','omitnan');
        baseline_std = std(d.spike_traces(i,1:d.stim_onset_frame-1,:),[],'all','omitnan');
        if isnan(baseline_avg) || isnan(baseline_std)
            % patch by Tomas Suarez Omedas to account for experiments
            % with no delay in impale parameter file (try that stim
            % onset frame is not zero)
            % patch uses last 15 frames of each trial as baseline
            % (suboptimal)
            baseline_avg = mean(d.spike_traces(i,end-15:end,:),'all','omitnan');
            baseline_std = std(d.spike_traces(i,end-15:end,:),[],'all','omitnan');
        elseif baseline_std==0
            % patch by Tomas Suarez Omedas to prevent formation of NaN when
            % a neuron did not spike in a given trial (sometimes happens in
            % short trials). Sets baseline_std to one to prevent division
            % by zero
            baseline_std = 1;
        end
        for j=1:size(d.spike_traces,3)
            d.spike_zscores(i,:,j)= (d.spike_traces(i,:,j)-baseline_avg)/baseline_std;
        end
    end

elseif isequal(exp.stim_software,'Tosca')

    % Run Tosca-specific processing to align trials and extract stimulus
    % and behavioral variables
    [spike_matrix,spikes_zscored,raw_calcium,dF_F,trial_stimulus,trial_outcome,rxn_time,stim_order] ...
        = get_data_tosca(stim_data,d.spike_traces_full,d.calcium_traces_full,d.stim_onset_frame);

    d.spike_traces = spike_matrix;
    d.spike_zscores = spikes_zscored;
    d.raw_calcium = raw_calcium;
    d.calcium_traces = dF_F;

    % Get inner and outer stimulus variables (to match Impale nomenclature)
    [d.inner_sequence, ~,  d.inner_index] = unique(trial_stimulus(:, 1));
    if numel(trial_stimulus(1, :)) == 2
        [d.outer_sequence, ~ , d.outer_index] = unique(trial_stimulus(:, 2));
    else 
        d.outer_sequence = [];
        d.outer_index = [];
    end

    % Get newer stimulus nomenclature
    stim_idx = uint8(zeros(size(trial_stimulus)));
    stim_seq = cell(size(trial_stimulus,2),1);
    for i = 1:size(trial_stimulus,2)
        [stim_seq_temp,~,stim_idx_temp] = unique(trial_stimulus(:,i));
        stim_seq{i} = stim_seq_temp;
        stim_idx(:,i) = stim_idx_temp;
    end
    d.stim_seq = stim_seq;
    d.stim_idx = stim_idx;
    d.stim_order = stim_order;

    % Behavior variables
    d.rxn_time = rxn_time;
    d.trial_outcome = trial_outcome;
end