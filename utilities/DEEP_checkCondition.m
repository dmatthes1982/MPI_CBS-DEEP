function [ num ] = DEEP_checkCondition( condition )
% DEEP_CHECKCONDITION - This functions checks the defined condition. 
%
% Use as
%   [ num ] = DEEP_checkCondition( condition )
%
% If condition is a number the function checks, if this number is equal to 
% one of the default values and return this number in case of confirmity. 
% If condition is a string, the function returns the associated number, if
% the given string is valid. Otherwise the function throws an error.
%
% All available condition strings and numbers are defined in
% DEEP_DATASTRUCTURE
%
% SEE also DEEP_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

condNum = generalDefinitions.condNum;
condString = generalDefinitions.condString;

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric(condition)                                                     % if condition is already numeric
  if ~any(condNum == condition)
    error('%d is not a valid condition', condition);
  else
    num = condition;
  end
else                                                                        % if condition is specified as string
  elements = strcmp(condString, condition);
  if ~any(elements)
     error('%s is not a valid condition', condition);
  else
    num = condNum(elements);
  end
end

end
