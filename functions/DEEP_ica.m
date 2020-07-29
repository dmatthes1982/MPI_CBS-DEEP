function [ data ] = DEEP_ica( cfg, data )
% DEEP_ICA conducts an independent component analysis on both
% participants
%
% Use as
%   [ data ] = DEEP_ica( cfg, data )
%
% where the input data have to be the result from DEEP_CONCATDATA
%
% The configuration options are
%   cfg.part          = participants which shall be processed: mother, child or both (default: both)
%   cfg.channel       = cell-array with channel selection (default = {'all', '-EOGV', '-EOGH', '-REF'})
%   cfg.numcomponent  = 'all' or number (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_CONCATDATA

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part            = ft_getopt(cfg, 'part', 'both');                           % participant selection
channel         = ft_getopt(cfg, 'channel', {'all', '-EOGV', '-EOGH', '-REF'});
numOfComponent  = ft_getopt(cfg, 'numcomponent', 'all');

if ~ismember(part, {'mother', 'child', 'both'})                             % check cfg.part definition
  error('cfg.part has to either ''mother'', ''child'' or ''both''.');
end

% -------------------------------------------------------------------------
% ICA decomposition
% -------------------------------------------------------------------------
cfg               = [];
cfg.method        = 'runica';
cfg.channel       = channel;
cfg.trials        = 'all';
cfg.numcomponent  = numOfComponent;
cfg.demean        = 'no';
cfg.updatesens    = 'no';
cfg.showcallinfo  = 'no';

if ismember(part, {'mother', 'both'})
  fprintf('\n<strong>ICA decomposition for mother...</strong>\n\n');
  data.mother = ft_componentanalysis(cfg, data.mother);
end

if ismember(part, {'child', 'both'})
  fprintf('\n<strong>ICA decomposition for child...</strong>\n\n');
  data.child = ft_componentanalysis(cfg, data.child);
end

if strcmp(part, 'mother')
  data = removefields(data, 'child');
elseif strcmp(part, 'child')
  data = removefields(data, 'mother');
end

end
