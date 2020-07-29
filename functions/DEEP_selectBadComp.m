function [ data_eogcomp ] = DEEP_selectBadComp( cfg, data_eogcomp, data_icacomp )
% DEEP_SELECTBADCOMP is a function for exploring previously estimated ICA
% components visually. Within the GUI, each component can be set to either
% keep or reject for a later artifact correction operation. The result of
% DEEP_DETEOGCOMP are preselected, but it should be visually explored
% too.
%
% Use as
%   [ data_eogcomp ] = DEEP_selectBadComp( data_eogcomp, data_icacomp )
%
% where the input data_eogcomp has to be the result of DEEP_DETEOGCOMP
% and data_icacomp the result of DEEP_ICA
%
% The configuration options are
%   cfg.part        = participants which shall be processed: mother, child or both (default: both)
%
% This function requires the fieldtrip toolbox
%
% See also DEEP_DETEOGCOMP, DEEP_ICA and FT_ICABROWSER

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part        = ft_getopt(cfg, 'part', 'both');

if ~ismember(part, {'mother', 'child', 'both'})                             % check cfg.part definition
  error('cfg.part has to either ''mother'', ''child'' or ''both''.');
end

% -------------------------------------------------------------------------
% Verify correlating components
% -------------------------------------------------------------------------
if ismember(part, {'mother', 'both'})
  fprintf('<strong>Select ICA components which shall be subtracted from mother''s data...</strong>\n');
  data_eogcomp.mother = selectComp(data_eogcomp.mother, data_icacomp.mother);
end

fprintf('\n');

if ismember(part, {'child', 'both'})
  fprintf('<strong>Select ICA components which shall be subtracted from child''s data...</strong>\n');
  data_eogcomp.child = selectComp(data_eogcomp.child, data_icacomp.child);
end

end

%--------------------------------------------------------------------------
% SUBFUNCTION which provides the ft_icabrowser for verification of the
% EOG-correlating components and for the selection of further bad
% components.
%--------------------------------------------------------------------------
function [ dataEOGComp ] = selectComp( dataEOGComp, dataICAcomp )

numOfElements = 1:length(dataEOGComp.elements);
idx = find(ismember(dataICAcomp.label, dataEOGComp.elements))';

fprintf('Select components to reject!\n');
if ~isempty(numOfElements)
  fprintf(['Components which exceeded the selected EOG correlation '...'
           'threshold are already marked as bad.\n'...
           'These are:\n']);
end

for i = numOfElements
  [~, pos] = max(abs([dataEOGComp.eoghCorr(idx(i)) ...
                  dataEOGComp.eogvCorr(idx(i))]));
  if pos == 1
    corrVal = dataEOGComp.eoghCorr(idx(i)) * 100;
  else
    corrVal = dataEOGComp.eogvCorr(idx(i)) * 100;
  end
  fprintf('[%d] - component %d - %2.1f %% correlation\n', i, idx(i), corrVal);
end

filepath = fileparts(mfilename('fullpath'));                                % load cap layout
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath), ...
     'lay');

cfg               = [];
cfg.rejcomp       = idx;
cfg.blocksize     = 30;
cfg.layout        = lay;
cfg.zlim          = 'maxabs';
cfg.colormap      = 'jet';
cfg.showcallinfo  = 'no';

ft_warning off;
badComp = ft_icabrowser(cfg, dataICAcomp);
ft_warning on;

if sum(badComp) == 0
  cprintf([1,0.5,0],'No component is selected!\n');
  cprintf([1,0.5,0],'NOTE: The following cleaning operation will keep the data unchanged!\n');
end

dataEOGComp.elements = dataICAcomp.label(badComp);

end
