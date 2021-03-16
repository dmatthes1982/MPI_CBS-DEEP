function DEEP_easyMPLVplot( cfg, data )
% DEEP_EASYMPLVPLOT is a function, which makes it easier to plot the mean 
% PLV values from all electrodes of a specific condition from the 
% DEEP_DATASTRUCTURE.
%
% Use as
%   DEEP_easyPLVplot( cfg, data )
%
% where the input data has to be the result either of DEEP_CALCMEANPLV or
% DEEP_MPLVOVERDYADS
%
% The configuration options are
%   cfg.condition = condition (default: 11 or 'DFreePlay', see DEEP_DATASTRUCTURE)
%   cfg.electrode = electrodes of interest (e.g. {'C3', 'Cz', 'C4'}, default: 'all')
%   cfg.elecorder = describes the order of electrodes (use 'default' or specific order i.e.: 'DEEP_01')
%                   default value: 'default'
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_DATASTRUCTURE, PLOT, DEEP_CALCMEANPLV, DEEP_MPLVOVERDYADS

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
condition = ft_getopt(cfg, 'condition', 11);
electrode = ft_getopt(cfg, 'electrode', 'all');
elecorder = ft_getopt(cfg, 'elecorder', 'default');

if isfield(data, 'dyad')
  data = data.dyad;
elseif isfield(data, 'avgData')
  data = data.avgData;
else
  error(['The data structure has either a ''dyad'' nor a ''avgData'' field.' ... 
         'You''ve probably loaded the wrong data']);
end

trialinfo = data.trialinfo;                                                 % get trialinfo

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));

condition = DEEP_checkCondition( condition );                             % check cfg.condition definition and translate it into trl number
trl  = find(trialinfo == condition);
if isempty(trl)
  error('The selected dataset contains no condition %d.', condition);
end

% -------------------------------------------------------------------------
% Load electrode order describition, if necessary
% -------------------------------------------------------------------------
if ~strcmp(elecorder, 'default')
  filepath = fileparts(mfilename('fullpath'));
  load(sprintf('%s/../elecorder/%s.mat', filepath, elecorder), ...
     'labelAlt');
end

% -------------------------------------------------------------------------
% Prepare data
% ------------------------------------------------------------------------- 
label = data.label;

if strcmp(elecorder, 'default')
  mPLV = data.mPLV{trl};
else
  [tf, loc] = ismember(labelAlt, label);                                    % bring data into a correct order
  label     = labelAlt(tf);
  
  mPLV = data.mPLV{trl};
  loc(loc==0) = [];
  mPLV = mPLV(loc, loc);
end

% -------------------------------------------------------------------------
% Select only a subset of electrodes
% -------------------------------------------------------------------------
if ~isstring(electrode) && iscell(electrode)
  tf   = ismember(label, electrode);
  label = label(tf);
  mPLV = mPLV(tf,tf);
end

if ~isempty(label)
  components = 1:1:length(label);
else
  error('One have to specify at least one valid channel');
end

% -------------------------------------------------------------------------
% Plot mPLV representation
% -------------------------------------------------------------------------
colormap jet;
imagesc(components, components, mPLV);
set(gca, 'XTick', components,'XTickLabel', label);                          % use labels instead of numbers for the axis description
set(gca, 'YTick', components,'YTickLabel', label);
set(gca,'xaxisLocation','top');                                             % move xlabel to the top
title(sprintf(' mean Phase Locking Values in Condition: %d', condition));
colorbar;

end
