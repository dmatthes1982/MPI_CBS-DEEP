function [ data ] = DEEP_concatData( cfg, data )
% DEEP_CONCATDATA concatenate all trials of a dataset to a continuous
% data stream.
%
% Use as
%   [ data ] = DEEP_concatData( cfg, data )
%
% where the input can be i.e. the result from DEEP_IMPORTDATASET or 
% DEEP_PREPROCESSING
%
% The configuration options are
%   cfg.part = participants which shall be processed: mother, child or both (default: both)
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_IMPORTDATASET, DEEP_PREPROCESSING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part = ft_getopt(cfg, 'part', 'both');                                      % participant selection

if ~ismember(part, {'mother', 'child', 'both'})                             % check cfg.part definition
  error('cfg.part has to either ''mother'', ''child'' or ''both''.');
end

% -------------------------------------------------------------------------
% Concatenate the data
% -------------------------------------------------------------------------
if ismember(part, {'mother', 'both'})
  fprintf('Concatenate trials of mother...\n');
  data.mother = concatenate(data.mother);
end

if ismember(part, {'child', 'both'})
  fprintf('Concatenate trials of child...\n');
  data.child = concatenate(data.child);
end

if strcmp(part, 'mother')
  data = removefields(data, 'child');
elseif strcmp(part, 'child')
  data = removefields(data, 'mother');
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION for concatenation
% -------------------------------------------------------------------------
function [ dataset ] = concatenate( dataset )

numOfTrials = length(dataset.trial);                                        % estimate number of trials
trialLength = zeros(numOfTrials, 1);                                        
numOfChan   = size(dataset.trial{1}, 1);                                    % estimate number of channels

for i = 1:numOfTrials
  trialLength(i) = size(dataset.trial{i}, 2);                               % estimate length of single trials
end

dataLength  = sum( trialLength );                                           % estimate number of all samples in the dataset
data_concat = zeros(numOfChan, dataLength);
time_concat = zeros(1, dataLength);
endsample   = 0;

for i = 1:numOfTrials
  begsample = endsample + 1;
  endsample = endsample + trialLength(i);
  data_concat(:, begsample:endsample) = dataset.trial{i}(:,:);              % concatenate data trials
  if begsample == 1
    time_concat(1, begsample:endsample) = dataset.time{i}(:);               % concatenate time vectors
  else
    if (dataset.time{i}(1) == 0 )
      time_concat(1, begsample:endsample) = dataset.time{i}(:) + ...
                                time_concat(1, begsample - 1) + ...         % create continuous time scale
                                1/dataset.fsample;
    elseif(dataset.time{i}(1) > time_concat(1, begsample - 1))
      time_concat(1, begsample:endsample) = dataset.time{i}(:);             % keep existing time scale
    else
      time_concat(1, begsample:endsample) = dataset.time{i}(:) + ...
                                time_concat(1, begsample - 1) + ...         % create continuous time scale
                                1/dataset.fsample - ...
                                dataset.time{i}(1);
    end
  end
end

dataset.trial       = [];
dataset.time        = [];
dataset.trial{1}    = data_concat;                                          % add concatenated data to the data struct
dataset.time{1}     = time_concat;                                          % add concatenated time vector to the data struct
dataset.trialinfo   = 0;                                                    % add a fake event number to the trialinfo for subsequend artifact rejection
dataset.sampleinfo  = [1 dataLength];                                       % add also a fake sampleinfo for subsequend artifact rejection

end
