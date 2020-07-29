function [ badLabel ] = DEEP_channelCheckbox( cfg )
% DEEP_CHANNELCHECKBOX is a function, which displays a small GUI for the 
% selection of bad channels. It returns a cell array including the labels
% of the bad channels
%
% Use as
%   [ badLabel ]  = DEEP_channelCheckbox( cfg )
%
% The configuration options are
%   cfg.maxchan   = The maximum number of channels, which can marked as bad. (default: 2)
%                   This value should not be greater than 10% of the total number of channels
%
% This function requires the fieldtrip toolbox.
%
% SEE also UIFIGURE, UICHECKBOX, UIBUTTON, UIRESUME, UIWAIT

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
maxchan  = ft_getopt(cfg, 'maxchan', 2);

% -------------------------------------------------------------------------
% Create GUI
% -------------------------------------------------------------------------
SelectBadChannels = uifigure;
SelectBadChannels.Position = [150 400 535 235];
SelectBadChannels.Name = 'Select bad channels';

warningLabel = uilabel(SelectBadChannels);
warningLabel.Position = [55 205 410 15];
warningLabel.FontColor = [1,0.5,0];
warningLabel.Text = '';

% Create FzCheckBox
Elec.Fz = uicheckbox(SelectBadChannels);
Elec.Fz.Text = 'Fz';
Elec.Fz.Position = [45 175 80 15];
% Create F3CheckBox
Elec.F3 = uicheckbox(SelectBadChannels);
Elec.F3.Text = 'F3';
Elec.F3.Position = [125 175 80 15];
% Create F7CheckBox
Elec.F7 = uicheckbox(SelectBadChannels);
Elec.F7.Text = 'F7';
Elec.F7.Position = [205 175 80 15];
% Create F9CheckBox
Elec.F9 = uicheckbox(SelectBadChannels);
Elec.F9.Text = 'F9';
Elec.F9.Position = [285 175 80 15];
Elec.F9.Enable = 'off';
% Create FT7CheckBox
Elec.FT7 = uicheckbox(SelectBadChannels);
Elec.FT7.Text = 'FT7';
Elec.FT7.Position = [365 175 80 15];
% Create FC3CheckBox
Elec.FC3 = uicheckbox(SelectBadChannels);
Elec.FC3.Text = 'FC3';
Elec.FC3.Position = [445 175 80 15];

% Create FC1CheckBox
Elec.FC1 = uicheckbox(SelectBadChannels);
Elec.FC1.Text = 'FC1';
Elec.FC1.Position = [45 150 80 15];
% Create CzCheckBox
Elec.Cz = uicheckbox(SelectBadChannels);
Elec.Cz.Text = 'Cz';
Elec.Cz.Position = [125 150 80 15];
% Create C3CheckBox
Elec.C3 = uicheckbox(SelectBadChannels);
Elec.C3.Text = 'C3';
Elec.C3.Position = [205 150 80 15];
% Create T7CheckBox
Elec.T7 = uicheckbox(SelectBadChannels);
Elec.T7.Text = 'T7';
Elec.T7.Position = [285 150 80 15];
% Create CP3CheckBox
Elec.CP3 = uicheckbox(SelectBadChannels);
Elec.CP3.Text = 'CP3';
Elec.CP3.Position = [365 150 80 15];
% Create PzCheckBox
Elec.Pz = uicheckbox(SelectBadChannels);
Elec.Pz.Text = 'Pz';
Elec.Pz.Position = [445 150 80 15];

% Create P3CheckBox
Elec.P3 = uicheckbox(SelectBadChannels);
Elec.P3.Text = 'P3';
Elec.P3.Position = [45 125 80 15];
% Create P7CheckBox
Elec.P7 = uicheckbox(SelectBadChannels);
Elec.P7.Text = 'P7';
Elec.P7.Position = [125 125 80 15];
% Create PO9CheckBox
Elec.PO9 = uicheckbox(SelectBadChannels);
Elec.PO9.Text = 'PO9';
Elec.PO9.Position = [205 125 80 15];
% Create O1CheckBox
Elec.O1 = uicheckbox(SelectBadChannels);
Elec.O1.Text = 'O1';
Elec.O1.Position = [285 125 80 15];
% Create O2CheckBox
Elec.O2 = uicheckbox(SelectBadChannels);
Elec.O2.Text = 'O2';
Elec.O2.Position = [365 125 80 15];
% Create PO10CheckBox
Elec.PO10 = uicheckbox(SelectBadChannels);
Elec.PO10.Text = 'PO10';
Elec.PO10.Position = [445 125 80 15];

% Create P8CheckBox
Elec.P8 = uicheckbox(SelectBadChannels);
Elec.P8.Text = 'P8';
Elec.P8.Position = [45 100 80 15];
% Create P4CheckBox
Elec.P4 = uicheckbox(SelectBadChannels);
Elec.P4.Text = 'P4';
Elec.P4.Position = [125 100 80 15];
% Create CP4CheckBox
Elec.CP4 = uicheckbox(SelectBadChannels);
Elec.CP4.Text = 'CP4';
Elec.CP4.Position = [205 100 80 15];
% Create TP10CheckBox
Elec.TP10 = uicheckbox(SelectBadChannels);
Elec.TP10.Text = 'TP10';
Elec.TP10.Position = [285 100 80 15];
% Create T8CheckBox
Elec.T8 = uicheckbox(SelectBadChannels);
Elec.T8.Text = 'T8';
Elec.T8.Position = [365 100 80 15];
% Create C4CheckBox
Elec.C4 = uicheckbox(SelectBadChannels);
Elec.C4.Text = 'C4';
Elec.C4.Position = [445 100 80 15];

% Create FT8CheckBox
Elec.FT8 = uicheckbox(SelectBadChannels);
Elec.FT8.Text = 'FT8';
Elec.FT8.Position = [45 75 80 15];
% Create FC4CheckBox
Elec.FC4 = uicheckbox(SelectBadChannels);
Elec.FC4.Text = 'FC4';
Elec.FC4.Position = [125 75 80 15];
% Create FC2CheckBox
Elec.FC2 = uicheckbox(SelectBadChannels);
Elec.FC2.Text = 'FC2';
Elec.FC2.Position = [205 75 80 15];
% Create F4CheckBox
Elec.F4 = uicheckbox(SelectBadChannels);
Elec.F4.Text = 'F4';
Elec.F4.Position = [285 75 80 15];
% Create F8CheckBox
Elec.F8 = uicheckbox(SelectBadChannels);
Elec.F8.Text = 'F8';
Elec.F8.Position = [365 75 80 15];
% Create F10CheckBox
Elec.F10 = uicheckbox(SelectBadChannels);
Elec.F10.Text = 'F10';
Elec.F10.Position = [445 75 80 15];
Elec.F10.Enable = 'off';

% Create SaveButton
btn = uibutton(SelectBadChannels, 'push');
btn.ButtonPushedFcn = @(btn, evt)SaveButtonPushed(SelectBadChannels);
btn.Position = [217 27 101 21];
btn.Text = 'Save';

% Create ValueChangedFcn pointers
Elec.Fz.ValueChangedFcn = @(Fz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F3.ValueChangedFcn = @(F3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F7.ValueChangedFcn = @(F7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F9.ValueChangedFcn = @(F9, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FT7.ValueChangedFcn = @(FT7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC3.ValueChangedFcn = @(FC3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC1.ValueChangedFcn = @(FC1, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.Cz.ValueChangedFcn = @(Cz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.C3.ValueChangedFcn = @(C3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.T7.ValueChangedFcn = @(T7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.CP3.ValueChangedFcn = @(CP3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.Pz.ValueChangedFcn = @(Pz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P3.ValueChangedFcn = @(P3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P7.ValueChangedFcn = @(P7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.PO9.ValueChangedFcn = @(P09, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.O1.ValueChangedFcn = @(O1, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.O2.ValueChangedFcn = @(O2, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.PO10.ValueChangedFcn = @(PO10, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P8.ValueChangedFcn = @(P8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P4.ValueChangedFcn = @(P4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.CP4.ValueChangedFcn = @(CP4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.TP10.ValueChangedFcn = @(TP10, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.T8.ValueChangedFcn = @(T8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.C4.ValueChangedFcn = @(C4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FT8.ValueChangedFcn = @(FT8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC4.ValueChangedFcn = @(FC4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC2.ValueChangedFcn = @(FC2, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F4.ValueChangedFcn = @(F4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F8.ValueChangedFcn = @(F8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F10.ValueChangedFcn = @(F10, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);

% -------------------------------------------------------------------------
% Wait for user input and return selection after btn 'save' was pressed
% -------------------------------------------------------------------------
% Wait until btn is pushed
uiwait(SelectBadChannels);

if ishandle(SelectBadChannels)                                              % if gui still exists
  badLabel = [Elec.Fz.Value; Elec.F3.Value; Elec.F7.Value; ...              % return existing selection
              Elec.F9.Value; Elec.FT7.Value; Elec.FC3.Value; ...
              Elec.FC1.Value; Elec.Cz.Value; Elec.C3.Value; ...
              Elec.T7.Value; Elec.CP3.Value; Elec.Pz.Value; ...
              Elec.P3.Value; Elec.P7.Value; Elec.PO9.Value; ...
              Elec.O1.Value; Elec.O2.Value; Elec.PO10.Value; ...
              Elec.P8.Value; Elec.P4.Value; Elec.CP4.Value; ...
              Elec.TP10.Value; Elec.T8.Value; Elec.C4.Value; ...
              Elec.FT8.Value; Elec.FC4.Value; Elec.FC2.Value; ...
              Elec.F4.Value; Elec.F8.Value; Elec.F10.Value];
  label    = {'Fz', 'F3', 'F7', 'F9', 'FT7', 'FC3', 'FC1' 'Cz', 'C3', ...
              'T7', 'CP3', 'Pz', 'P3', 'P7', 'PO9', 'O1', 'O2', 'PO10',...
              'P8', 'P4', 'CP4', 'TP10', 'T8', 'C4', 'FT8', 'FC4', ...
              'FC2', 'F4', 'F8', 'F10'};
  badLabel = label(badLabel);
  if isempty(badLabel)
    badLabel = [];
  end
  delete(SelectBadChannels);                                                % close gui
else                                                                        % if gui was already closed (i.e. by using the close symbol)
  badLabel = [];                                                            % return empty selection
end

end

% -------------------------------------------------------------------------
% Event Functions
% -------------------------------------------------------------------------
% Button pushed function: btn
function  SaveButtonPushed(SelectBadChannels)
  uiresume(SelectBadChannels);                                              % resume from wait status                                                                             
end

% Checkbox value changed function
function  CheckboxValueChanged(Elec, warningLabel, btn, maxchan)
  badLabel = [Elec.Fz.Value; Elec.F3.Value; Elec.F7.Value; ...              % get status of all checkboxes
              Elec.F9.Value; Elec.FT7.Value; Elec.FC3.Value; ...
              Elec.FC1.Value; Elec.Cz.Value; Elec.C3.Value; ...
              Elec.T7.Value; Elec.CP3.Value; Elec.Pz.Value; ...
              Elec.P3.Value; Elec.P7.Value; Elec.PO9.Value; ...
              Elec.O1.Value; Elec.O2.Value; Elec.PO10.Value; ...
              Elec.P8.Value; Elec.P4.Value; Elec.CP4.Value; ...
              Elec.TP10.Value; Elec.T8.Value; Elec.C4.Value; ...
              Elec.FT8.Value; Elec.FC4.Value; Elec.FC2.Value; ...
              Elec.F4.Value; Elec.F8.Value; Elec.F10.Value];
  NumOfBad = sum(double(badLabel));
  if NumOfBad > maxchan
    warningLabel.Text = sprintf(['Too many channels selected! It''s '...
                  'only allowed to repair maximum %d channels.'], maxchan);
    btn.Enable = 'off';
  else
    warningLabel.Text = '';
    btn.Enable = 'on';
  end    
end
