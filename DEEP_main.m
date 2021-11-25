% -------------------------------------------------------------------------
% Add directory and subfolders to path, clear workspace, clear command
% windwow
% -------------------------------------------------------------------------
DEEP_init;

% -------------------------------------------------------------------------
% Set number of cores/threads to 4
% -------------------------------------------------------------------------
LASTN = maxNumCompThreads(4);                                               %#ok<NASGU>
clear LASTN

cprintf([0,0.6,0], '<strong>---------------------------------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>DEEP: A dual-EEG Pipeline for adult and infant hyperscanning studies. - data processing</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.2</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018-2021, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>---------------------------------------------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
srcPath = '/data/pt_01888/eegData/DualEEG_DEEP_rawData/';
desPath = '/data/pt_01888/eegData/DualEEG_DEEP_processedData/';

fprintf('\nThe default paths are:\n');
fprintf('Source: %s\n',srcPath);
fprintf('Destination: %s\n',desPath);

selection = false;
while selection == false
  fprintf('\nDo you want to select the default paths?\n');
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
  srcPath = uigetdir(pwd, 'Select Source Folder...');
  desPath = uigetdir(strcat(srcPath,'/..'), ...
                      'Select Destination Folder...');
  srcPath = strcat(srcPath, '/');
  desPath = strcat(desPath, '/');
end

if ~exist(strcat(desPath, '00_settings'), 'dir')
  mkdir(strcat(desPath, '00_settings'));
end
if ~exist(strcat(desPath, '01a_raw'), 'dir')
  mkdir(strcat(desPath, '01a_raw'));
end
if ~exist(strcat(desPath, '01b_manart'), 'dir')
  mkdir(strcat(desPath, '01b_manart'));
end
if ~exist(strcat(desPath, '02a_badchan'), 'dir')
  mkdir(strcat(desPath, '02a_badchan'));
end
if ~exist(strcat(desPath, '02b_preproc1'), 'dir')
  mkdir(strcat(desPath, '02b_preproc1'));
end
if ~exist(strcat(desPath, '03a_icacomp'), 'dir')
  mkdir(strcat(desPath, '03a_icacomp'));
end
if ~exist(strcat(desPath, '03b_eogchan'), 'dir')
  mkdir(strcat(desPath, '03b_eogchan'));
end
if ~exist(strcat(desPath, '04a_eogcomp'), 'dir')
  mkdir(strcat(desPath, '04a_eogcomp'));
end
if ~exist(strcat(desPath, '04b_eyecor'), 'dir')
  mkdir(strcat(desPath, '04b_eyecor'));
end
if ~exist(strcat(desPath, '04c_preproc2'), 'dir')
  mkdir(strcat(desPath, '04c_preproc2'));
end
if ~exist(strcat(desPath, '05a_autoart'), 'dir')
  mkdir(strcat(desPath, '05a_autoart'));
end
if ~exist(strcat(desPath, '05b_allart'), 'dir')
  mkdir(strcat(desPath, '05b_allart'));
end
if ~exist(strcat(desPath, '06a_bpfilt'), 'dir')
  mkdir(strcat(desPath, '06a_bpfilt'));
end
if ~exist(strcat(desPath, '06b_hilbert'), 'dir')
  mkdir(strcat(desPath, '06b_hilbert'));
end
if ~exist(strcat(desPath, '07a_hilbertSegment'), 'dir')
  mkdir(strcat(desPath, '07a_hilbertSegment'));
end
if ~exist(strcat(desPath, '07b_plv'), 'dir')
  mkdir(strcat(desPath, '07b_plv'));
end
if ~exist(strcat(desPath, '07c_mplv'), 'dir')
  mkdir(strcat(desPath, '07c_mplv'));
end
if ~exist(strcat(desPath, '08a_tfr'), 'dir')
  mkdir(strcat(desPath, '08a_tfr'));
end
if ~exist(strcat(desPath, '08b_pwelch'), 'dir')
  mkdir(strcat(desPath, '08b_pwelch'));
end
if ~exist(strcat(desPath, '09a_mplvod'), 'dir')
  mkdir(strcat(desPath, '09a_mplvod'));
end
if ~exist(strcat(desPath, '09b_tfrod'), 'dir')
  mkdir(strcat(desPath, '09b_tfrod'));
end
if ~exist(strcat(desPath, '09c_pwelchod'), 'dir')
  mkdir(strcat(desPath, '09c_pwelchod'));
end

clear sessionStr numOfPart newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(desPath, '01a_raw/');

sessionList     = dir([tmpPath, 'DEEP_d*_01a_raw_*.mat']);
sessionList     = struct2cell(sessionList);
sessionList     = sessionList(1,:);
numOfSessions   = length(sessionList);

sessionNum      = zeros(1, numOfSessions);
sessionListCopy = sessionList;

for i=1:1:numOfSessions
  sessionListCopy{i} = strsplit(sessionList{i}, '01a_raw_');
  sessionListCopy{i} = sessionListCopy{i}{end};
  sessionNum(i) = sscanf(sessionListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(sessionListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, sessionList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
  end
  fprintf('\n');
  fprintf('Please select one session or create a new one:\n');
  fprintf('[0] - Create new session\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      session = x;
      sessionStr = sprintf('%03d', session);
    elseif x == 0  
      selection = true;
      session = x;
      if ~isempty(max(sessionNum))
        sessionStr = sprintf('%03d', max(sessionNum) + 1);
      else
        sessionStr = sprintf('%03d', 1);
      end
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

clear tmpPath sessionListCopy userList match filePath cmdout attrib 

% -------------------------------------------------------------------------
% General selection of dyads
% -------------------------------------------------------------------------
selection = false;

while selection == false
  fprintf('\nPlease select one option:\n');
  fprintf('[1] - Process all available dyads\n');
  fprintf('[2] - Process all new dyads\n');
  fprintf('[3] - Process specific dyads\n');
  fprintf('[4] - Quit data processing\n\n');
  x = input('Option: ');
  
  switch x
    case 1
      selection = true;
      dyadsSpec = 'all';
    case 2
      selection = true;
      dyadsSpec = 'new';
    case 3
      selection = true;
      dyadsSpec = 'specific';
    case 4
      fprintf('\nData processing aborted.\n');
      clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions sessionStr
      return;
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

% -------------------------------------------------------------------------
% General selection of preprocessing option
% -------------------------------------------------------------------------
selection = false;

if session == 0
  fprintf('\nA new session always will start with part:\n');
  fprintf('[1] - Import raw data\n');
  part = 1;
else
  while selection == false
    fprintf('\nPlease select what you want to do with the selected dyads:\n');
    fprintf('[1]  - Data import\n');
    fprintf('[2]  - Preproc I: bad channel detection, filtering\n');
    fprintf('[3]  - ICA decomposition\n');
    fprintf('[4]  - Preproc II: ICA-based artifact correction, bad channel recovery, re-referencing\n');
    fprintf('[5]  - Automatic and manual artifact detection\n');
    fprintf('[6]  - Narrow band filtering and Hilbert transform\n'); 
    fprintf('[7]  - Estimation of Phase Locking Values (PLV) or cross Phase Locking Values (crossPLV)\n');
    fprintf('[8]  - Power analysis (TFR, pWelch)\n');
    fprintf('[9]  - Averaging over dyads\n');
    fprintf('[10] - Quit data processing\n\n');
    x = input('Option: ');
  
    switch x
      case 1
        part = 1;
        selection = true;
      case 2
        part = 2;
        selection = true;
      case 3
        part = 3;
        selection = true;
      case 4
        part = 4;
        selection = true;
      case 5
        part = 5;
        selection = true;
      case 6
        part = 6;
        selection = true;
      case 7
        part = 7;
        selection = true;
      case 8
        part = 8;
        selection = true;
      case 9
        part = 9;
        selection = true;
      case 10
        fprintf('\nData processing aborted.\n');
        clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions dyadsSpec sessionStr
        return;
      otherwise
        selection = false;
        cprintf([1,0.5,0], 'Wrong input!\n');
    end
  end
end

% -------------------------------------------------------------------------
% Specific selection of dyads
% -------------------------------------------------------------------------
sourceList    = dir([srcPath, '/*.vhdr']);
sourceList    = struct2cell(sourceList);
sourceList    = sourceList(1,:);
numOfSources  = length(sourceList);
fileNum       = zeros(1, numOfSources);

for i=1:1:numOfSources
  fileNum(i)     = sscanf(sourceList{i}, 'DEEP_all_P%d.vhdr');
end

switch part
  case 1
    fileNamePre = [];
    tmpPath = strcat(desPath, '01a_raw/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_01a_raw_', sessionStr, '.mat');
  case 2
    tmpPath = strcat(desPath, '01a_raw/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_01a_raw_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '02b_preproc1/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_02b_preproc1_', sessionStr, '.mat');
  case 3
    tmpPath = strcat(desPath, '02b_preproc1/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_02b_preproc1_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '03b_eogchan/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_03b_eogchan_', sessionStr, '.mat');
  case 4
    tmpPath = strcat(desPath, '03b_eogchan/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_03b_eogchan_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '04c_preproc2/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_04c_preproc2_', sessionStr, '.mat');
  case 5
    tmpPath = strcat(desPath, '04c_preproc2/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_04c_preproc2_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '05b_allart/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_05b_allart_', sessionStr, '.mat');
  case 6
    tmpPath = strcat(desPath, '04c_preproc2/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_04c_preproc2_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '06b_hilbert/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_06b_hilbertGamma_', sessionStr, '.mat');
  case 7
    tmpPath = strcat(desPath, '06b_hilbert/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_06b_hilbertGamma_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '07b_mplv/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_07b_mplvGamma_', sessionStr, '.mat');
  case 8
    tmpPath = strcat(desPath, '04c_preproc2/');
    fileNamePre = strcat(tmpPath, 'DEEP_d*_04c_preproc2_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '08b_pwelch/');
    fileNamePost = strcat(tmpPath, 'DEEP_d*_08b_pwelch_', sessionStr, '.mat');
  case 9
    fileNamePre = 0;
  otherwise
    error('Something unexpected happend. part = %d is not defined' ...
          , part);
end

if ~isequal(fileNamePre, 0)
  if isempty(fileNamePre)
    numOfPrePart = fileNum;
  else
    fileListPre = dir(fileNamePre);
    if isempty(fileListPre)
      cprintf([1,0.5,0], ['Selected part [%d] can not be executed, no '...'
            'input data available\n Please choose a previous part.\n'], part);
      clear desPath fileNamePost fileNamePre fileNum i numOfSources ...
            selection sourceList srcPath x y dyadsSpec fileListPre ... 
            sessionList sessionNum numOfSessions session part sessionStr ...
            tmpPath
      return;
    else
      fileListPre = struct2cell(fileListPre);
      fileListPre = fileListPre(1,:);
      numOfFiles  = length(fileListPre);
      numOfPrePart = zeros(1, numOfFiles);
      for i=1:1:numOfFiles
        numOfPrePart(i) = sscanf(fileListPre{i}, strcat('DEEP_d%d*', sessionStr, '.mat'));
      end
    end
  end

  if strcmp(dyadsSpec, 'all')                                               % process all dyads
    numOfPart = numOfPrePart;
  elseif strcmp(dyadsSpec, 'specific')                                      % process specific dyads
    listOfPartStr = cellfun(@(x) sprintf('%d', x), ...                      % prepare a cell array with all possible options for the following list dialog
                        num2cell(numOfPrePart), 'UniformOutput', false);

    fprintf('\nSelection of specific dyads...\n');

    sel = listdlg('PromptString',' Select dyads...', ...                    % open the dialog window --> the user can select the dyads of interest
                'ListString', listOfPartStr, ...
                'ListSize', [220, 300] );

    numOfPart = numOfPrePart(sel);
    clear listOfPartStr sel
  elseif strcmp(dyadsSpec, 'new')                                           % process only new dyads
    if session == 0
      numOfPart = numOfPrePart;
    else
      fileListPost = dir(fileNamePost);
      if isempty(fileListPost)
        numOfPostPart = [];
      else
        fileListPost = struct2cell(fileListPost);
        fileListPost = fileListPost(1,:);
        numOfFiles  = length(fileListPost);
        numOfPostPart = zeros(1, numOfFiles);
        for i=1:1:numOfFiles
          numOfPostPart(i) = sscanf(fileListPost{i}, strcat('DEEP_d%d*', sessionStr, '.mat'));
        end
      end
  
      numOfPart = numOfPrePart(~ismember(numOfPrePart, numOfPostPart));
      if isempty(numOfPart)
        cprintf([1,0.5,0], 'No new dyads available!\n');
        fprintf('Data processing aborted.\n');
        clear desPath fileNamePost fileNamePre fileNum i numOfPrePart ...
              numOfSources selection sourceList srcPath x y dyadsSpec ...
              fileListPost fileListPre numOfPostPart sessionList ...
              numOfFiles sessionNum numOfSessions session numOfPart ...
              part sessionStr dyads tmpPath
        return;
      end
    end
  end

  y = sprintf('%d ', numOfPart);
  fprintf(['\nThe following dyads will be processed ' ...
         'in the selected part [%d]:\n'],  part);
  fprintf('%s\n\n', y);

  clear fileNamePost fileNamePre fileNum i numOfPrePart ...
        numOfSources selection sourceList x y dyads fileListPost ...
        fileListPre numOfPostPart sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath
else
  fprintf('\n');
  clear fileNamePost fileNamePre fileNum i numOfSources selection ...
        sourceList x y dyads sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath
end

% -------------------------------------------------------------------------
% Data processing main loop
% -------------------------------------------------------------------------
sessionStatus = true;
sessionPart = part;

clear part;

while sessionStatus == true
  switch sessionPart
    case 1
      DEEP_main_1;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[2] - Preproc I: bad channel detection, filtering?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 2;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 2
      DEEP_main_2;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[3] - ICA decomposition?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 3;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 3
      DEEP_main_3;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[4] - Preproc II: ICA-based artifact correction, bad channel recovery, re-referencing?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 4;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 4
      DEEP_main_4;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[5] - Automatic and manual detection of artifacts?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 5;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 5
      DEEP_main_5;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[6]  - Narrow band filtering and Hilbert transform?</strong>\n');
        fprintf('<strong>[8]  - Power analysis (TFR, pWelch)?</strong>\n');
        fprintf('<strong>[10] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 6
            selection = true;
            sessionStatus = true;
            sessionPart = 6;
          case 8
            selection = true;
            sessionStatus = true;
            sessionPart = 8;
          case 10
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 6
      DEEP_main_6;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[7] - Estimation of Phase Locking Values (PLV)?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 7;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end  
    case 7
      DEEP_main_7;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[8]  - Power analysis (TFR, pWelch)?</strong>\n');
        fprintf('<strong>[9]  - Averaging over dyads?</strong>\n');
        fprintf('<strong>[10] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 8
            selection = true;
            sessionStatus = true;
            sessionPart = 8;
          case 9
            selection = true;
            sessionStatus = true;
            sessionPart = 9;
         case 10
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 8
      DEEP_main_8;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[9] - Averaging over dyads?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 9;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 9
      DEEP_main_9;
      sessionStatus = false;
    otherwise
      sessionStatus = false;
  end
  fprintf('\n');
end

fprintf('<strong>Data processing finished.</strong>\n');
fprintf('<strong>Session will be closed.</strong>\n');

clear sessionStr numOfPart srcPath desPath sessionPart sessionStatus ...
      selection x
