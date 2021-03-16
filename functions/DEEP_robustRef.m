 function [data_out] =DEEP_robustRef(data_continuous, data_in)

% data in is data from step 2 data_noisy that has subfield .outliers e.g.,
% output form DEEP_estNoiseyChan

% get noisy chan numbers
noisy_chans_mum = find(data_in.mother.outliers==1);
noisy_chans_child = find(data_in.child.outliers==1); 

% remove noisy chans from data
tempdat_mother = data_continuous.mother.trial{1,1};
tmpdat_mother = tempdat_mother(1:30,:); % exclude eog channels from the reference

tmpM = tmpdat_mother;
tmpM(noisy_chans_mum,:)=[];

tempdat_child = data_continuous.child.trial{1,1};
tmpdat_child = tempdat_child(1:30,:);

tmpC = tmpdat_child;
tmpC(noisy_chans_child,:)=[];

% get robust average reference
mum_robustRef = mean(tmpM,1);
child_robustRef = mean(tmpC,1);

% re reference continuous data to robustRef
mum_referenced = tempdat_mother - mum_robustRef;
child_referenced = tempdat_child - child_robustRef;

% add back eogs 
extra_chansM = tempdat_mother(31:size(tempdat_mother,1),:);
extra_chansC = tempdat_child(31:size(tempdat_child,1),:);


data_continuous.mother.trial{1,1} = cat(1, mum_referenced, extra_chansM);
data_continuous.child.trial{1,1} = cat(1, child_referenced, extra_chansC);

% done
data_out = data_continuous;


