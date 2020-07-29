function [ data ] = DEEP_rejectArtifacts( cfg, data )
% DEEP_REJECTARTIFACTS is a function which removes trials containing 
% artifacts. It returns clean data.
%
% Use as
%   [ data ] = DEEP_rejectartifacts( cfg, data )
%
% where data can be a result of DEEP_SEGMENTATION, DEEP_BPFILTERING,
% DEEP_CONCATDATA or DEEP_HILBERTPHASE
%
% The configuration options are
%   cfg.part      = participants which shall be processed: mother, child or both (default: both)
%   cfg.artifact  = output of DEEP_MANARTIFACT or DEEP_AUTOARTIFACT 
%                   (see file coSMIC_pxx_05_autoArt_yyy.mat, coSMIC_pxx_06_allArt_yyy.mat)
%   cfg.reject    = 'none', 'partial','nan', or 'complete' (default = 'complete')
%   cfg.target    = type of rejection, options: 'single' or 'dual' (default: 'single');
%                   'single' = trials of a certain participant will be 
%                              rejected, if they are marked as bad 
%                              for that particpant (useable for ITPC calc)
%                   'dual' = trials of a certain participant will be
%                            rejected, if they are marked as bad for
%                            that particpant or for the other participant
%                            of the dyad (useable for PLV calculation)
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_SEGMENTATION, DEEP_BPFILTERING, DEEP_HILBERTPHASE, 
% DEEP_MANARTIFACT and DEEP_AUTOARTIFACT 

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 'both');                                 % participant selection
artifact  = ft_getopt(cfg, 'artifact', []);
reject    = ft_getopt(cfg, 'reject', 'complete');
target    = ft_getopt(cfg, 'target', 'single');

if ~ismember(part, {'mother', 'child', 'both'})                             % check cfg.part definition
  error('cfg.part has to either ''mother'', ''child'' or ''both''.');
end

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

if ~strcmp(target, 'single') && ~strcmp(target, 'dual')
  error('Selected type is unknown. Choose single or dual');
end

if ~strcmp(reject, 'complete')
  if ismember(part, {'mother', 'both'})
    artifact.mother.artfctdef.reject = reject;
    artifact.mother.artfctdef.minaccepttim = 0.2;
  end

  if ismember(part, {'child', 'both'})
    artifact.child.artfctdef.reject = reject;
    artifact.child.artfctdef.minaccepttim = 0.2;
  end
end


% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
if ismember(part, {'mother', 'both'})
  fprintf('\n<strong>Cleaning data of mother...</strong>\n');
  ft_warning off;
  data.mother = ft_rejectartifact(artifact.mother, data.mother);
  if strcmp(target, 'dual')
    ft_warning off;
    data.mother = ft_rejectartifact(artifact.child, data.mother);
  end
end

if ismember(part, {'child', 'both'})
  fprintf('\n<strong>Cleaning data of child...</strong>\n');
  ft_warning off;
  data.child = ft_rejectartifact(artifact.child, data.child);
  if strcmp(target, 'dual')
    ft_warning off;
    data.child = ft_rejectartifact(artifact.mother, data.child);
  end
end
  
ft_warning on;

if strcmp(part, 'mother')
  data = removefields(data, 'child');
elseif strcmp(part, 'child')
  data = removefields(data, 'mother');
end

end
