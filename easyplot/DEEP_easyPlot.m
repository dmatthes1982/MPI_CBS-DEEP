function DEEP_easyPlot( cfg, data )
% DEEP_EASYPLOT is a function, which makes it easier to plot the data of 
% a specific condition and trial from the DEEP_DATASTRUCTURE.
%
% Use as
%   DEEP_easyPlot(cfg, data)
%
% where the input data can be the results of DEEP_IMPORTDATASET or
% DEEP_PREPROCESSING
%
% The configuration options are
%   cfg.part      = participant identifier, options: 'mother' or 'child' (default: 'mother')
%   cfg.condition = condition (default: 11 or 'DFreePlay', see DEEP_DATASTRUCTURE)
%   cfg.electrode = number of electrode (default: 'Cz')
%   cfg.trial     = number of trial (default: 1)
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_DATASTRUCTURE, PLOT

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part = ft_getopt(cfg, 'part', 'mother');
cond = ft_getopt(cfg, 'condition', 11);
elec = ft_getopt(cfg, 'electrode', 'Cz');
trl  = ft_getopt(cfg, 'trial', 1);

if ~ismember(part, {'mother', 'child'})                                     % check cfg.part definition
  error('cfg.part has to either ''mother'' or ''child''.');
end

switch part
  case 'mother'
    data = data.mother;
  case 'child'
    data = data.child;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));


cond    = DEEP_checkCondition( cond );                                    % check cfg.condition definition    
trials  = find(trialinfo == cond);
if isempty(trials)
  error('The selected dataset contains no condition %d.', cond);
else
  numTrials = length(trials);
  if numTrials < trl                                                        % check cfg.trial definition
    error('The selected dataset contains only %d trials.', numTrials);
  else
    trlInCond = trl;
    trl = trl-1 + trials(1);
  end
end

if isnumeric(elec)                                                          % check cfg.electrode definition
  if elec < 1 || elec > 32
    error('cfg.elec hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elec = find(strcmp(label, elec));
  if isempty(elec)
    error('cfg.elec hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

% -------------------------------------------------------------------------
% Plot timeline
% -------------------------------------------------------------------------
plot(data.time{trl}, data.trial{trl}(elec,:));
title(sprintf('Part.: %s - Cond.: %d - Elec.: %s - Trial: %d', ...
      part, cond, strrep(data.label{elec}, '_', '\_'), trlInCond));      

xlabel('time in seconds');
ylabel('voltage in \muV');

end
