function [ data ] = DEEP_pWelch( cfg, data )
% DEEP_PWELCH calculates the power activity using Welch's method for 
% every condition of every participant in the dataset.
%
% Use as
%   [ data ] = DEEP_pWelch( cfg, data)
%
% where the input data hast to be the result from DEEP_SEGMENTATION
%
% The configuration options are
%   cfg.foi = frequency of interest - begin:resolution:end (default: 1:1:50)
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_SEGMENTATION

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
foi = ft_getopt(cfg, 'foi', 1:1:50);

% -------------------------------------------------------------------------
% power settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.method          = 'mtmfft';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum for all channels
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 'maxperlen';                                          % do not use padding
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = foi;                                                  % frequencies of interest
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

% -------------------------------------------------------------------------
% Calculate power spectrum using Welch's method
% -------------------------------------------------------------------------
fprintf('<strong>Calc power spectrum of mothers data...</strong>\n');
ft_warning off;
data.mother = ft_freqanalysis(cfg, data.mother);
ft_warning on;
data.mother = pWelch(data.mother);

fprintf('<strong>Calc power spectrum of childs data...</strong>\n');
ft_warning off;
data.child = ft_freqanalysis(cfg, data.child); 
ft_warning on;
data.child = pWelch(data.child);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_pWelch ] = pWelch(data_pow)
% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');  

val       = ismember(generalDefinitions.condNum, data_pow.trialinfo);
trialinfo = generalDefinitions.condNum(val)';
powspctrm = zeros(length(trialinfo), length(data_pow.label), length(data_pow.freq));

for i = 1:1:length(trialinfo)
  val       = ismember(data_pow.trialinfo, trialinfo(i));
  tmpspctrm = data_pow.powspctrm(val,:,:);
  powspctrm(i,:,:) = median(tmpspctrm, 1);
end

data_pWelch.label = data_pow.label;
data_pWelch.dimord = data_pow.dimord;
data_pWelch.freq = data_pow.freq;
data_pWelch.powspctrm = powspctrm;
data_pWelch.trialinfo = trialinfo;
data_pWelch.cfg.previous = data_pow.cfg;
data_pWelch.cfg.pwelch_median = 'yes';
data_pWelch.cfg.pwelch_mean = 'no';

end
