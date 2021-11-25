function [ data_mplvod ] = DEEP_mPLVoverDyads( cfg )
% DEEP_MPLVOVERDYADS estimates the mean of the phase locking values for
% all conditions and over all dyads.
%
% Use as
%   [ data_mplvod ] = DEEP_mPLVoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01888/eegData/DualEEG_DEEP_processedData/07c_mplv/')
%   cfg.plvtype   = type of PLV data ('plv' or 'crossplv'
%   cfg.session   = session number (default: 1)
%   cfg.passband  = select passband of interest (default: theta)
%                   (accepted values: theta, alpha, beta, gamma)
%
% This function requires the fieldtrip toolbox
% 
% See also DEEP_CALCMEANPLV

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01888/eegData/DualEEG_DEEP_processedData/07c_mplv/');
plvtype   = ft_getopt(cfg, 'plvtype', 'plv');         
session   = ft_getopt(cfg, 'session', 1);
passband  = ft_getopt(cfg, 'passband', 'theta');

bands     = {'theta', 'alpha', 'beta', 'gamma'};
suffix    = {'Theta', 'Alpha', 'Beta', 'Gamma'};

if ~any(strcmp(passband, bands))
  error(['Define cfg.passband could only be ''theta'', '...
         '''alpha'', ''beta'' or ''gamma''.']);
else
  fileSuffix = suffix{strcmp(passband, bands)};
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
if strcmp(plvtype, 'plv') 
  fprintf('<strong>Averaging of Phase Locking Values over dyads at %s...</strong>\n', passband);

  dyadsList   = dir([path, sprintf('DEEP_d*_07c_mplv%s_%03d.mat', ...
                     fileSuffix, session)]);
elseif strcmp(plvtype, 'crossplv')
  fprintf('<strong>Averaging of Cross Phase Locking Values over dyads at %s...</strong>\n', passband);

  dyadsList   = dir([path, sprintf('DEEP_d*_07e_mcrossplv%s_%03d.mat', ...
                     fileSuffix, session)]);
end

dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

if strcmp(plvtype, 'plv')
  for i=1:1:numOfDyads
    listOfDyads(i) = sscanf(dyadsList{i}, ['DEEP_d%d_07c_mplv'...
                                     sprintf('%s_', fileSuffix) ...
                                     sprintf('%03d.mat', session)]);        %#ok<AGROW>
  end
elseif strcmp(plvtype, 'crossplv')
  for i=1:1:numOfDyads
    listOfDyads(i) = sscanf(dyadsList{i}, ['DEEP_d%d_07e_crossmplv'...
                                     sprintf('%s_', fileSuffix) ...
                                     sprintf('%03d.mat', session)]);        %#ok<AGROW>
  end
end
    
y = sprintf('%d ', listOfDyads);
selection = false;

while selection == false
  fprintf('The following dyads are available: %s\n', y);
  x = input('Which dyads should be included into the averaging? (i.e. [1,2,3]):\n');
  if ~all(ismember(x, listOfDyads))
    cprintf([1,0.5,0], 'Wrong input!\n');
  else
    selection = true;
    listOfDyads = unique(x);
    numOfDyads  = length(listOfDyads);
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
data_mplvod.avgData.trialinfo = generalDefinitions.condNumDual;

data{1, numOfDyads} = [];
trialinfo{1, numOfDyads} = [];

if strcmp(plvtype, 'plv')
  for i=1:1:numOfDyads
    filename = sprintf('DEEP_d%02d_07c_mplv%s_%03d.mat', listOfDyads(i), ...
                      fileSuffix, session);
    file = strcat(path, filename);
    fprintf('Load %s ...\n', filename);
    load(file, 'data_mplv');
    data{i} = data_mplv.dyad.mPLV;
    trialinfo{i} = data_mplv.dyad.trialinfo;
    if i == 1
      data_mplvod.centerFreqMother    = data_mplv.centerFreqMother;
      data_mplvod.bpFreqMother        = data_mplv.bpFreqMother;
      data_mplvod.centerFreqChild     = data_mplv.centerFreqChild;
      data_mplvod.bpFreqChild         = data_mplv.bpFreqChild;
      data_mplvod.avgData.label       = data_mplv.dyad.label;
    end
    clear data_mplv
  end
elseif strcmp(plvtype, 'crossplv')
  for i=1:1:numOfDyads
    filename = sprintf('DEEP_d%02d_07e_mcrossplv%s_%03d.mat', listOfDyads(i), ...
                      fileSuffix, session);
    file = strcat(path, filename);
    fprintf('Load %s ...\n', filename);
    load(file, 'data_mcrossplv');
    data{i} = data_mcrossplv.dyad.mPLV;
    trialinfo{i} = data_mcrossplv.dyad.trialinfo;
    if i == 1
      data_mplvod.centerFreqMother    = data_mcrossplv.centerFreqMother;
      data_mplvod.bpFreqMother        = data_mcrossplv.bpFreqMother;
      data_mplvod.centerFreqChild     = data_mcrossplv.centerFreqChild;
      data_mplvod.bpFreqChild         = data_mcrossplv.bpFreqChild;
      data_mplvod.avgData.label       = data_mcrossplv.dyad.label;
    end
    clear data_mcrossplv
  end
end

data = fixTrialOrder( data, trialinfo, generalDefinitions.condNumDual, ...
                      listOfDyads );
fprintf('\n');

for j=1:1:numOfDyads
  data{j} = cat(3, data{j}{:});
end
if numOfDyads > 1
  data = cat(4, data{:});
end

% -------------------------------------------------------------------------
% Estimate averaged phase locking value (over dyads)
% ------------------------------------------------------------------------- 
if numOfDyads > 1
  data = nanmean(data, 4);
else
  data = data{1};
end
data = squeeze(num2cell(data, [1 2]))';

data_mplvod.avgData.mPLV  = data;
data_mplvod.dyads         = listOfDyads;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trlInf, trlInfOrg, dyadNum )

emptyMatrix = NaN * ones(size(dataTmp{1}{1}, 1), size(dataTmp{1}{1}, 2));   % empty matrix with NaNs

for k = 1:1:size(dataTmp, 2)
  if ~isequal(trlInf{k}, trlInfOrg')
    missingPhases = ~ismember(trlInfOrg, trlInf{k});
    missingPhases = trlInfOrg(missingPhases);
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
            sprintf('Dyad %d: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
            dyadNum(k), missingPhases));
    [~, loc] = ismember(trlInfOrg, trlInf{k});
    tmpBuffer = [];
    tmpBuffer{length(trlInfOrg)} = [];                                      %#ok<AGROW>
    for l = 1:1:length(trlInfOrg)
      if loc(l) == 0
        tmpBuffer{l} = emptyMatrix;
      else
        tmpBuffer(l) = dataTmp{k}(loc(l));
      end
    end
    dataTmp{k} = tmpBuffer;
  end
end

end
