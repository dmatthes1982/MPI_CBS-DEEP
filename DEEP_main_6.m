%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04c_preproc2/';
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

%% part 6

cprintf([0,0.6,0], '<strong>[6] - Narrow band filtering and Hilbert transform</strong>\n');
fprintf('\n');

% option to define passbands manually
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to use the default passbands?\n');
  cprintf([0,0.6,0], '-------------------\n');
  cprintf([0,0.6,0], 'theta:  4 - 7 Hz\n');
  cprintf([0,0.6,0], 'alpha:  8 - 12 Hz\n');
  cprintf([0,0.6,0], 'beta:   13 - 30 Hz\n');
  cprintf([0,0.6,0], 'gamma:  31 - 48 Hz\n');
  cprintf([0,0.6,0], '-------------------\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    passband = true;
  elseif strcmp('n', x)
    selection = true;
    passband = false;
  else
    selection = false;
  end
end
fprintf('\n');

%% passband specifications
if passband == true
  [pbSpec(1:4).freqRange]   = deal([4 7],[8 12],[13 30],[31 48]);
else
  passband = DEEP_pbSelectbox();
  [pbSpec(1:4).freqRange]   = deal(passband{:});
end
[pbSpec(1:4).fileSuffix]    = deal('Theta','Alpha','Beta','Gamma');
[pbSpec(1:4).name]          = deal('theta','alpha','beta','gamma');
[pbSpec(1:4).filtOrdBase]   = deal(500, 250, 250, 250);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bandpass filtering

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04c_preproc2/');
  cfg.filename    = sprintf('coSMIC_d%02d_04c_preproc2', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load preprocessed data...\n\n');
  DEEP_loadData( cfg );
  
  filtCoeffDiv = 500 / data_preproc2.mother.fsample;                        % estimate sample frequency dependent divisor of filter length

  % select only dual conditions
  cfg = [];
  cfg.part    = 'both';
  cfg.channel = 'all';
  cfg.trials  = [11,13,20,21,22,23];

  data_preproc2 = DEEP_selectdata(cfg, data_preproc2);

  % bandpass filter data
  for j = 1:1:numel(pbSpec)
    cfg           = [];
    cfg.bpfreq    = pbSpec(j).freqRange;
    cfg.filtorder = fix(pbSpec(j).filtOrdBase / filtCoeffDiv);
    cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'};

    data_bpfilt   = DEEP_bpFiltering(cfg, data_preproc2);
  
    % export the filtered data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
    cfg.filename    = sprintf('coSMIC_d%02d_06a_bpfilt%s', i, ...
                                pbSpec(j).fileSuffix);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', ...
                        cfg.sessionStr, '.mat');
                   
    fprintf(['Saving bandpass filtered data (%s: %g-%gHz) of dyad %d '...
              'in:\n'], pbSpec(j).name, pbSpec(j).freqRange, i);
    fprintf('%s ...\n', file_path);
    DEEP_saveData(cfg, 'data_bpfilt', data_bpfilt);
    fprintf('Data stored!\n\n');
    clear data_bpfilt
  end
  clear data_preproc2
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hilbert phase calculation

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);

  % calculate hilbert phase
  for j = 1:1:numel(pbSpec)
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
    cfg.filename    = sprintf('coSMIC_d%02d_06a_bpfilt%s', i, ...
                                pbSpec(j).fileSuffix);
    cfg.sessionStr  = sessionStr;

    fprintf('Load the at %s (%g-%gHz) bandpass filtered data...\n', ...
              pbSpec(j).name, pbSpec(j).freqRange);
    DEEP_loadData( cfg );

    data_hilbert = DEEP_hilbertPhase(data_bpfilt);

    % export the hilbert phase data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '06b_hilbert/');
    cfg.filename    = sprintf('coSMIC_d%02d_06b_hilbert%s', i, ...
                                pbSpec(j).fileSuffix);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf(['Saving Hilbert phase data (%s: %g-%gHz) of dyad %d  '...
              'in:\n'], pbSpec(j).name, pbSpec(j).freqRange, i);
    fprintf('%s ...\n', file_path);
    DEEP_saveData(cfg, 'data_hilbert', data_hilbert);
    fprintf('Data stored!\n\n');
    clear data_hilbert data_bpfilt
  end
end

%% clear workspace
clear cfg file_path numOfSources sourceList i filtCoeffDiv pbSpec j ...
      passband x selection
