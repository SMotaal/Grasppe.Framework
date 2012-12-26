% Sample property sheet.
%
% See also: PropertySheet, SwingPropertySheet

% Copyright 2009 Levente Hunyadi
function example_propertysheet

javastartup;

f = figure;

% object whose properties to display
o = SampleObject;

% create property sheet
p = PropertySheetFactory.Create(f, ...
    'Units', 'normalized', ...
    'Position', [0.0, 0.0, 1.0, 1.0], ...
    'Item', o);

% wait for figure to be closed
uiwait(f);

% retrieve changed object from property sheet
disp(p.Item);