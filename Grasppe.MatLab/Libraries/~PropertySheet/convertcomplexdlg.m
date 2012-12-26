% Prompts for converting a real data type to complex.

% Copyright 2008-2009 Levente Hunyadi
function tf = convertcomplexdlg(value, type)

if nargin < 2
    type = 'double';
end

if nargin < 1
    text = sprintf('The value cannot be represented as a real "%s".\nConvert the underlying type to complex?', type);
else
    text = sprintf('The value "%s" cannot be represented as a real "%s".\nConvert the underlying type to complex?', value, type);
end
reply = questdlg(text, 'Real to complex conversion required', 'Yes', 'No', 'No');
switch reply
    case 'Yes'
        tf = true;
    otherwise  % 'No' and empty
        tf = false;
end