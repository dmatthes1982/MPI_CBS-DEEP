function [ num ] = DEEP_getSessionNum( cfg )
% DEEP_GETSESSIONNUM determines the highest session number of a specific 
% data file 
%
% Use as
%   [ num ] = DEEP_getSessionNum( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01888/eegData/DualEEG_coSMIC_processedData/')
%   cfg.subFolder   = name of subfolder (default: '01_raw/')
%   cfg.filename    = filename (default: 'coSMIC_d01_01_raw')
%
% This function requires the fieldtrip toolbox.

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', '/data/pt_01888/eegData/DualEEG_coSMIC_processedData/');
subFolder   = ft_getopt(cfg, 'subFolder', '01_raw/');
filename    = ft_getopt(cfg, 'filename', 'coSMIC_d01_01_raw');

% -------------------------------------------------------------------------
% Estimate highest session number
% -------------------------------------------------------------------------
file_path = strcat(desFolder, subFolder, filename, '_*.mat');

sessionList    = dir(file_path);
if isempty(sessionList)
  num = 0;
else
  sessionList   = struct2cell(sessionList);
  sessionList   = sessionList(1,:);
  numOfSessions = length(sessionList);

  sessionNum    = zeros(1, numOfSessions);
  filenameStr   = strcat(filename, '_%d.mat');
  
  for i=1:1:numOfSessions
    sessionNum(i) = sscanf(sessionList{i}, filenameStr);
  end

  num = max(sessionNum);
end

end

