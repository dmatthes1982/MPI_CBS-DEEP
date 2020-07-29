function [ numOfSeg ] = DEEP_numOfSeg( data )
% DEEP_NUMOFSEG estimates number of segments per condition.
%
% Use as
%   [ numOfSeg ] = DEEP_numOfSeg( data )
%
% where the input data could be any data structure of the DEEP project.
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_SEGMENTATION

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

conditions = [generalDefinitions.condNum];

numOfSeg.mother = numofseg(data.mother, conditions);
numOfSeg.child  = numofseg(data.child, conditions);

end

% -------------------------------------------------------------------------
% Estimate number of segments
% -------------------------------------------------------------------------
function [seg] = numofseg(dataPart, cond)

  seg = zeros(numel(cond), 1);

  for i = 1:1:numel(cond)
    seg(i) = sum(ismember(dataPart.trialinfo, cond(i)));
  end

end
