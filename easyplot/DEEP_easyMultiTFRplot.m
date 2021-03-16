function DEEP_easyMultiTFRplot(cfg, data)
% DEEP_EASYTFRPLOT is a function, which makes it easier to create a multi
% time frequency response plot of all electrodes of specific condition and 
% trial on a head model.
%
% Use as
%   DEEP_easyTFRPlot(cfg, data)
%
% where the input data is a results from DEEP_TIMEFREQANALYSIS.
%
% The configuration options are 
%   cfg.part        = participant identifier, options: 'mother' or 'child' (default: 'mother')
%   cfg.condition   = condition (default: 11 or 'DFreePlay', see DEEP_DATASTRUCTURE)
%   cfg.trial       = number of trial (default: 1)
%   cfg.freqlim     = [begin end] (default: [2 30])
%   cfg.timelim     = [begin end] (default: [4 116])
%
% This function requires the fieldtrip toolbox
%
% See also FT_MULTIPLOTTFR, DEEP_TIMEFREQANALYSIS

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 'mother');
condition = ft_getopt(cfg, 'condition', 11);
trl       = ft_getopt(cfg, 'trial', 1);
freqlim   = ft_getopt(cfg, 'freqlim', [2 30]);
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

ft_warning off;

% -------------------------------------------------------------------------
% Plot time frequency spectrum
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath),...
     'lay');

colormap 'jet';

cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.maskstyle     = 'saturation';
cfg.xlim          = timelim;
cfg.ylim          = freqlim;
cfg.zlim          = 'maxmin';
cfg.trials        = trl;
cfg.channel       = {'all', '-V1', '-V2', '-Ref', '-EOGH', '-EOGV'};
cfg.layout        = lay;

cfg.showlabels    = 'no';
cfg.showoutline   = 'yes';
cfg.colorbar      = 'yes';

cfg.showcallinfo  = 'no';                                                   % suppress function call output

ft_multiplotTFR(cfg, data);
title(sprintf('Part.: %s - Cond.: %d - Trial: %d', part, condition, trlInCond));
  
ft_warning on;

end
