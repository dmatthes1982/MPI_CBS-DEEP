function [ data ] = DEEP_hilbertPhase( data )
% DEEP_HILBERTPHASE estimates the Hilbert phase of every channel in every 
% trial in the DEEP_DATASTRUCTURE
%
% Use as
%   [ data ] = DEEP_hilbertPhase( data )
%
% where the input data have to be the result from DEEP_BPFILTERING
%
% This functions calculates also the Hilbert average ratio as described in
% the Paper of M. Chavez (2005). This value could be used to check the
% compilance of the narrow band condition. (hilbert_avRatio > 50)
%
% This function requires the fieldtrip toolbox
%
% Reference:
%   [Chavez2005]    "Towards a proper extimation of phase synchronization
%                   from time series"
%
% See also DEEP_DATASTRUCTURE, DEEP_BPFILTERING, FT_PREPROCESSING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% General Hilbert transform settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.channel         = 'all';
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';

% -------------------------------------------------------------------------
% Calculate Hilbert phase
% -------------------------------------------------------------------------
fprintf('<strong>Calc Hilbert phase of mothers data at %g Hz...</strong>\n', ...           
         data.centerFreqMother);
data.mother   = hilbertTransform(cfg, data.mother);        
          
fprintf('<strong>Calc Hilbert phase of childs data at %g Hz...</strong>\n', ...           
         data.centerFreqChild);
data.child   = hilbertTransform(cfg, data.child);

end

% -------------------------------------------------------------------------
% Local function
% -------------------------------------------------------------------------

function [ data ] = hilbertTransform( cfg, data )
% -------------------------------------------------------------------------
% Get data properties
% -------------------------------------------------------------------------
trialNum = length(data.trial);                                              % get number of trials 
trialComp = length (data.label);                                            % get number of components

% -------------------------------------------------------------------------
% Calculate instantaneous phase
% -------------------------------------------------------------------------
cfg.hilbert         = 'angle';
data_phase          = ft_preprocessing(cfg, data);

% -------------------------------------------------------------------------
% Calculate instantaenous amplitude
% -------------------------------------------------------------------------
cfg.hilbert         = 'abs';
data_amplitude      = ft_preprocessing(cfg, data);

% -------------------------------------------------------------------------
% Calculate average ratio E[phi'(t)/(A'(t)/A(t))]
% -------------------------------------------------------------------------
hilbert_avRatio = zeros(trialNum, trialComp);

for trial=1:1:trialNum
    phase_diff_abs      = abs(diff(data_phase.trial{trial} , 1, 2));
    phase_diff_abs_inv  = 2*pi - phase_diff_abs;
    phase_diff_abs      = cat(3, phase_diff_abs, phase_diff_abs_inv);
    phase_diff_abs      = min(phase_diff_abs, [], 3);
    
    amp_diff = diff(data_amplitude.trial{trial} ,1 ,2);
    amp = data_amplitude.trial{trial};
    amp(:, 1) =  [];                                                        % delete the first amplitude, since there are no amplitude and phase differences available at this point
    amp_ratio_abs = abs(amp_diff ./ amp);
    ratio = (phase_diff_abs ./ amp_ratio_abs);

    hilbert_avRatio(trial, :) = (mean(ratio, 2))';
    
    Val2low = length(find(hilbert_avRatio(trial, :) < 10));
    
    if (Val2low ~= 0)
      warning('Hilbert average ratio in trial %d is %d time(s) below 10.', ...
             trial, Val2low);
    end
end

% -------------------------------------------------------------------------
% Generate the output 
% -------------------------------------------------------------------------
data = data_phase;

data.hilbert_avRatio = hilbert_avRatio;                                     % assign hilbert_avRatio to the output data structure

end
