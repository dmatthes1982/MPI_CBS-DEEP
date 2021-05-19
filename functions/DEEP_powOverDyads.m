function  [ data_pwelchod ] = DEEP_powOverDyads( cfg )
% DEEP_POWOVERDYADS estimates the mean of the power activity over dyads
% for all conditions separately for mothers and children.
%
% Use as
%   [ data_pwelchod ] = DEEP_powOverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01888/eegData/DualEEG_DEEP_processedData/08b_pwelch/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also DEEP_PWELCH

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01888/eegData/DualEEG_DEEP_processedData/08b_pwelch/');
session   = ft_getopt(cfg, 'session', 1);

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/DEEP_generalDefinitions.mat', filepath), ...
     'generalDefinitions');   

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
fprintf('<strong>Averaging power values over dyads...</strong>\n');

dyadsList   = dir([path, sprintf('DEEP_d*_08b_pwelch_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['DEEP_d%d_08b'...
                                   sprintf('%03d.mat', session)]);          %#ok<AGROW>
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
data_out.mother.trialinfo = generalDefinitions.condNum';
data_out.child.trialinfo        = generalDefinitions.condNum';

dataMother{1, numOfDyads}        = [];
dataChild{1, numOfDyads}      = [];
trialinfoExp{1, numOfDyads}   = [];
trialinfoChild{1, numOfDyads} = [];

for i=1:1:numOfDyads
  filename = sprintf('DEEP_d%02d_08b_pwelch_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_pwelch');
  dataMother{i}        = data_pwelch.mother.powspctrm;
  dataChild{i}      = data_pwelch.child.powspctrm;
  trialinfoExp{i}   = data_pwelch.mother.trialinfo;
  trialinfoChild{i} = data_pwelch.child.trialinfo;
  if i == 1
    data_out.mother.label   = data_pwelch.mother.label;
    data_out.child.label    = data_pwelch.child.label;
    data_out.mother.dimord  = data_pwelch.mother.dimord;
    data_out.child.dimord   = data_pwelch.child.dimord;
    data_out.mother.freq    = data_pwelch.mother.freq;
    data_out.child.freq     = data_pwelch.child.freq;
  end
  clear data_pwelch
end

dataMother  = cellfun(@(x) num2cell(x, [2,3])', dataMother, 'UniformOutput', false);
dataChild   = cellfun(@(x) num2cell(x, [2,3])', dataChild, 'UniformOutput', false);

for i=1:1:numOfDyads
  dataMother{i} = cellfun(@(x) squeeze(x), dataMother{i}, 'UniformOutput', false);
  dataChild{i}  = cellfun(@(x) squeeze(x), dataChild{i}, 'UniformOutput', false);
end

dataMother   = fixTrialOrder( dataMother, trialinfoExp, generalDefinitions.condNumDual, ...
                      listOfDyads, 'Mother' );
dataChild = fixTrialOrder( dataChild, trialinfoChild, generalDefinitions.condNum, ...
                      listOfDyads, 'Child' );

fprintf('\n');

dataMother = cellfun(@(x) cat(3, x{:}), dataMother, 'UniformOutput', false);
dataMother = cellfun(@(x) shiftdim(x, 2), dataMother, 'UniformOutput', false);
dataMother = cat(4, dataMother{:});

dataChild = cellfun(@(x) cat(3, x{:}), dataChild, 'UniformOutput', false);
dataChild = cellfun(@(x) shiftdim(x, 2), dataChild, 'UniformOutput', false);
dataChild = cat(4, dataChild{:});

% -------------------------------------------------------------------------
% Estimate averaged power spectrum (over dyads)
% -------------------------------------------------------------------------
dataMother  = nanmean(dataMother, 4);
dataChild   = nanmean(dataChild, 4);

data_out.mother.powspctrm = dataMother;
data_out.child.powspctrm  = dataChild;
data_out.dyads            = listOfDyads;

data_pwelchod = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg, dyadNum, part )

emptyMatrix = NaN * ones(size(dataTmp{1}{1}, 1), size(dataTmp{1}{1}, 2));   % empty matrix with NaNs

for k = 1:1:size(dataTmp, 2)
  if ~isequal(trInf{k}, trInfOrg')
    missingPhases = ~ismember(trInfOrg, trInf{k});
    missingPhases = trInfOrg(missingPhases);
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
            sprintf('Dyad %d - %s: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
            dyadNum(k), part, missingPhases));
    [~, loc] = ismember(trInfOrg, trInf{k});
    tmpBuffer = [];
    tmpBuffer{length(trInfOrg)} = [];                                       %#ok<AGROW>
    for l = 1:1:length(trInfOrg)
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
