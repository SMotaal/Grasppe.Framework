% Returns help text associated with an object.
% Spaces are removed as necessary.
%
% See also: helpdialog

% Copyright 2008-2009 Levente Hunyadi
function text = helptext(obj)

if ischar(obj)
    text = help(obj);
else
    text = help(class(obj));
end
text = texttrim(text);

% Concatenates lines that have been split into multiple lines.
function text = textunwrap(text)

text = strrep(text, sprintf('\n'), ' ');

% Trims leading and trailing whitespace characters from lines of text.
% The number of leading whitespace characters to trim is determined by
% inspecting all lines of text.
function lines = texttrim(text)

loc = strfind(text, sprintf('\n'));
n = numel(loc);
loc = [ 0 loc ];
lines = cell(n,1);
if ~isempty(loc)
    for k = 1 : n
        lines{k} = text(loc(k)+1 : loc(k+1));
    end
end
lines = deblank(lines);

% determine maximum leading whitespace count
whitelen = 0;
for k = 1 : n
    firstchar = find(~isspace(lines{k}), 1);  % index of first non-whitespace character
    if ~isempty(firstchar) && firstchar >= whitelen
        whitelen = firstchar - 1;
    end
end

% trim leading whitespace
for k = 1 : n
    line = lines{k};
    if numel(line) > whitelen
        lines{k} = line(whitelen+1:end);
    else
        lines{k} = '';
    end
end