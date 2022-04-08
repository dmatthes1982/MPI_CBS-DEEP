function [ data ] = DEEP_crossPhaseLockVal( cfg, data )
% DEEP_CROSSPHASELOCKVAL estimates cross phase locking values between the
% participants of one dyads for all conditions and trials in the
% DEEP_DATASTRUCTURE
%
% Use as
%   [ data ] = DEEP_crossphaseLockVal( cfg, data )
%
% where the input data has to be the result of DEEP_HILBERTPHASE
%
% The configuration option is
%   cfg.winlen    = length of window over which the crossPLV will be calculated. (default: 1 sec)
%                   minimum = 1 sec
% 
% Reference: P Sauseng, W Klimesch, WR Gruber, N Birbaumer - Neuroimage, 2008 - Elsevier
%
% This function requires the fieldtrip toolbox
%
% See also DEEP_DATASTRUCTURE, DEEP_HILBERTPHASE

% Copyright (C) 2021, Daniel Matthes, HTWK Leipzig, Laboratory for 
% Biosignal Processing, Ira Marriott Haresign, University of East London

% -------------------------------------------------------------------------
% Get config option
% -------------------------------------------------------------------------
cfg.winlen = ft_getopt(cfg, 'winlen', 1);

% -------------------------------------------------------------------------
% Estimate Phase Locking Value (PLV)
% -------------------------------------------------------------------------
dataTmp = struct;
dataTmp.dyad = [];

fprintf('<strong>Calc cross frequency PLVs between infant %g Hz activity and adult %g Hz activity</strong>\n',...
        data.centerFreqChild, data.centerFreqMother)
     
dataTmp.dyad  = crossPhaseLockingValue(cfg, data.mother, data.child, data);
dataTmp.centerFreqMother = data.centerFreqMother;
dataTmp.bpFreqMother = data.bpFreqMother;
dataTmp.centerFreqChild = data.centerFreqChild;
dataTmp.bpFreqChild = data.bpFreqChild;

data = dataTmp;
end

function [data_out] = crossPhaseLockingValue(cfgPLV, dataPart1, dataPart2,data)
% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

%--------------------------------------------------------------------------
% Initialze variables
%--------------------------------------------------------------------------
markerTemplate          = generalDefinitions.condNum;                       % template including all available markers in correct order
numOfElec               = length(dataPart1.label);                          % number of electrodes
connections             = numOfElec;                                        % number of connections
timeOrg                 = dataPart1.time;                                   % extract original time vector
trial_p1                = dataPart1.trial;                                  % extract trials of participant 1  
trial_p2                = dataPart2.trial;                                  % extract trials of participant 2 
N                       = cfgPLV.winlen * dataPart1.fsample;                % Number of samples in one PLV window

orgTrialLength          = cellfun(@(x) length(x), dataPart1.trial);
divider                 = orgTrialLength./N;

if ~all(divider == round(divider))
  hits = find(divider ~= round(divider));
  error(['The trial lengths have to be mutiples of plv window ' ...
        'length. Error in trial(s): %d'], hits);
end

%--------------------------------------------------------------------------
% concatenate all trials with equal condition numbers
%--------------------------------------------------------------------------
uniqueTrials            = unique(dataPart1.trialinfo, 'stable');            % estimate unique phases                                
tf                      = ismember(markerTemplate, uniqueTrials);           % bring unique phase into a correct order
idx                     = 1:length(markerTemplate);
idx                     = idx(tf);
uniqueTrials            = markerTemplate(idx);

diffCondition           = length(uniqueTrials);                             % estimate number of different condition 
trialinfo               = zeros(diffCondition, 1);                          % build new trialinfo
goodtrials              = zeros(diffCondition, 1);                          % build goodtrials info field
catTrial_p1{diffCondition} = [];                                            % new cell vector for concatenated trial matrices of participant 1
catTrial_p2{diffCondition} = [];                                            % new cell vector for concatenated trial matrices of participant 2
catTimeOrg{diffCondition}  = [];                                            % new cell vector for concatenated time vectors   

for i=1:1:diffCondition                                                     % for all conditions
  marker          = uniqueTrials(i);                                        % estimate i-th phase marker
  trials          = find(dataPart1.trialinfo == marker);                    % extract all trials with this marker
  goodtrials(i)   = length(trials);                                         % save the number of good trials for each condition
  trialinfo(i)    = marker;                                                 % put phase marker into new trialinfo
  catTimeOrg{i}   = cat(2, timeOrg{trials});                                % concatenate time elements
  catTrial_p1{i}  = cat(2, trial_p1{trials});                               % concatenate trials of participant 1
  catTrial_p2{i}  = cat(2, trial_p2{trials});                               % concatenate trials of participant 2
end

numOfTrials             = length(catTrial_p1);                              % number of trials
PLV{numOfTrials}        = [];                                               % PLV matrix 
time{numOfTrials}       = [];                                               % time matrix

%--------------------------------------------------------------------------
% Calculate PLV values
%--------------------------------------------------------------------------

r = mean(data.bpFreqMother)/mean(data.bpFreqChild);
freq_range = [min(data.bpFreqChild) max(data.bpFreqMother)];

freqsn  = freq_range;
freqsm  = freqsn*r;

n_mult  = (freqsn(1)+freqsm(1))/(2*freqsn(1));
m_mult  = (freqsm(1)+freqsn(1))/(2*freqsm(1));% check this one



for i = 1:1:numOfTrials                                                     % for all trials
    
  VarA        = catTrial_p1{i};                                             % extract i-th trial of participant 1
  VarA        = permute(VarA, [1, 3, 2]);                                   % rearrange dimensions (electrodes to first, samples to third)
  VarA        = VarA*n_mult;   %   transformation of phase

  
  VarB        = catTrial_p2{i};                                             % extract i-th trial of participant 2
  VarB        = permute(VarB, [3, 1, 2]);                                   % rearrange dimensions (electrodes to second, samples to third)
  VarB        = VarB*m_mult;%   transformation of phase

  
  Time        = catTimeOrg{i};
  numOfPLV    = fix(size(VarA, 3)/N);                                       % calculate number of PLV values within one trial
  PLV{i}      = zeros(numOfElec, connections, numOfPLV);
  
  phasediff = VarA - VarB;                                                  % calculate phase diff for all electrodes and over all connections
  for k = 1:1:numOfPLV                                                      % for all windows in one trial                                                   
    if mod(N, 2) == 0                                                       % if PLV window length is even 
      time{1,i}(1,k) = Time((k-1)*N + (N./2+1));                            % estimate time points for each PLV value
    else                                                                    % if PLV window length is odd
      time{1,i}(1,k) = (Time((k-1)*N + (fix(N./2)+1)) + ...
                        Time((k-1)*N + (fix(N./2)+2))) / 2;
    end
    window = phasediff(:,:, (k-1)*N + 1:k*N);
    PLV{i}(:,:,k) = abs(sum(exp(1i*window), 3)/N);
  end
  PLV{i} = mat2cell(PLV{i}, ones(1,numOfElec), ones(1,numOfElec), ...
                    size(PLV{i},3));
  PLV{i} = cellfun(@(x) squeeze(x)', PLV{i}, 'uniform', 0);
  
  
  
end

%--------------------------------------------------------------------------
% compile output data
%--------------------------------------------------------------------------
data_out                  = keepfields(dataPart1, {'hdr', 'fsample'});
data_out.trialinfo        = trialinfo;
data_out.goodtrials       = goodtrials;
data_out.dimord           = 'trl_chan1_chan2';
data_out.PLV              = PLV;
data_out.time             = time;
data_out.label            = dataPart1.label;
data_out.cfg              = cfgPLV;
data_out.cfg.previous{1}  = dataPart1.cfg;
data_out.cfg.previous{2}  = dataPart2.cfg;

end
