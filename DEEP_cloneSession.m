% -------------------------------------------------------------------------
% Add directory and subfolders to path, clear workspace, clear command
% windwow
% -------------------------------------------------------------------------
DEEP_init;

cprintf([0,0.6,0], '<strong>---------------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>DEEP: A dual-EEG Pipeline for adult and infant hyperscanning studies.</strong>\n');
cprintf([0,0.6,0], '<strong>Clone session script</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018-2019, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>---------------------------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
path = '/data/pt_01888/eegData/DualEEG_DEEP_processedData/';

fprintf('\nThe default path is: %s\n', path);

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
  path = uigetdir(pwd, 'Select folder...');
  path = strcat(path, '/');
end
clear newPaths

folderList = dir(path);
folderList = struct2cell(folderList);
folderList = folderList(1,3:end)';
if ~strcmp(folderList{1}, '00_settings')
  cprintf([1,0.5,0], '\nSelected path has no DEEP data!\n');
  return;
end

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
tmpPath = strcat(path, '01a_raw/');

fileList     = dir([tmpPath, 'DEEP_d*_01a_raw_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

if numOfFiles == 0
  fprintf('\n<strong>No sessions are avialable at this path!</strong>\n');
  clear tmpPath fileList numOfFiles path selection x
  return;
end

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for i=1:1:numOfFiles
  fileListCopy{i} = strsplit(fileList{i}, '01a_raw_');
  fileListCopy{i} = fileListCopy{i}{end};
  sessionNum(i) = sscanf(fileListCopy{i}, '%d.mat');
end

sessionNum    = unique(sessionNum);
newSessionNum = max(sessionNum) + 1;
newSessionStr = sprintf('%03d', newSessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

selection = false;
while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
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
      sessionNum = x;
      sessionStr = sprintf('%03d', x);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

fprintf('\n');

clear fileList numOfFiles fileListCopy y userList match ...
      filePath cmdout attrib

% -------------------------------------------------------------------------
% Clone session
% -------------------------------------------------------------------------
fprintf('<strong>Creating new session number %d...</strong>\n\n', newSessionNum);
for i = 1:1:length(folderList)
  folder = folderList{i};
  fprintf('Cloning data in folder: %s...\n', folder);
  
  tmpPath   = strcat(path, folder);
  homePath  = fileparts(mfilename('fullpath'));
  
  fileList      = dir(tmpPath);
  fileList      = struct2cell(fileList);
  fileList      = fileList(1,~cell2mat(fileList(5,:)))';
  tf            = ~startsWith(fileList,'.');
  fileList      = fileList(tf); 
  fileList      = cellfun(@(x) strsplit(x, '.'), fileList, ...
                          'UniformOutput', false);
  fileList      = cat(1, fileList{:});
  fileExt       = unique(fileList(:,2));
  fileList      = fileList(:,1);
  sessionFiles  = regexp(fileList, sessionStr);
  sessionFiles  = cellfun(@(x) ~isempty(x), sessionFiles);
  fileList      = fileList(sessionFiles);
  fileList      = cellfun(@(x) strrep(x, sessionStr, ''), fileList, ...
                  'UniformOutput',false);
  cd(tmpPath);
  for j = 1:1:length(fileList)
    file = fileList{j};
    copyfile( strcat(file, sessionStr, '.', fileExt{1}), ...
              strcat(file, newSessionStr, '.', fileExt{1}) ); 
  end
  cd(homePath);
end

fprintf('\n<strong>Cloning of session %d completed. Session %d created!</strong>\n', ...
        sessionNum, newSessionNum);

%% clear workspace
clear folder folderList i j newSessionNum path selection sessionNum ...
      tmpPath x sessionStr file fileExt fileList homePath sessionFiles ...
      newSessionStr tf
