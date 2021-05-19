function DEEP_saveData( cfg, varargin )
% DEEP_SAVEDATA stores the data of various structure elements (generally the
% DEEP_DATASTRUCTURE) into a MAT_File.
%
% Use as
%   DEEP_saveData( cfg, varargin )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01888/eegData/DualEEG_DEEP_processedData/01_raw/')
%   cfg.filename    = filename (default: 'DEEP_d01_01_raw')
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% This function requires the fieldtrip toolbox.
%
% SEE also SAVE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', '/data/pt_01888/eegData/DualEEG_DEEP_processedData/01_raw/');
filename    = ft_getopt(cfg, 'filename', 'DEEP_d01_01_raw');
sessionStr  = ft_getopt(cfg, 'sessionStr', '001');

% -------------------------------------------------------------------------
% Save data
% -------------------------------------------------------------------------
file_path = strcat(desFolder, filename, '_', sessionStr, '.mat');
inputElements = length(varargin);

if inputElements == 0
  error('No elements to save!');
elseif mod(inputElements, 2)
  error('Numbers of input are not even!');
else
  for i = 1:2:inputElements-1
    if ~isvarname(varargin{i})
      error('varargin{%d} is not a valid varname');
    else
      str = [varargin{i}, ' = varargin{i+1};'];
      eval(str);
    end
  end
end

if (~isempty(who('-regexp', '^data')))
  save(file_path, '-regexp','^data', '-v7.3');
elseif (~isempty(who('-regexp', '^cfg_')))
  save(file_path, '-regexp','^cfg_', '-v7.3');
end

end

