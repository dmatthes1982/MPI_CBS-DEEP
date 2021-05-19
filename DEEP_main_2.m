%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_raw/';
  cfg.filename  = 'DEEP_d01_01a_raw';
  sessionStr    = sprintf('%03d', DEEP_getSessionNum( cfg ));               % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01888/eegData/DualEEG_DEEP_processedData/';           % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '01a_raw/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('DEEP_d%d_01a_raw_', sessionStr, '.mat'));
  end
end

%% part 2
% 1. select bad/noisy channels
% 2. filter the good channels (basic bandpass filtering)

cprintf([0,0.6,0], '<strong>[2] - Preproc I: bad channel detection, filtering</strong>\n');
fprintf('\n');

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  DEEP_createTbl(cfg);                                                      % create settings file
end

% Load settings file
T = readtable(settings_file);                                               % update settings table

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);

  %% selection of corrupted channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Selection of corrupted channels</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('DEEP_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load raw data...\n');
  DEEP_loadData( cfg );

  % concatenated raw trials to a continuous stream
  cfg = [];
  cfg.part = 'both';

  data_continuous = DEEP_concatData( cfg, data_raw );

  fprintf('\n');

  % detect noisy channels automatically
  data_noisy = DEEP_estNoisyChan( data_continuous );

  fprintf('\n');

  % select corrupted channels
  data_badchan = DEEP_selectBadChan( data_continuous, data_noisy );
  clear data_noisy

  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02a_badchan/');
  cfg.filename    = sprintf('DEEP_d%02d_02a_badchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Bad channels of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'data_badchan', data_badchan);
  fprintf('Data stored!\n\n');
  clear data_continuous

  % add bad labels of bad channels to the settings file
  if isempty(data_badchan.mother.badChan)
    badChanMother = {'---'};
  else
    badChanMother = {strjoin(data_badchan.mother.badChan,',')};
  end
  if isempty(data_badchan.child.badChan)
    badChanChild  = {'---'};
  else
    badChanChild  = {strjoin(data_badchan.child.badChan,',')};
  end
  warning off;
  T.badChanMother(i)  = badChanMother;
  T.badChanChild(i)   = badChanChild;
  warning on;

  % store settings table
  delete(settings_file);
  writetable(T, settings_file);

  %% basic bandpass filtering of good channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Basic preprocessing of good channels</strong>\n');

  cfg                   = [];
  cfg.bpfreq            = [1 48];                                           % passband from 1 to 48 Hz
  cfg.bpfilttype        = 'but';
  cfg.bpinstabilityfix  = 'split';
  cfg.motherBadChan     = data_badchan.mother.badChan';
  cfg.childBadChan      = data_badchan.child.badChan';
  
  ft_info off;
  data_preproc1 = DEEP_preprocessing( cfg, data_raw);
  ft_info on;
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02b_preproc1/');
  cfg.filename    = sprintf('DEEP_d%02d_02b_preproc1', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'data_preproc1', data_preproc1);
  fprintf('Data stored!\n\n');
  clear data_preproc1 data_raw data_badchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i selection badChanMother ...
      badChanChild T settings_file
