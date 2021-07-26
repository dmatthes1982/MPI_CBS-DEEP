function DEEP_createTbl( cfg )
% DEEP_CREATETBL generates '*.xls' files for the documentation of the data 
% processing process. Currently three different types of doc files are
% supported.
%
% Use as
%   DEEP_createTbl( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01888/eegData/DualEEG_DEEP_processedData/00_settings/')
%   cfg.type        = type of documentation file (options: 'settings', 'plv')
%   cfg.param       = additional params for type 'plv' (options: 'theta', 'alpha', 'beta', 'gamma');
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% Explanation:
%   type settings - holds information about the selectable values: fsample, reference and ICAcorrVal
%   type plv      - holds the number of good trials for each condition in case of plv estimation
%
% This function requires the fieldtrip toolbox.

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', ...
          '/data/pt_01888/eegData/DualEEG_DEEP_processedData/00_settings/');
type        = ft_getopt(cfg, 'type', []);
param       = ft_getopt(cfg, 'param', []);
sessionStr  = ft_getopt(cfg, 'sessionStr', []);

if isempty(type)
  error(['cfg.type has to be specified. It could be either ''settings'''...
         ' or ''plv''.']);
end

if strcmp(type, 'plv')
  if isempty(param)
    error([ 'cfg.param has to be specified. Selectable options: '...
            '''theta'', ''alpha'', ''beta'', ''gamma''']);
  end
end

if isempty(sessionStr)
  error('cfg.sessionStr has to be specified');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Create table
% -------------------------------------------------------------------------
switch type
  case 'settings'
    T = table(1,{'unknown'},{'unknown'},{'unknown'},{'unknown'},0,...
                {'unknown'},{'unknown'},{'unknown'},0,0,{'unknown'},...
                {'unknown'},{'unknown'},{'unknown'},{'unknown'},...
                {'unknown'},{'unknown'},{'unknown'});
    T.Properties.VariableNames = ...
        {'dyad', 'noiChan', 'badChanMother', 'badChanChild', 'reference', ...
         'ICAcorrValMother', 'ICAcompMother', 'ICAcompChild', ...
         'artMethod', 'artTholdMother', 'artTholdChild', 'artDeadSegs', ...
         'artChanMother', 'artChanChild', 'pbSpecMother', 'pbSpecChild', ...
         'artRejectPLV', 'plvSegmentLengths', 'artRejectPow'};
    filepath = [desFolder type '_' sessionStr '.xls'];
    writetable(T, filepath);
  case 'plv'
    A(1) = {1};
    A(2:length(generalDefinitions.condNumDual)+1) = {0};
    T = cell2table(A);
    B = num2cell(generalDefinitions.condNumDual);
    C = cellfun(@(x) sprintf('S%d', x), B, 'UniformOutput', 0);                            
    VarNames = [{'dyad'} C];
    T.Properties.VariableNames = VarNames;
    filepath = [desFolder type '_' param '_' sessionStr '.xls'];
    writetable(T, filepath); 
  otherwise
    error('cfg.type is not valid. Use either ''settings'' or ''plv''.');
end

end
