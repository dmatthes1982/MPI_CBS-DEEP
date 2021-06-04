
% -------------------------------------------------------------------------
% Add directory and subfolders to path, clear workspace, clear command
% windwow
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
run([filepath '/../DEEP_init.m']);

cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>DEEP project</strong>\n');                       
cprintf([0,0.6,0], '<strong>Surrogate data generator</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2020, Mohammed Alahmadi, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
datastorepath = '/data/pt_01888/eegData/';                                  % root path to eeg data
desPath = '/data/pt_01888/eegData/DualEEG_DEEP_surrogate_analysis/';        % processed data location
if ~exist(desPath, 'dir')                                                   % generate session dir, if not exist
  mkdir(desPath);
end

fprintf('\nThe default path is: %s\n', datastorepath);

selection = false;
while selection == false
    fprintf('\nDo you want to use the default path?\n');
    x = input('Select [y/n]: ','s');
    if strcmp('y', x)
        selection = true;
        newPaths = false;
    elseif strcmp('n', x)
        selection = true;
        newPaths = true;
    else
        selection = false;
    end
end

if newPaths == true
    datastorepath = uigetdir(pwd, 'Select folder...');
    datastorepath = strcat(datastorepath, '/');
end

clear newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
fprintf('\n<strong>Session selection...</strong>\n');
srcPath = [datastorepath 'DualEEG_DEEP_processedData/'];
srcPath = [srcPath  '06b_hilbert/'];

fileList     = dir([srcPath, 'DEEP_d*_06b_hilbertAlpha_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
    fileListCopy{dyad} = strsplit(fileList{dyad}, '06b_hilbertAlpha_');
    fileListCopy{dyad} = fileListCopy{dyad}{end};
    sessionNum(dyad) = sscanf(fileListCopy{dyad}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for dyad = sessionNum
    match = find(strcmp(fileListCopy, sprintf('%03d.mat', dyad)), 1, 'first');
    filePath = [srcPath, fileList{match}];
    [~, cmdout] = system(['ls -l ' filePath '']);
    attrib = strsplit(cmdout);
    userList{dyad} = attrib{3};
end

selection = false;
while selection == false
    fprintf('The following sessions are available: %s\n', y);
    fprintf('The session owners are:\n');
    for dyad = sessionNum
        fprintf('%d - %s\n', dyad, userList{dyad});
    end
    fprintf('\n');
    fprintf('Please select one session:\n');
    fprintf('[num] - Select session\n\n');
    x = input('Session: ');
    
    if length(x) > 1
        cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
    else
        if ismember(x, sessionNum)
            selection = true;
            sessionStr = sprintf('%03d', x);
        else
            cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
        end
    end
end

fprintf('\n');

clear sessionNum fileListCopy y userList match filePath cmdout attrib ...
    fileList numOfFiles x selection dyad

% -------------------------------------------------------------------------
% Passband selection
% -------------------------------------------------------------------------
fprintf('<strong>Passband selection...</strong>\n');
passband  = {'Alpha', 'Beta', 'Gamma'};                                     % all available passbands

part = listdlg('PromptString',' Select passband...', ...                    % open the dialog window --> the user can select the passband of interest
                'SelectionMode', 'single', ...
                'ListString', passband, ...
                'ListSize', [220, 300] );
              
passband  = passband{part};
fprintf('You have selected the following passband: %s\n\n', passband);

% -------------------------------------------------------------------------
% Dyad selection
% -------------------------------------------------------------------------
fprintf('<strong>Dyad selection...</strong>\n');
fileList     = dir([srcPath 'DEEP_d*_06b_hilbert' passband '_' sessionStr ...
                    '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

listOfDyads = zeros(numOfFiles, 1);
for i = 1:1:numOfFiles
    listOfDyads(i) = sscanf(fileList{i}, ['DEEP_d%d_06b_hilbert' ...        % generate a list of all available numbers of dyads
        passband '_' sessionStr '.mat']);
end

listOfDyadstStr = cellfun(@(x) sprintf('%d', x), ...                        % prepare a cell array with all possible options for the following list dialog
                        num2cell(listOfDyads), 'UniformOutput', false);

dyads = listdlg('PromptString',' Select dyads...', ...                      % open the dialog window --> the user can select the participants of interest
                'ListString', listOfDyadstStr, ...
                'ListSize', [220, 300] );

listOfDyadsBool = ismember(1:1:numOfFiles, dyads);                          % transform the user's choise into a binary representation for further use

dyads = listOfDyadstStr(listOfDyadsBool);                                   % generate a cell vector with identifiers of all selected dyads

fprintf('You have selected the following dyads:\n');
cellfun(@(x) fprintf('%s, ', x), dyads, 'UniformOutput', false);            % show the identifiers of the selected dyads in the command window
fprintf('\b\b.\n\n');

dyads       = listOfDyads(listOfDyadsBool);                                 % generate dyad vector for further use
fileList    = fileList(listOfDyadsBool);
numOfFiles  = length(fileList);

%--------------------------------------------------------------------------
% Generate a random bootstrapping surrogate
%--------------------------------------------------------------------------
part_id     = ["mother", "child"]; 
numOfPermutations = 1000;
for i_file = 1:numOfFiles
    org_dyad = dyads(i_file);
    inc = 0;
    for org_part = 1:2
        rand_dyads  = randi(length(listOfDyads), 1, fix(numOfPermutations/2));
        rand_part   = randi(2, 1, fix(numOfPermutations/2));

        flag = true;
        while flag
            idx = find(rand_dyads == org_dyad);
            if numel(idx) == 0
                flag = false;
            else
                rand_dyads(:,idx) = randi(length(listOfDyads), 1, numel(idx));
            end
        end

        for i_perm = 1:fix(numOfPermutations/2)
            file_data1    = sprintf(['DEEP_d%02.f_06b_hilbert' ... 
                passband '_' sessionStr], org_dyad);
            file_data2    = sprintf(['DEEP_d%02.f_06b_hilbert' ... 
                passband '_' sessionStr], listOfDyads(rand_dyads(i_perm)));
            file_artifact1 = sprintf(['DEEP_d%02.f_05b_allart_' ...
                sessionStr], org_dyad);
            file_artifact2 = sprintf(['DEEP_d%02.f_05b_allart_' ...
                sessionStr], listOfDyads(rand_dyads(i_perm)));
            
            
            fprintf('<strong>Load hilbert phase data...\n</strong>');
            file_path_data1 = strcat(srcPath, file_data1,'.mat');
            file_path_data2 = strcat(srcPath, file_data2,'.mat');
            data_sub1=load(file_path_data1);
            data_sub2=load(file_path_data2);
            
            fprintf('<strong>Load automatic and manual defined artifacts...\n</strong>');
            artPath = [datastorepath 'DualEEG_DEEP_processedData/'];
            artPath = [artPath  '05b_allart/'];
   
            file_path_artifact1 = strcat(artPath, file_artifact1,'.mat');
            file_path_artifact2 = strcat(artPath, file_artifact2,'.mat');
            artifact_sub1=load(file_path_artifact1);
            artifact_sub2=load(file_path_artifact2);
            
            first_field1 = fieldnames(data_sub1);
            first_field2 = fieldnames(data_sub2);
            
            % mix data from two different dyads
            data_hilbert.mother = data_sub1.(first_field1{1}).(part_id(org_part));
            data_hilbert.child = data_sub2.(first_field2{1}).(part_id(rand_part(i_perm)));
            data_hilbert.centerFreqMother = data_sub1.(first_field1{1}).centerFreqMother;
            data_hilbert.bpFreqMother = data_sub1.(first_field1{1}).bpFreqMother;
            data_hilbert.centerFreqChild = data_sub1.(first_field1{1}).centerFreqChild;
            data_hilbert.bpFreqChild = data_sub1.(first_field1{1}).bpFreqChild;
            
            first_field1 = fieldnames(artifact_sub1);
            first_field2 = fieldnames(artifact_sub2);
                        
            cfg_allart.mother = artifact_sub1.(first_field1{1}).(part_id(org_part));
            cfg_allart.child = artifact_sub2.(first_field2{1}).(part_id(rand_part(i_perm)));
            
            trial_mother = data_hilbert.mother.trialinfo;
            trial_child = data_hilbert.child.trialinfo;
            
            % keep only the trials which are common
            cfg = [];
            [cfg.trials, ~] = intersect(trial_mother, trial_child);
            data_hilbert = DEEP_selectdata(cfg, data_hilbert);
            
            % segmentation
            cfg           = [];
            cfg.length    = 1;
            cfg.overlap   = 0;
            data_hilbert  = DEEP_segmentation( cfg, data_hilbert );
            
            % remove manual defined artifacts
            cfg           = [];
            cfg.part      = 'mother';
            cfg.artifact  = cfg_allart;
            cfg.reject    = 'complete';
            cfg.target    = 'single';

            fprintf('<strong>Rejection of manual, during the testing defined artifacts</strong>');
            backup = data_hilbert.child;
            try
                data_hilbert = DEEP_rejectArtifacts(cfg, data_hilbert);
            catch
                fprintf('Empty dataset - this permutation will be skipped.\n\n');
                inc = inc + 1;
                continue;
            end
            data_hilbert.child = backup;
            fprintf('\n');
            
            cfg           = [];
            cfg.part      = 'child';
            cfg.artifact  = cfg_allart;
            cfg.reject    = 'complete';
            cfg.target    = 'single';

            fprintf('<strong>Rejection of artifacts</strong>');
            
            backup = data_hilbert.mother;
            try
                data_hilbert = DEEP_rejectArtifacts(cfg, data_hilbert);
            catch
                fprintf('Empty dataset - this permutation will be skipped.\n\n');
                inc = inc + 1;
                continue;
            end
            data_hilbert.mother = backup;
            fprintf('\n');
            
            % remove subtrials which have not equivalent in the other dataset
            trial_num = unique(data_hilbert.mother.trialinfo);
            mother_trials = zeros(1, length(trial_num));
            child_trials = zeros(1, length(trial_num));
            
            for i=1:1:length(trial_num)
                mother_trials(i) = sum(data_hilbert.mother.trialinfo == trial_num(i));
                child_trials(i) = sum(data_hilbert.child.trialinfo == trial_num(i));
            end
            
            for i=1:1:length(trial_num)
                diff = mother_trials(i) - child_trials(i);
                if (diff > 0)
                    pos = find(data_hilbert.mother.trialinfo == trial_num(i), diff, 'last');
                    data_hilbert.mother.trialinfo(pos) = [];
                    data_hilbert.mother.sampleinfo(pos,:) = [];
                    data_hilbert.mother.time(pos) = [];
                    data_hilbert.mother.trial(pos) = [];
                elseif (diff < 0)
                    pos = find(data_hilbert.child.trialinfo == trial_num(i), abs(diff), 'last');
                    data_hilbert.child.trialinfo(pos) = [];
                    data_hilbert.child.sampleinfo(pos,:) = [];
                    data_hilbert.child.time(pos) = [];
                    data_hilbert.child.trial(pos) = [];
                end
            end
            
            % fake PLV estimation
            cfg           = [];
            cfg.winlen    = 1;
            dataPLV       = DEEP_phaseLockVal(cfg,  data_hilbert);
            dataPLV       = DEEP_calcMeanPLV(dataPLV);

            % save preprocessed data
            desFolder   = strcat(desPath);
            file_path = strcat(desFolder, sprintf(['DEEP_d%02d', ... 
                '_perm%04d', passband],...
                org_dyad, inc), '.mat');
            fprintf('The surrogate plv data of dyad will be saved in '); 
            fprintf('%s ...\n', file_path);
            save(file_path, 'dataPLV');
            fprintf('Data stored!\n\n');
            inc = inc + 1;
        end
    end
end

clear;
