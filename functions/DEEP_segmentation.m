function [ data ] = DEEP_segmentation(cfg, data )
% DEEP_SEGMENTATION segments the data of each condition into segments with a
% certain length
%
% Use as
%   [ data ] = DEEP_segmentation( cfg, data )
%
% where the input data can be the result from DEEP_IMPORTDATASET, 
% DEEP_PREPROCESSING, DEEP_BPFILTERING or DEEP_HILBERTPHASE
%
% The configuration options are
%   cfg.length    = length of segments (excepted values: 0.2, 1, 5, 10 seconds, default: 1)
%   cfg.overlap   = percentage of overlapping (range: 0 ... 1, default: 0)
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_IMPORTDATASET, DEEP_PREPROCESSING, FT_REDEFINETRIAL,
% DEEP_DATASTRUCTURE, DEEP_BPFILTERING, DEEP_HILBERTPHASE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
segLength = ft_getopt(cfg, 'length', 1);
overlap   = ft_getopt(cfg, 'overlap', 0);

possibleLengths = [0.2, 1, 5, 10];

if ~any(ismember(possibleLengths, segLength))
  error('Excepted cfg.length values are only 0.2, 1, 5 and 10 seconds');
end

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = segLength;
cfg.overlap         = overlap;

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('<strong>Segment data of mother in segments of %d sec...</strong>\n', ...
        segLength);
ft_info off;
ft_warning off;
data.mother = ft_redefinetrial(cfg, data.mother);
    
fprintf('<strong>Segment data of child in segments of %d sec...</strong>\n', ...
        segLength);
ft_info off;
ft_warning off;
data.child = ft_redefinetrial(cfg, data.child);
    
ft_info on;
ft_warning on;
