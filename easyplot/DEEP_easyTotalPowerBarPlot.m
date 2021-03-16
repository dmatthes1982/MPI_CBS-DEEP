function DEEP_easyTotalPowerBarPlot( cfg, data )
% DEEP_EASYTOTALPOWERBARPLOT shows the total power of all available
% channels. The channels are ordered in ascending order and outliers are
% highlighted.
% 
% Use as
%   DEEP_easyTotalPowerBarPlot( cfg, data)
%
% where the input has to be a result of DEEP_SELECTBADCHAN.
%
% The configuration option is
%   cfg.part = identifier of participant, 'mother' or 'child' (default: 'mother')
%
% This function requires the fieldtrip toolbox
%
% See also DEEP_SELECTBADCHAN

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part = ft_getopt(cfg, 'part', 'mother');

if ~ismember(part, {'mother', 'child'})                                     % check cfg.part definition
  error('cfg.part has to either ''mother'' or ''child''.');
end

switch part
  case 'mother'
    data = data.mother;
  case 'child'
    data = data.child;
end

% -------------------------------------------------------------------------
% Create the bar plot
% -------------------------------------------------------------------------
[pow, index] = sort(data.totalpow);                                         % sort the channels in ascending order

outliers  = data.outliers(index);
label     = data.label(index);

figure();
b = bar(pow);
b.FaceColor   = 'flat';
b.CData(outliers,:)  = repmat([1,0,0], sum(outliers), 1); 
set(gca, 'XTick', 1:numel(label), 'XTickLabel', label);

dim = [0.2 0.5 0.4 0.3];                                                    % add textbox with statistical information
q3  = sprintf('Q3:          %d', data.quartile(3));
m   = sprintf('Median:   %d', data.quartile(2));
q1  = sprintf('Q1:          %d', data.quartile(1));
iq  = sprintf('IQR:         %d', data.interquartile);
bp  = sprintf('BP:          %d...%d Hz', data.freqrange{1});
str = {'Info box:', '', q3, m, q1, iq, 'Outliers:  > 1.5 * IQR + Q3', bp};
annotation('textbox',dim,'String',str,'FitBoxToText','on',...
            'BackgroundColor','white');

end
