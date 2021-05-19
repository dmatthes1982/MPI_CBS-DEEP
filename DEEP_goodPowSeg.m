% -------------------------------------------------------------------------
% Add directory and subfolders to path, clear workspace, clear command
% windwow
% -------------------------------------------------------------------------
DEEP_init;

cprintf([0,0.6,0], '<strong>---------------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>DEEP: A dual-EEG Pipeline for adult and infant hyperscanning studies.</strong>\n');
cprintf([0,0.6,0], '<strong>Export number of all and of good segments per condition,</strong>\n');
cprintf([0,0.6,0], '<strong>which are used for power estimation.</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2019, Daniel Matthes, MPI CBS\n');
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

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
tmpPath = strcat(path, '08b_pwelch/');

fileList     = dir([tmpPath, 'DEEP_d*_08b_pwelch_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for i=1:1:numOfFiles
  fileListCopy{i} = strsplit(fileList{i}, '08b_pwelch_');
  fileListCopy{i} = fileListCopy{i}{end};
  sessionNum(i) = sscanf(fileListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
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
  for i = sessionNum
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
      sessionStr = sprintf('%03d', x);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

fprintf('\n');

clear sessionNum fileListCopy y userList match filePath cmdout attrib

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

conditions = [generalDefinitions.condNum]';

clear filepath generalDefinitions

% -------------------------------------------------------------------------
% Extract and export number of all and number of good segments
% -------------------------------------------------------------------------
tmpPath = strcat(path, '08b_pwelch/');

fileList     = dir([tmpPath, ['DEEP_d*_08b_pwelch_' sessionStr '.mat']]);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles  = length(fileList);
numOfPart   = zeros(1, numOfFiles);
for i = 1:1:numOfFiles
  numOfPart(i) = sscanf(fileList{i}, strcat('DEEP_d%d*', sessionStr, '.mat'));
end

rows = num2cell(numOfPart);
rows_part1 = cellfun(@(x) sprintf('P%02d_all', x), rows, ...
                          'UniformOutput', false);
rows_part2 = cellfun(@(x) sprintf('P%02d_exp_good', x), rows, ...
                          'UniformOutput', false);
rows_part3 = cellfun(@(x) sprintf('P%02d_child_good', x), rows, ...
                          'UniformOutput', false);

rows = [rows_part1; rows_part2; rows_part3];
rows = reshape(rows,[],1);

headline = cellfun(@(x) sprintf('S%d', x), num2cell(conditions)', ...
                    'UniformOutput', false);

cell_array = [rows, num2cell(zeros(numel(rows), numel(conditions)))];

T = cell2table(cell_array);
T.Properties.VariableNames = [{'participants'}, headline];                  % create empty table with variable names

clear headline rows_part1 rows_part2 rows_part3 cell_array conditions ...
      rows

fprintf('Import of data...\n\n');
f = waitbar(0,'Please wait...');

for i = 1:1:length(fileList)
  file_path = strcat(tmpPath, fileList{i});
  load(file_path, 'data_pwelch');

  warning off;
  T(3*i-2, 2:end) = num2cell(data_pwelch.child.numOfAllSeg');
  T(3*i-1, 2:end) = num2cell(data_pwelch.mother.numOfGoodSeg');
  T(3*i,   2:end) = num2cell(data_pwelch.child.numOfGoodSeg');
  warning on;
  
  waitbar(i/numOfFiles, f, 'Please wait...');
end

close(f);
clear f

file_path = strcat(path, '00_settings/', 'numOfGoodPowSeg_', sessionStr, '.xls');
fprintf('The default file path is: %s\n', file_path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default file path and possibly overwrite an existing file?\n');
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
  [filename, file_path] = uiputfile(file_path, 'Specify a destination file...');
  file_path = [file_path, filename];
end

if exist(file_path, 'file')
  delete(file_path);
end
writetable(T, file_path);

fprintf('\nNumber of all and good segments of all selected participant exported to:\n');
fprintf('%s\n', file_path);

%% clear workspace
clear tmpPath path sessionStr fileList numOfFiles numOfPart i ...
      file_path data_pwelch T newPaths filename selection x
