%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '03b_eogchan/';
  cfg.filename  = 'coSMIC_d01_03b_eogchan';
  sessionStr    = sprintf('%03d', DEEP_getSessionNum( cfg ));             % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01888/eegData/DualEEG_coSMIC_processedData/';         % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eogcomp data folder
  sourceList    = dir([strcat(desPath, '03b_eogchan/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('coSMIC_d%d_03b_eogchan_', sessionStr, '.mat'));
  end
end

%% part 4
% Estimation and correction of eye artifacts
% Processing steps:
% 1. Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
%    confirmity)
% 2. Verify the estimated components by using the ft_icabrowser function
%    and add further bad components to the selection
% 3. Correct EEG data
% 4. Recovery of bad channels
% 5. Re-referencing

cprintf([0,0.6,0], '<strong>[4] - Preproc II: ICA-based artifact correction, bad channel recovery, re-referencing</strong>\n');
fprintf('\n');

% determine available channels
fprintf('Determine available channels...\n');
cfg             = [];
cfg.srcFolder   = strcat(desPath, '02b_preproc1/');
cfg.filename    = sprintf('coSMIC_d%02d_02b_preproc1', numOfPart(1));
cfg.sessionStr  = sessionStr;

DEEP_loadData( cfg );
mastoid = ismember('TP10', data_preproc1.mother.label);
clear data_preproc1;

% select favoured reference
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select favoured reference:\n');
  fprintf('[1] - Common average reference\n');
  if(mastoid == true)
    fprintf('[2] - Linked mastoid (''TP9'', ''TP10'')\n');
  end
  fprintf('[3] - Robust average reference\n');
  x = input('Option: ');

  if x == 1
     selection = true;
     refchannel = {'all', '-V1', '-V2'};
     reference = {'CAR'};
  elseif x == 2 && mastoid == true
     selection = true;
     refchannel = 'TP10';
     reference = {'LM'};
  elseif x == 3                                                             %IRA_MOD
     selection = true;
     refchannel = 'RAR';
     reference = {'RobustAvg'};     
  else
    cprintf([1,0.5,0], 'Wrong input!\n\n');
  end
end
fprintf('\n');

% correlation threshold
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to use the default threshold (0.8) for EOG-artifact estimation with mother data?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    threshold = 0.8;
  elseif strcmp('n', x)
    selection = true;
    threshold = [];
  else
    selection = false;
  end
end
fprintf('\n');

if isempty(threshold)
  selection = false;
  while selection == false
    cprintf([0,0.6,0], 'Specify a threshold value for the mother dataset in a range between 0 and 1!\n');
    x = input('Value: ');
    if isnumeric(x)
      if (x < 0 || x > 1)
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      else
        threshold = x;
        selection = true;
      end
    else
      cprintf([1,0.5,0], 'Wrong input!\n');
      selection = false;
    end
  end
fprintf('\n');  
end

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  DEEP_createTbl(cfg);                                                    % create settings file
end

T = readtable(settings_file);                                               % update settings table
warning off;
T.reference(numOfPart) = reference;
T.ICAcorrValMother(numOfPart) = threshold;
warning on;

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);

  %% ICA-based artifact correction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>ICA-based artifact correction</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('coSMIC_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load ICA result...\n');
  DEEP_loadData( cfg );
  
  cfg.srcFolder   = strcat(desPath, '03b_eogchan/');
  cfg.filename    = sprintf('coSMIC_d%02d_03b_eogchan', i);
  
  fprintf('Load original EOG channels...\n\n');
  DEEP_loadData( cfg );
  
  % Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
  % confirmity)
  cfg           = [];
  cfg.part      = 'both';
  cfg.threshold = threshold;
  
  data_eogcomp  = DEEP_detEOGComp(cfg, data_icacomp, data_eogchan);
  
  clear data_eogchan
  fprintf('\n');
  
  % Verify EOG-like ICA Components and add further bad components to the
  % selection
  cfg           = [];
  cfg.part      = 'both';

  data_eogcomp  = DEEP_selectBadComp(cfg, data_eogcomp, data_icacomp);
  
  clear data_icacomp

  % export the selected ICA components and the unmixing matrix into
  % a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04a_eogcomp/');
  cfg.filename    = sprintf('coSMIC_d%02d_04a_eogcomp', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The eye-artifact related components and the unmixing matrix of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'data_eogcomp', data_eogcomp);
  fprintf('Data stored!\n\n');

  % add selected ICA components to the settings file
  if isempty(data_eogcomp.mother.elements)
    ICAcompMother = {'---'};
  else
    ICAcompMother = {strjoin(data_eogcomp.mother.elements,',')};
  end
  if isempty(data_eogcomp.child.elements)
    ICAcompChild = {'---'};
  else
    ICAcompChild = {strjoin(data_eogcomp.child.elements,',')};
  end
  warning off;
  T.ICAcompMother(i)  = ICAcompMother;
  T.ICAcompChild(i)   = ICAcompChild;
  warning on;

  delete(settings_file);
  writetable(T, settings_file);

  % load basic bandpass filtered data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02b_preproc1/');
  cfg.filename    = sprintf('coSMIC_d%02d_02b_preproc1', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load bandpass filtered data...\n');
  DEEP_loadData( cfg );
  
  % correct EEG signals
  cfg           = [];
  cfg.part      = 'both';

  data_eyecor = DEEP_correctSignals(cfg, data_eogcomp, data_preproc1);
  
  clear data_eogcomp data_preproc1
  fprintf('\n');

  % export the reviced data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04b_eyecor/');
  cfg.filename    = sprintf('coSMIC_d%02d_04b_eyecor', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The reviced data (from eye artifacts) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'data_eyecor', data_eyecor);
  fprintf('Data stored!\n\n');

  %% Recovery of bad channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Bad channel recovery</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02a_badchan/');
  cfg.filename    = sprintf('coSMIC_d%02d_02a_badchan', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load bad channels specification...\n');
  DEEP_loadData( cfg );

  data_eyecor = DEEP_repairBadChan( data_badchan, data_eyecor );
  
  %% re-referencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Rereferencing</strong>\n');

  cfg                   = [];
  cfg.refchannel        = refchannel;

  ft_info off;
  
  if strcmp('RobustAvg', reference(1))                                      %IRA_MOD
      data_preproc2 = DEEP_robustRef(data_eyecor, data_badchan);
  else
      data_preproc2 = DEEP_reref( cfg, data_eyecor);
  end
  clear data_badchan
  
  ft_info on;

  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04c_preproc2/');
  cfg.filename    = sprintf('coSMIC_d%02d_04c_preproc2', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The clean and re-referenced data of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  DEEP_saveData(cfg, 'data_preproc2', data_preproc2);
  fprintf('Data stored!\n\n');
  clear data_preproc2 data_eyecor data_badchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i threshold selection x T ...
      settings_file ICAcompMother ICAcompChild reference refchannel mastoid
