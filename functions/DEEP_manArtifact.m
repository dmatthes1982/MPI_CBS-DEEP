function [ cfgAllArt ] = DEEP_manArtifact( cfg, data )
% DEEP_MANARTIFACT - this function could be use to is verify the
% automatic detected artifacts, remove some of them or add additional ones,
% if required.
%
% Use as
%   [ cfgAllArt ] = DEEP_manArtifact(cfg, data)
%
% where data has to be a result of DEEP_SEGMENTATION
%
% The configuration options are
%   cfg.artifact  = output of DEEP_AUTOARTIFACT and/or DEEP_IMPORTDATASET
%                   (see files coSMIC_dxx_05a_autoart_yyy.mat, coSMIC_dxx_01b_manart_yyy.mat)
%   cfg.dyad      = number of dyad (only necessary for adding markers to databrowser view) (default: []) 
%
% This function requires the fieldtrip toolbox.
%
% See also DEEP_SEGMENTATION, DEEP_DATABROWSER, DEEP_AUTOARTIFACT, 
% DEEP_IMPORTDATASET

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
artifact  = ft_getopt(cfg, 'artifact', []);
dyad      = ft_getopt(cfg, 'dyad', []);

% -------------------------------------------------------------------------
% Initialize settings, build output structure
% -------------------------------------------------------------------------
cfg             = [];
cfg.dyad        = dyad;
cfg.ylim        = [-100 100];
cfgAllArt.mother = [];                                       
cfgAllArt.child = [];

% -------------------------------------------------------------------------
% Check Data
% -------------------------------------------------------------------------

fprintf('\n<strong>Search for artifacts with mother...</strong>\n');
cfg.part = 'mother';
cfg.channel     = {'all', '-V1', '-V2'};
cfg.artifact = artifact.mother.artfctdef;
ft_warning off;
DEEP_easyArtfctmapPlot(cfg, artifact);                                    % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];                                             % --> first figure will be placed on the left side of figure 2
cfgAllArt.mother = DEEP_databrowser(cfg, data);                           % show databrowser view in figure 2
close all;                                                                  % figure 1 will be closed with figure 2
cfgAllArt.mother = keepfields(cfgAllArt.mother, {'artfctdef', 'showcallinfo'});
  
fprintf('\n<strong>Search for artifacts with child...</strong>\n');
cfg.part = 'child';
cfg.channel     = {'all'};
cfg.artifact = artifact.child.artfctdef;
ft_warning off;
DEEP_easyArtfctmapPlot(cfg, artifact);                                    % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];                                             % --> first figure will be placed on the left side of figure 2
cfgAllArt.child = DEEP_databrowser(cfg, data);                            % show databrowser view in figure 2
close all;                                                                  % figure 1 will be closed with figure 2
cfgAllArt.child = keepfields(cfgAllArt.child, {'artfctdef', 'showcallinfo'});
  
ft_warning on;

end
