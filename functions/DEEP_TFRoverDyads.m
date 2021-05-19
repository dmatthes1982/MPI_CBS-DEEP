function  [ data_tfrod ] = DEEP_TFRoverDyads( cfg )
% DEEP_TFROVERDYADS estimates the mean of the time frequency responses
% over dyads for all conditions seperately for mothers and children.
%
% Use as
%   [ data_tfrod ] = DEEP_TFRoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01888/eegData/DualEEG_DEEP_processedData/08a_tfr/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also DEEP_TIMEFREQANALYSIS

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01888/eegData/DualEEG_DEEP_processedData/08a_tfr/');
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
fprintf('<strong>Averaging TFR values over dyads...</strong>\n');

dyadsList   = dir([path, sprintf('DEEP_d*_08a_tfr_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['DEEP_d%d_08a'...
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
% Load, organize and summarize data
% -------------------------------------------------------------------------
data_out.mother.trialinfo = generalDefinitions.condNumDual';
data_out.child.trialinfo  = generalDefinitions.condNum';

numOfTrialsMother = zeros(1, length(data_out.mother.trialinfo));
numOfTrialsChild  = zeros(1, length(data_out.child.trialinfo));
tfrMother{length(data_out.mother.trialinfo)}   = [];
tfrChild{length(data_out.child.trialinfo)}  = [];

for i=1:1:numOfDyads
  filename = sprintf('DEEP_d%02d_08a_tfr_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_tfr');
  tfr1   = data_tfr.mother.powspctrm;
  tfr2   = data_tfr.child.powspctrm;
  trialinfo_mother = data_tfr.mother.trialinfo;
  trialinfo_child = data_tfr.child.trialinfo;
  if i == 1
    data_out.mother.label   = data_tfr.mother.label;
    data_out.child.label    = data_tfr.child.label;
    data_out.mother.dimord  = data_tfr.mother.dimord;
    data_out.child.dimord   = data_tfr.child.dimord;
    data_out.mother.freq    = data_tfr.mother.freq;
    data_out.child.freq     = data_tfr.child.freq;
    data_out.mother.time    = data_tfr.mother.time;
    data_out.child.time     = data_tfr.child.time;
    tfrMother(:)  = {zeros(length(data_out.mother.label), ...
                    length(data_out.mother.freq), ...
                    length(data_out.mother.time))};
    tfrChild(:)   = {zeros(length(data_out.child.label), ...
                    length(data_out.child.freq), ...
                    length(data_out.child.time))};
  end
  clear data_tfr
  
  tfr1 = num2cell(tfr1, [2,3,4])';
  tfr1 = cellfun(@(x) squeeze(x), tfr1, 'UniformOutput', false);
  [tfr1,trialSpec1] = fixTrialOrder( tfr1, trialinfo_mother, ...
                                      generalDefinitions.condNumDual, ...
                                      listOfDyads(i), 'Mother');
  
  tfr2 = num2cell(tfr2, [2,3,4])';
  tfr2 = cellfun(@(x) squeeze(x), tfr2, 'UniformOutput', false);
  [tfr2, trialSpec2] = fixTrialOrder( tfr2, trialinfo_child, ...
                                      generalDefinitions.condNum, ...
                                      listOfDyads(i), 'Child');
  
  tfrMother = cellfun(@(x,y) x+y, tfrMother, tfr1, 'UniformOutput', false);
  numOfTrialsMother = numOfTrialsMother + trialSpec1;

  tfrChild  = cellfun(@(x,y) x+y, tfrChild, tfr2, 'UniformOutput', false);
  numOfTrialsChild  = numOfTrialsChild + trialSpec2;
end
fprintf('\n');

numOfTrialsMother = num2cell(numOfTrialsMother);
numOfTrialsChild  = num2cell(numOfTrialsChild);

tfrMother = cellfun(@(x,y) x/y, tfrMother, numOfTrialsMother, 'UniformOutput', false);
tfrMother = cat(4, tfrMother{:});
tfrMother = shiftdim(tfrMother, 3);

tfrChild = cellfun(@(x,y) x/y, tfrChild, numOfTrialsChild, 'UniformOutput', false);
tfrChild = cat(4, tfrChild{:});
tfrChild = shiftdim(tfrChild, 3);

data_out.mother.powspctrm   = tfrMother;
data_out.child.powspctrm    = tfrChild;
data_out.dyads              = listOfDyads;

data_tfrod = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function [dataTmp, NoT] = fixTrialOrder( dataTmp, trInf, trInfOrg, ...
                                        dyadNum, part )

emptyMatrix = zeros(size(dataTmp{1}, 1), size(dataTmp{1}, 2), ...           % empty matrix
                    size(dataTmp{1}, 3));
NoT = ones(1, length(trInfOrg));

if ~isequal(trInf, trInfOrg')
  missingPhases = ~ismember(trInfOrg, trInf);
  missingPhases = trInfOrg(missingPhases);
  if ~isempty(missingPhases)
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
          sprintf('Dyad %d - %s: Phase(s) %s missing. Empty matrix(matrices) with zeros created.\n', ...
          dyadNum, part, missingPhases));
  end
  [~, loc] = ismember(trInfOrg, trInf);
  tmpBuffer = [];
  tmpBuffer{length(trInfOrg)} = [];
  for j = 1:1:length(trInfOrg)
    if loc(j) == 0
      NoT(j) = 0;
      tmpBuffer{j} = emptyMatrix;
    else
      tmpBuffer(j) = dataTmp(loc(j));
    end
  end
  dataTmp = tmpBuffer;
end

end
