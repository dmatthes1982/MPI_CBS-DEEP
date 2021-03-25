function [data_out] =DEEP_robustRef(data_in, data_badchan)
% DEEP_ROBUSTREF does an average based re-referencing of eeg data using 
% only good channels for building the reference
%
% Use as
%   [data_out] =DEEP_robustRef(data_in, badchan)
%
% data_badchan is generated in part 2 of the pipeline during the first
% preprocessing step

% Copyright (C) 2021, Ira Marriott Haresign, University of East London,
% Daniel Matthes, HTWK Leipzig, Laboratory for Biosignal Processing

% get noisy chan numbers
noisy_chans_mum = data_badchan.mother.outliers==1;
noisy_chans_child = data_badchan.child.outliers==1; 

% -------------------------------------------------------------------------
% Re-Referencing of the mother's data
% -------------------------------------------------------------------------
for i=1:1:length(data_in.mother.trial)
    mum_input = data_in.mother.trial{i};
    % exclude EOGV and EOGH from rereferencing
    mum_reduced = mum_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmpM = mum_reduced;
    tmpM(noisy_chans_mum,:)=[];
    
    % get robust average reference
    mum_robustRef = mean(tmpM,1);
    
    % rereference continuous data to robustRef
    mum_referenced = mum_reduced - mum_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chansM = mum_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.mother.trial{i} = cat(1, mum_referenced, eog_chansM);
end

% -------------------------------------------------------------------------
% Re-Referencing of the child's data
% -------------------------------------------------------------------------
for i=1:1:length(data_in.child.trial)
    child_input = data_in.child.trial{i};                                   % Note: there are no EOGV and EOGH components in the child's dataset
    
    % remove noisy chans from data, ther are no
    tmpC = child_input;
    tmpC(noisy_chans_child,:)=[];

    % get robust average reference
    child_robustRef = mean(tmpC,1);
    
    % rereference continuous data to robustRef
    child_referenced = child_input - child_robustRef;
    
    % replace trial with rereferenced one
    data_in.child.trial{i} = child_referenced;
end

data_out = data_in;
