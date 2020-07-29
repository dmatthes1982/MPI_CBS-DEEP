%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_raw/';
  cfg.filename  = 'coSMIC_d01_01a_raw';
  sessionNum    = DEEP_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath = '/data/pt_01888/eegData/DualEEG_coSMIC_rawData/';               % source path to raw data
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01888/eegData/DualEEG_coSMIC_processedData/';         % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '/*.vhdr']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, 'coSMIC_all_P%d.vhdr');
  end
end

%% part 1
% 1. import data from brain vision eeg files and bring it into an order

cprintf([0,0.6,0], '<strong>[1] - Data import</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Select channels, which are NOT of interest?\n');
  fprintf('[1] - import all channels\n');
  fprintf('[2] - reject T7, T8, PO9, PO10, P7, P8, TP10\n');
  fprintf('[3] - reject specific selection\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      noichan = [];
      noichanStr = {'---'};
    case 2
      selection = true;
      noichan = {'T7', 'T8', 'PO9', 'PO10', 'P7', 'P8', 'TP10'};
      noichanStr = {'-T7,-T8,-PO9,-PO10,-P7,-P8,-TP10'};
    case 3
      selection = true;
      cprintf([0,0.6,0], '\nAvailable channels will be determined. Please wait...\n');

      load('layouts/mpi_customized_acticap32.mat', 'lay')
      label = lay.label(1:end-2);
      loc   = ~ismember(label, {'V1', 'V2', 'F9', 'F10'});                  % remove EOG-related electrodes from options to avoid errors
      label = label(loc);

      sel = listdlg('PromptString', ...                                     % open the dialog window --> the user can select the channels wich are not of interest
              'Which channels are NOT of interest...', ...
              'ListString', label, ...
              'ListSize', [220, 300] );

      noichan = label(sel)';
      channels = {strjoin(noichan,',')};

      fprintf('You have unselected the following channels:\n');
      fprintf('%s\n', channels{1});

      noichanStr = cellfun(@(x) strcat('-', x), noichan, ...
                          'UniformOutput', false);
      noichanStr = {strjoin(noichanStr,',')};
      clear channels label loc sel
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;

  DEEP_createTbl(cfg);                                                       % create settings file
end

% Load settings file
T = readtable(settings_file);
warning off;
T.dyad(numOfPart)     = numOfPart;
T.noiChan(numOfPart)  = noichanStr;
warning on;

%% import data from brain vision eeg files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  cfg               = [];
  cfg.path          = srcPath;
  cfg.dyad          = i;
  cfg.noichan       = noichan;
  cfg.continuous    = 'no';
  cfg.prestim       = 0;
  cfg.rejectoverlap = 'yes';
  
  fprintf('<strong>Import data of dyad %d</strong> from: %s ...\n', i, cfg.path);
  ft_info off;
  [data_raw, cfg_manart] = DEEP_importDataset( cfg );
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('coSMIC_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01b_manart/');
  cfg.filename    = sprintf('coSMIC_d%02d_01b_manart', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The manual defined artifacts of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'cfg_manart', cfg_manart);
  fprintf('Data stored!\n\n');
  clear cfg_manart
end

% store settings table
delete(settings_file);
writetable(T, settings_file);

%% clear workspace
clear file_path cfg sourceList numOfSources i T settings_file lay ...
      noichan noichanStr
