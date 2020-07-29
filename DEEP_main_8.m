%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '04c_preproc2';
  cfg.filename  = 'coSMIC_d01_04c_preproc2';
  sessionStr    = sprintf('%03d', DEEP_getSessionNum( cfg ));             % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01888/eegData/DualEEG_coSMIC_processedData/';         % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eyecor data folder
  sourceList    = dir([strcat(desPath, '04c_preproc2/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('coSMIC_d%d_04c_preproc2_', sessionStr, '.mat'));
  end
end

%% part 8
% 1. Calculate TFRs of the preprocessed data
% 2. Calculate the power scpectrum of the processed data

cprintf([0,0.6,0], '<strong>[8] - Power analysis (TFR, pWelch)</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculation of time-frequency response (TFR)
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should the time-frequency response calculated?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    tfr = true;
  elseif strcmp('n', x)
    choise = true;
    tfr = false;
  else
    choise = false;
  end
end
fprintf('\n');

if tfr == true
  for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);

    cfg             = [];                                                   % load EOG-artifact corrected data
    cfg.srcFolder   = strcat(desPath, '04c_preproc2/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('coSMIC_d%02d_04c_preproc2', i);

    fprintf('Load preprocessed data...\n\n');
    DEEP_loadData( cfg );

    maxtrll = max(cell2mat(cellfun(@(x) size(x,2), ...
                  data_preproc2.child.trial, 'UniformOutput', false)));
    tend    = ceil(maxtrll/2500)*5;

    cfg         = [];
    cfg.foi     = 2:1:50;                                                   % frequency of interest
    cfg.toi     = 0:0.5:tend;                                               % time of interest

    data_tfr = DEEP_timeFreqanalysis( cfg, data_preproc2 );

    % export TFR data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '08a_tfr/');
    cfg.filename    = sprintf('coSMIC_d%02d_08a_tfr', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Time-frequency response data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    DEEP_saveData(cfg, 'data_tfr', data_tfr);
    fprintf('Data stored!\n\n');
    clear data_tfr data_preproc2 maxtrll tend
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculation of the power spectrum using Welch's method (pWelch)
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should the power spectrum by using Welch''s method be calculated?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    pwelch = true;
  elseif strcmp('n', x)
    choise = true;
    pwelch = false;
  else
    choise = false;
  end
end
fprintf('\n');

if pwelch == true
  choise = false;
  while choise == false
    cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before power estimation?\n');
    x = input('Select [y/n]: ','s');
    if strcmp('y', x)
      choise = true;
      artifactRejection = true;
    elseif strcmp('n', x)
      choise = true;
      artifactRejection = false;
    else
      choise = false;
    end
  end
  fprintf('\n');
  
  % Write selected settings to settings file
  file_path = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
  if ~(exist(file_path, 'file') == 2)                                       % check if settings file already exist
    cfg = [];
    cfg.desFolder   = [desPath '00_settings/'];
    cfg.type        = 'settings';
    cfg.sessionStr  = sessionStr;
  
    DEEP_createTbl(cfg);                                                  % create settings file
  end

  T = readtable(file_path);                                                 % update settings table
  warning off;
  T.artRejectPow(numOfPart) = { x };
  warning on;
  delete(file_path);
  writetable(T, file_path);
  
  for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);
    
    % Load preprocessed data
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '04c_preproc2/');
    cfg.filename    = sprintf('coSMIC_d%02d_04c_preproc2', i);
    cfg.sessionStr  = sessionStr;

    fprintf('Load preprocessed data...\n\n');
    DEEP_loadData( cfg );
    
    % Segmentation of conditions in segments of one second with 75 percent
    % overlapping
    cfg          = [];
    cfg.length   = 1;                                                       % window length: 1 sec       
    cfg.overlap  = 0.75;                                                    % 75 percent overlap
    
    fprintf('<strong>Segmentation of preprocessed data.</strong>\n');
    data_preproc2 = DEEP_segmentation( cfg, data_preproc2 );

    numOfAllSeg = DEEP_numOfSeg( data_preproc2 );                         % estimate number of segments for each existing condition and participant

    fprintf('\n');
    
    % Load artifact definitions 
    if artifactRejection == true
      cfg             = [];
      cfg.srcFolder   = strcat(desPath, '05b_allart/');
      cfg.filename    = sprintf('coSMIC_d%02d_05b_allart', i);
      cfg.sessionStr  = sessionStr;

      file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');
      if ~isempty(dir(file_path))
        fprintf('Loading %s ...\n', file_path);
        DEEP_loadData( cfg );                                                  
        artifactAvailable = true;     
      else
        fprintf('File %s is not existent,\n', file_path);
        fprintf('Artifact rejection is not possible!\n');
        artifactAvailable = false;
      end
    fprintf('\n');  
    end
    
    % Artifact rejection
    if artifactRejection == true
      if artifactAvailable == true
        cfg           = [];
        cfg.artifact  = cfg_allart;
        cfg.reject    = 'complete';
        cfg.target    = 'single';

        fprintf('<strong>Artifact Rejection with preprocessed data.</strong>\n');
        data_preproc2 = DEEP_rejectArtifacts(cfg, data_preproc2);
        fprintf('\n');
      end
      
      clear cfg_allart
    end

    numOfGoodSeg = DEEP_numOfSeg( data_preproc2 );                        % estimate number of remaining segments (after artifact rejection) for each existing condition and participant

    % Estimation of power spectrum
    cfg         = [];
    cfg.foi     = 1:1:50;                                                   % frequency of interest
      
    data_preproc2 = DEEP_pWelch( cfg, data_preproc2 );                    % calculate power activity using Welch's method
    data_pwelch = data_preproc2;                                            % to save need of RAM
    data_pwelch.mother.numOfAllSeg  = numOfAllSeg.mother;                   % add number of segments of each existing condition
    data_pwelch.child.numOfAllSeg   = numOfAllSeg.child;
    data_pwelch.mother.numOfGoodSeg = numOfGoodSeg.mother;                  % add number of clean segments of each existing condition
    data_pwelch.child.numOfGoodSeg  = numOfGoodSeg.child;
    clear data_preproc2
    
    % export power spectrum into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '08b_pwelch/');
    cfg.filename    = sprintf('coSMIC_d%02d_08b_pwelch', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Power spectrum of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    DEEP_saveData(cfg, 'data_pwelch', data_pwelch);
    fprintf('Data stored!\n\n');
    clear data_pwelch
  end
end

%% clear workspace
clear file_path cfg sourceList numOfSources i choise tfr pwelch T ...
      artifactRejection artifactAvailable numOfAllSeg numOfGoodSeg
