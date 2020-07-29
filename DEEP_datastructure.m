% DEEP_DATASTRUCTURE
%
% The data in the --- DEEP: A dual-EEG Pipeline for adult and infant 
% hyperscanning studies. (DEEP) --- is structured as follows:
%
% dataset example:
%
% data_raw
%    |               
%    |---- mother (1x1 fieldtrip data structure for mother)    
%    |---- child (1x1 fieldtrip data structure for child)
%
% In every substep of the data processing pipeline (i.e. 01a_raw,
% 01b_manart, 02a_badchan, 02b_preproc1, 03a_icacomp ...) N single datasets
% will be created. The number N stands for the current number of dyads
% within the study. Every dataset for each dyad is stored in a separate
% *.mat file, to avoid the need of swap memory during data processing. As
% described a datasets has in most cases two fields, which are named
% mother and child. Some steps (i.e. the ica) will only be done with
% the data of the mother. Each field comprises a 1x1 struct with the
% complete data of the specific participant. The different conditions in
% this data struct are separated through trials and the field trialinfo
% contains the condition markers of each trials. In case of subsegmented
% data the structure contains more than one trial for each condition.
% The information about the order of the trials of one condition is
% available through the relating time elements.
%
% Many functions especially the plot functions need a declaration of the 
% specific condition, which should be selected. The DEEP study is 
% described by the following conditions:
%
% - DFreePlay       - 11
% - DRestFreePlay   - 13
% - DRestHighCont   - 20
% - DHighCont       - 21
% - DRestLowCont    - 22
% - DLowCont        - 23
% - SRestContToy1   - 41
% - SContToy1       - 42
% - SRestContToy2   - 43
% - SContToy2       - 44
% - SRestNoContToy1 - 45
% - SNoContToy1     - 46
% - SRestNoContToy2 - 47
% - SNoContToy2     - 48
% - SRestContReToy1 - 49
% - SContReToy1     - 50
% - SRestContReToy2 - 51
% - SContReToy2     - 52
%
% The declaration of the condition is done by setting the cfg.condition
% option with the string or the number of the specific condition.

% Copyright (C) 2018, Daniel Matthes, MPI CBS
