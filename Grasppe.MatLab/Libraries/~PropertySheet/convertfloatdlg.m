% Prompts for converting a data type to floating-point double precision.

% Copyright 2008-2009 Levente Hunyadi
function tf = convertfloatdlg(value, type)

if nargin < 2
    type = 'int32';
end

if nargin < 1
    text = sprintf('The value cannot be represented as "%s".\nConvert the underlying type to "double"?', type);
else
    text = sprintf('The value "%s" cannot be represented as "%s".\nConvert the underlying type to "double"?', value, type);
end
reply = questdlg(text, sprintf('Conversion from %s to double required', type), 'Yes', 'No', 'No');
switch reply
    case 'Yes'
        tf = true;
    otherwise  % 'No' and empty
        tf = false;
end