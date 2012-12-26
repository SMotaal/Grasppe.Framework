% Prompts for converting a value to data type char as a fallback.

% Copyright 2008-2009 Levente Hunyadi
function tf = converterrordlg(value, type)

if nargin < 2
    type = 'double';
end

if nargin < 1
    text = sprintf('Cannot convert the value to type "%s".\nRepresent the entered text as "char"?', type);
else
    text = sprintf('Cannot convert the value "%s" to type "%s".\nRepresent the entered text as "char"?', value, type);
end
reply = questdlg(text, 'Conversion not possible', 'Yes', 'No', 'No');
switch reply
    case 'Yes'
        tf = true;
    otherwise  % 'No' and empty
        tf = false;
end