function DEEP_easyPLVplot( cfg, data )
% DEEP_EASYPLVPLOT is a function, which makes it easier to plot the PLV 
% values of a specific condition from the DEEP_DATASTRUCTURE.
%
% Use as
%   DEEP_easyPLVplot( cfg, data )
%
% where the input data has to be the result of DEEP_PHASELOCKVAL
%
% The configuration options are
%   cfg.condition = condition (default: 11 or 'DFreePlay', see DEEP_DATASTRUCTURE)
%   cfg.elecPart1 = number of electrode of mother (default: 'Cz')
%   cfg.elecPart2 = number of electrode of child (default: 'Cz')
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_DATASTRUCTURE, PLOT, DEEP_PHASELOCKVAL

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cond = ft_getopt(cfg, 'condition', 4);
elecPart1 = ft_getopt(cfg, 'elecPart1', 'Cz');
elecPart2 = ft_getopt(cfg, 'elecPart2', 'Cz');

trialinfo = data.dyad.trialinfo;                                            % get trialinfo

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));

cond = DEEP_checkCondition( cond );                                       % check cfg.condition definition and translate it into trl number    
trl  = find(trialinfo == cond);
if isempty(trl)
  error('The selected dataset contains no condition %d.', cond);
end

label = data.dyad.label;                                                    % get labels

if isnumeric(elecPart1)                                                     % check cfg.electrode definition
  if ~ismember(elecPart1, 1:1:32)
    error('cfg.elecPart1 hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elecPart1 = find(strcmp(label, elecPart1));                            
  if isempty(elecPart1)
    error('cfg.elecPart1 hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

if isnumeric(elecPart2)                                                     % check cfg.electrode definition
  if ~ismember(elecPart2, 1:1:32)
    error('cfg.elecPart2 hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elecPart2 = find(strcmp(label, elecPart2));
  if isempty(elecPart2)
    error('cfg.elecPart2 hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

% -------------------------------------------------------------------------
% Plot PLV course
% -------------------------------------------------------------------------
plot(data.dyad.time{trl}, data.dyad.PLV{trl}{elecPart1,elecPart2}(:));
title(sprintf(' Cond.: %d - Elec.: %s - %s', cond, ...
              strrep(data.dyad.label{elecPart1}, '_', '\_'), ...
              strrep(data.dyad.label{elecPart2}, '_', '\_')));   

xlabel('time in seconds');
ylabel('phase locking value');

end
