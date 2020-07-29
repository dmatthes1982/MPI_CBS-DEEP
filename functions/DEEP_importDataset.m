function [ data, cfg_manart ] = DEEP_importDataset(cfg)
% DEEP_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data, cfg_manart ] = DEEP_importDataset(cfg)
%
% The configuration options are
%   cfg.path          = source path' (i.e. '/data/pt_01888/eegData/DualEEG_coSMIC_rawData/')
%   cfg.dyad          = number of dyad
%   cfg.noichan       = channels which are not of interest (default: [])
%   cfg.continuous    = 'yes' or 'no' (default: 'no')
%   cfg.prestim       = define pre-Stimulus offset in seconds (default: 0)
%   cfg.rejectoverlap = reject first of two overlapping trials, 'yes' or 'no' (default: 'yes')
%
% The second output variable holds the manual during testing defined
% artifacts.
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, DEEP_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path          = ft_getopt(cfg, 'path', []);
dyad          = ft_getopt(cfg, 'dyad', []);
noichan       = ft_getopt(cfg, 'noichan', []);
continuous    = ft_getopt(cfg, 'continuous', 'no');
prestim       = ft_getopt(cfg, 'prestim', 0);
rejectoverlap = ft_getopt(cfg, 'rejectoverlap', 'yes');

if isempty(path)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No specific participant is defined!');
end

headerfile = sprintf('%scoSMIC_all_P%02d.vhdr', path, dyad);

if strcmp(continuous, 'no')
  % -----------------------------------------------------------------------
  % Load general definitions
  % -------------------------------------------------------------------------
  filepath = fileparts(mfilename('fullpath'));
  load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

  % definition of all possible stimuli, two for each condition, the first 
  % on is the original one and the second one handles the 'video trigger 
  % bug'
  eventvalues = generalDefinitions.condMark;
  artfctvalues = generalDefinitions.artfctMark;
  samplingRate = 500;
  dur = (generalDefinitions.duration + prestim) * samplingRate;
              
  % -----------------------------------------------------------------------
  % Generate trial definition
  % -----------------------------------------------------------------------
  % basis configuration for data import
  cfg                     = [];
  cfg.dataset             = headerfile;
  cfg.trialfun            = 'ft_trialfun_general';
  cfg.trialdef.eventtype  = 'Stimulus';
  cfg.trialdef.prestim    = prestim;
  cfg.showcallinfo        = 'no';
  cfg.feedback            = 'error';
  cfg.trialdef.eventvalue = eventvalues;

  cfg = ft_definetrial(cfg);                                                % generate config for segmentation
  if isfield(cfg, 'notification')
    cfg = rmfield(cfg, {'notification'});                                   % workarround for mergeconfig bug
  end

  for i = 1:1:size(cfg.trl, 1)                                              % set specific trial lengths
    element = generalDefinitions.condNum == cfg.trl(i,4);
    cfg.trl(i, 2) = dur(element) + cfg.trl(i, 1) - 1;
  end

  % -----------------------------------------------------------------------
  % Extract artifacts
  % -----------------------------------------------------------------------
  cfgArtfct                     = [];
  cfgArtfct.dataset             = headerfile;
  cfgArtfct.trialfun            = 'ft_trialfun_general';
  cfgArtfct.trialdef.eventtype  = 'Stimulus';
  cfgArtfct.showcallinfo        = 'no';
  cfgArtfct.feedback            = 'error';
  cfgArtfct.trialdef.eventvalue = artfctvalues;

  try
    cfgArtfct = ft_definetrial(cfgArtfct);                                  % extract manual artifact markers
  catch
    cfgArtfct = [];
  end

  if ~isempty(cfgArtfct)
    hdr = ft_read_header(headerfile);                                       % read header file
    maxSamples = hdr.nSamples;

    artifact     = cfgArtfct.trl;
    locStop = ismember(artifact(:,4), 3);                                   % check if dataset has one presStop marker
    if any(locStop)
      maxSamples = artifact(locStop, 1);                                    % define location of presStop marker as last valid sample
      artifact = artifact(~locStop, :);                                     % remove presStop marker
    end

    numOfArtfct = size(artifact, 1);

    if mod(numOfArtfct, 2)                                                  % if the last presResume marker is missing, add one at the last data sample
      artifact(numOfArtfct + 1, :) = [maxSamples maxSamples 0 5];
      numOfArtfct = numOfArtfct + 1;
    end

    locPause = ismember(artifact(:,4), 4);                                  % check if every presPause marker has one corresponding presResume marker
    locResume = ismember(artifact(:,4), 5);
    if ~all(locPause == circshift(locResume,1))
      error(['Problems with manual artifact markers! Not every ' ...
              '''S  4'' has a corresponding ''S  5''.']);
    end

    artifact(locPause, 2) = artifact(locResume, 1);
    artifact = artifact(locPause, :);
    numOfArtfct = numOfArtfct/2;
    artifact(:,3) = artifact(:,2) - artifact(:,1) + 1;

    % ---------------------------------------------------------------------
    % Adapt trial size
    % ---------------------------------------------------------------------
    for i = 1:1:numOfArtfct
      locArt = (artifact(i,1) >= cfg.trl(:,1) & ...
                artifact(i,1) <= cfg.trl(:,2)   );
      cfg.trl(locArt, 2) = cfg.trl(locArt,2) + artifact(i,3);
      if(sum(locArt) > 1)
        error(['Something weird happend! One manual artifact could ' ...
                'not be assigned to only one particular trial']);
      end
      if cfg.trl(locArt,2) > maxSamples
        cfg.trl(locArt,2) = maxSamples;
      end
    end

    if cfg.trl(end,2) > maxSamples
      cfg.trl(end,2) = maxSamples;
    end

    % ---------------------------------------------------------------------
    % Generate artifact config
    % ---------------------------------------------------------------------
    cfg_manart = [];
    cfg_manart.mother.artfctdef.xxx.artifact = artifact(:,1:2);
    cfg_manart.child.artfctdef.xxx.artifact = artifact(:,1:2);
  else
    % ---------------------------------------------------------------------
    % Adapt trial size, if recording was aborted
    % ---------------------------------------------------------------------
    hdr = ft_read_header(headerfile);                                       % read header file
    if cfg.trl(end,2) > hdr.nSamples
      cfg.trl(end,2) = hdr.nSamples;
    end

    % ---------------------------------------------------------------------
    % Generate artifact config
    % ---------------------------------------------------------------------
    cfg_manart = [];
    cfg_manart.mother.artfctdef.xxx.artifact = [];
    cfg_manart.child.artfctdef.xxx.artifact = [];
  end

  % -----------------------------------------------------------------------
  % Reject overlapping trials
  % -----------------------------------------------------------------------
  if strcmp(rejectoverlap, 'yes')                                           % if overlapping trials should be rejected
    overlapping = find(cfg.trl(1:end-1,2) > cfg.trl(2:end, 1));             % in case of overlapping trials, remove the first of theses trials
    if ~isempty(overlapping)
      for i = 1:1:length(overlapping)
        warning off backtrace;
        warning(['trial %d with marker ''S%3d''  will be removed due to '...
               'overlapping data with its successor.'], ...
               overlapping(i), cfg.trl(overlapping(i), 4));
        warning on backtrace;
      end
      cfg.trl(overlapping, :) = [];
    end
  end
else
  cfg                     = [];
  cfg.dataset             = headerfile;
  cfg.showcallinfo        = 'no';
  cfg.feedback            = 'no';
end

% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
if ~isempty(noichan)
  noichan = cellfun(@(x) strcat('-', x), noichan, ...
                          'UniformOutput', false);
  noichanp1 = cellfun(@(x) strcat(x, '_1'), noichan, ...
                          'UniformOutput', false);
  noichanp2 = cellfun(@(x) strcat(x, '_2'), noichan, ...
                          'UniformOutput', false);
  cfg.channel = [{'all'} noichanp1 noichanp2 ...                            % exclude channels which are not of interest
                {'-V2_1'}];                                                 % V2 is not connected with children, reject them always
else
  cfg.channel = {'all', '-V2_1'};
end

dataTmp = ft_preprocessing(cfg);                                            % import data

numOfChan = (numel(dataTmp.label) - 1)/2;

data.mother = dataTmp;                                                      % split dataset into two datasets, one for each participant
data.mother.label = strrep(dataTmp.label(numOfChan+1:end), '_2', '');
for i=1:1:length(dataTmp.trial)
  data.mother.trial{i} = dataTmp.trial{i}(numOfChan+1:end,:);
end

data.child = dataTmp;
data.child.label = strrep(dataTmp.label(1:numOfChan), '_1', '');            % V2 is not used with childs, hence V1 has no meaning
for i=1:1:length(dataTmp.trial)                                           
  data.child.trial{i} = dataTmp.trial{i}(1:numOfChan,:);                    % as a result both will be removed from the childs dataset  
end

dataTmp = data.child;

cfg = [];
cfg.part    = 'mother';
cfg.channel = 'all';
cfg.trials  = [11,13,20,21,22,23];                                          % keep only the dual conditions

data = DEEP_selectdata(cfg, data);                                        % remove all trials from the mothers dataset in which only the childs data is of interest
data.child = dataTmp;

end
