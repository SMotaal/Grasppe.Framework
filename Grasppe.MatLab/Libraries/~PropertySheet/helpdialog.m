% Displays a dialog to give help information on an object.
%
% See also: msgbox

% Copyright 2008-2009 Levente Hunyadi
function helpdialog(obj)

text = helptext(obj);
if ~isempty(text)
    createmode = struct( ...
        'WindowStyle', 'replace', ...
        'Interpreter', 'none');
    msgbox(text, 'Quick help', 'help', createmode);
else
    msgbox('No help available.', 'Quick help', 'help', 'replace');
end