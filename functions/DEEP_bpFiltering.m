function [ data ] = DEEP_bpFiltering( cfg, data) 
% DEEP_BPFILTERING applies a specific bandpass filter to every channel in
% the DEEP_DATASTRUCTURE
%
% Use as
%   [ data ] = DEEP_bpFiltering( cfg, data)
%
% where the input data have to be the result from DEEP_IMPORTDATASET,
% DEEP_PREPROCESSING or DEEP_SEGMENTATION 
%
% The configuration options are
%   cfg.bpfreq      = passband range [begin end] (default: [1.9 2.1])
%   cfg.filtorder   = define order of bandpass filter (default: 250)
%   cfg.channel     = channel selection (default: {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'}
%
% This function is configured with a fixed filter order, to generate
% comparable filter charakteristics for every operating point.
%
% This function requires the fieldtrip toolbox
%
% See also DEEP_IMPORTDATASET, DEEP_PREPROCESSING, DEEP_SEGMENTATION, 
% DEEP_DATASTRUCTURE, FT_PREPROCESSING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq          = ft_getopt(cfg, 'bpfreq', [1.9 2.1]);
bpfreq_Child    = ft_getopt(cfg, 'bpfreq_Child', [1.9 2.1]);
order           = ft_getopt(cfg, 'filtorder', 250);
channel         = ft_getopt(cfg, 'channel', {'all', '-REF', '-EOGV', ...    % apply bandpass to every channel except REF, EOGV, EOGH, V1 and V2
                                            '-EOGH', '-V1', '-V2' });

% -------------------------------------------------------------------------
% Filtering settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.trials          = 'all';                                                % apply bandpass to all trials
cfg.channel         = channel;
cfg.bpfilter        = 'yes';
cfg.bpfilttype      = 'fir';                                                % use a simple fir
cfg.bpfreq          = bpfreq;                                               % define bandwith
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output
cfg.bpfiltord       = order;                                                % define filter order

centerFreq = (bpfreq(2) + bpfreq(1))/2;
centerFreq_Child = (bpfreq_Child(2) + bpfreq_Child(1))/2;

% -------------------------------------------------------------------------
% Bandpass filtering
% -------------------------------------------------------------------------
data.centerFreq = [];
data.centerFreq_Child = [];

fprintf('<strong>Apply bandpass to mothers data with a center frequency of %g Hz...</strong>\n', ...           
          centerFreq);
data.mother   = ft_preprocessing(cfg, data.mother);        
          
fprintf('<strong>Apply bandpass to childs data with a center frequency of %g Hz...</strong>\n', ...           
          centerFreq_Child);
cfg.bpfreq = bpfreq_Child;
data.child   = ft_preprocessing(cfg, data.child);
 
cfg.bpfreq = bpfreq;
data.centerFreq = centerFreq;
data.bpFreq = bpfreq;

data.centerFreq_Child = centerFreq_Child;
data.bpFreq_Child = bpfreq_Child;

end
