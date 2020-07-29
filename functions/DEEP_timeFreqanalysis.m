function [ data ] = DEEP_timeFreqanalysis( cfg, data )
% DEEP_TIMEFREQANALYSIS performs a time frequency analysis.
%
% Use as
%   [ data ] = DEEP_timeFreqanalysis(cfg, data)
%
% where the input data has to be the result from DEEP_IMPORTDATASET,
% DEEP_PREPROCESSING or DEEP_SEGMENTATION
%
% The configuration options are
%   cfg.foi = frequency of interest - begin:resolution:end (default: 2:1:50)
%   cfg.toi = time of interest - begin:resolution:end (default: 4:0.5:146)
%   
% This function requires the fieldtrip toolbox.
%
% See also DEEP_IMPORTDATASET, DEEP_PREPROCESSING, DEEP_SEGMENTATION, 
% DEEP_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
foi       = ft_getopt(cfg, 'foi', 2:1:50);
toi       = ft_getopt(cfg, 'toi', 4:0.5:146);

% -------------------------------------------------------------------------
% TFR settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.method          = 'wavelet';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum for specified channel
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = toi(end);                                             % do keep the selected frequency resolution
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = foi;                                                  % frequencies of interest
cfg.width           = 7;                                                    % wavlet specific parameter 1 (default value)
cfg.gwidth          = 3;                                                    % wavlet specific parameter 2 (default value) 
cfg.toi             = toi;                                                  % time of interest
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

% -------------------------------------------------------------------------
% Time-Frequency Response (Analysis)
% -------------------------------------------------------------------------
fprintf('<strong>Calc TFRs of mothers data...</strong>\n');
ft_warning off;
data.mother = ft_freqanalysis(cfg, data.mother);
  
fprintf('<strong>Calc TFRs of childs data...</strong>\n');
ft_warning off;
data.child = ft_freqanalysis(cfg, data.child); 

ft_warning on;

end
