function [segmentation] = DEEP_segSelectbox( )
% DEEP_SEGSELECTBOX is a function, which displays a small GUI for the
% adjustment of segmentation durations. It returns a cell array of 
% segmentation window lengths.
%
% Use as
%   [ segmentation ]  = DEEP_segSelectbox( cfg )
%
% This function requires the fieldtrip toolbox.
%
% SEE also UIFIGURE, UIEDITFIELD, UIBUTTON, UIRESUME, UIWAIT


% Copyright (C) 2021
% Daniel Matthes, HTWK Leipzig, Laboratory for Biosignal Processing


% -------------------------------------------------------------------------
% Create GUI
% -------------------------------------------------------------------------
segSelectbox = uifigure;
segSelectbox.Position = [150 400 400 215];
segSelectbox.CloseRequestFcn = @(segSelectbox, evt)SaveButtonPushed(segSelectbox);
segSelectbox.Name = 'Specify Segment Durations';

% Create sdur label
sdurlbl = uilabel(segSelectbox);
sdurlbl.Position = [154 175 100 15];
sdurlbl.Text = 'duration (sec)';
sdurlbl.WordWrap = 'on';

% Create theta label
theta.lbl = uilabel(segSelectbox);
theta.lbl.Position = [45 150 80 15];
theta.lbl.Text = 'theta';
% Create theta sdur editfield
theta.sdur = uieditfield(segSelectbox, 'numeric');
theta.sdur.Position = [125 150 80 15];
theta.sdur.Value = 5;
theta.sdur.Limits = [0.2 10];

% Create alpha label
alpha.lbl = uilabel(segSelectbox);
alpha.lbl.Position = [45 125 80 15];
alpha.lbl.Text = 'alpha';
% Create alpha sdur editfield
alpha.sdur = uieditfield(segSelectbox, 'numeric');
alpha.sdur.Position = [125 125 80 15];
alpha.sdur.Value = 1;
alpha.sdur.Limits = [0.2 10];

% Create beta label
beta.lbl = uilabel(segSelectbox);
beta.lbl.Position = [45 100 80 15];
beta.lbl.Text = 'beta';
% Create beta sdur editfield
beta.sdur = uieditfield(segSelectbox, 'numeric');
beta.sdur.Position = [125 100 80 15];
beta.sdur.Value = 1;
beta.sdur.Limits = [0.2 10];

% Create gamma label
gamma.lbl = uilabel(segSelectbox);
gamma.lbl.Position = [45 75 80 15];
gamma.lbl.Text = 'gamma';
% Create beta sdur editfield
gamma.sdur = uieditfield(segSelectbox, 'numeric');
gamma.sdur.Position = [125 75 80 15];
gamma.sdur.Value = 1;
gamma.sdur.Limits = [0.2 10];

% Create SaveButton
btn = uibutton(segSelectbox, 'push');
btn.ButtonPushedFcn = @(btn, evt)SaveButtonPushed(segSelectbox);
btn.Position = [130 27 100 21];
btn.Text = 'Save';

% Create ValueChangedFcn pointers
theta.sdur.ValueChangedFcn    = @(sdur, evt)EditFieldValueChanged(theta);
alpha.sdur.ValueChangedFcn    = @(sdur, evt)EditFieldValueChanged(alpha);
beta.sdur.ValueChangedFcn     = @(sdur, evt)EditFieldValueChanged(beta);
gamma.sdur.ValueChangedFcn    = @(sdur, evt)EditFieldValueChanged(gamma);

% -------------------------------------------------------------------------
% Wait for user input and return selection after btn 'save' was pressed
% -------------------------------------------------------------------------
% Wait until btn is pushed
uiwait(segSelectbox);

if ishandle(segSelectbox)                                                    % if gui still exists
  segmentation = {theta.sdur.Value,  alpha.sdur.Value, ...                   % return existing selection
                  beta.sdur.Value,   gamma.sdur.Value, ...
                 };
  delete(segSelectbox);
else                                                                         % otherwise return default settings
  segmentation = {5,1,1,1};
end

end

% -------------------------------------------------------------------------
% Event Functions
% -------------------------------------------------------------------------
% Button pushed function: btn
function  SaveButtonPushed(segSelectbox)
  uiresume(segSelectbox);                                                    % resume from wait status                                                                             
end

