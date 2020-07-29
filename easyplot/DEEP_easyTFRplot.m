function DEEP_easyTFRplot(cfg, data)
% DEEP_EASYTFRPLOT is a function, which makes it easier to plot a
% time-frequency-spectrum of a specific condition and trial from the 
% DEEP_DATASTRUCTURE.
%
% Use as
%   DEEP_easyTFRPlot(cfg, data)
%
% where the input data is a results from DEEP_TIMEFREQANALYSIS.
%
% The configuration options are 
%   cfg.part        = participant identifier, options: 'mother' or 'child' (default: 'mother')
%   cfg.condition   = condition (default: 11 or 'DFreePlay', see DEEP_DATASTRUCTURE)
%   cfg.electrode   = number of electrode (default: 'Cz')
%   cfg.trial       = number of trial (default: 1)
%   cfg.freqlim     = [begin end] (default: [2 50])
%   cfg.timelim     = [begin end] (default: [4 116])
%
% This function requires the fieldtrip toolbox
%
% See also FT_SINGLEPLOTTFR, DEEP_TIMEFREQANALYSIS, DEEP_DATASTRUCTURE

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 'mother');
condition = ft_getopt(cfg, 'condition', 11);
elec      = ft_getopt(cfg, 'electrode', 'Cz');
trl       = ft_getopt(cfg, 'trial', 1);
freqlim   = ft_getopt(cfg, 'freqlim', [2 50]);
timelim   = ft_getopt(cfg, 'timelim', [4 116]);

if ~ismember(part, {'mother', 'child'})                                     % check cfg.part definition
  error('cfg.part has to either ''mother'' or ''child''.');
end

switch part                                                                 % extract selected participant
    case 'mother'
    data = data.mother;
  case 'child'
    data = data.child;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));

condition    = DEEP_checkCondition( condition );                          % check cfg.condition definition
trials  = find(trialinfo == condition);
if isempty(trials)
  error('The selected dataset contains no condition %d.', condition);
else
  numTrials = length(trials);
  if numTrials < trl                                                        % check cfg.trial definition
    error('The selected dataset contains only %d trials in condition %d.',...
            numTrials, condition);
  else
    trlInCond = trl;
    trl = trl-1 + trials(1);
  end
end

if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  if ischar(elec)
    elec = {elec};
  end
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

% -------------------------------------------------------------------------
% Plot time frequency spectrum
% -------------------------------------------------------------------------
ft_warning off;

cfg                 = [];                                                       
cfg.maskstyle       = 'saturation';
cfg.xlim            = timelim;
cfg.ylim            = freqlim;
cfg.zlim            = 'maxmin';
cfg.trials          = trl;                                                  % select trial (or 'all' trials)
cfg.channel         = elec;
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

colormap jet;                                                               % use the older and more common colormap

ft_singleplotTFR(cfg, data);
labelString = strjoin(data.label(elec), ',');
title(sprintf('Part.: %s - Cond.: %d - Elec.: %s - Trial: %d', ...
      part, condition, labelString, trlInCond));

xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel

ft_warning on;

end
