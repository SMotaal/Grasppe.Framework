% Check if version is at least the minimum version specified.
%
% See also: ver, version, verLessThan

% Copyright 2009 Levente Hunyadi
function tf = assertversion(currentversion, minimumversion)

currentversion = getversion(currentversion);
minimumversion = getversion(minimumversion);

for k = 1 : numel(currentversion)
    if currentversion(k) < minimumversion(k)
        if nargout > 0
            tf = false;
        else
            callererror('assertversion:InvalidOperation', 'Version mismatch, current: %s, expected: %s', getversionstring(currentversion), getversionstring(minimumversion));
        end
        return;
    elseif currentversion(k) > minimumversion(k)
        break;
    end
end
tf = true;

function versionnumber = getversion(versionidentifier)

if ischar(versionidentifier)  % convert text to version number sequence
    versionnumber = getversionnumber(versionidentifier);
else
    versionnumber = versionidentifier;
end
versionnumber = standardizeversion(versionnumber);

% Converts a version number into a standardized format.
% A standard version number takes the format [major minor revision build].
function versionnumber = standardizeversion(versionnumber)

validateattributes(versionnumber, {'numeric'}, {'nonempty','real','integer','row'});
assert(numel(versionnumber) <= 4, ...
    'progtool:assertversion:InvalidArgumentValue', ...
    'Version number is expected to take the format [major minor revision build].');
if numel(versionnumber) < 4  % add minor version, revision and build if omitted
    versionnumber = [versionnumber, zeros(1, 4-numel(versionnumber))];
end

% Convert a version text into a version number.
function versionnumber = getversionnumber(versiontext)

validateattributes(versiontext, {'char'}, {'nonempty','row'});
[startpos,endpos] = regexp(versiontext, '\d+(?:\.\d+){1,3}', 'once', 'warnings', 'start', 'end');
versiontext = versiontext(startpos:endpos);
versionnumber = sscanf(versiontext, '%d.%d.%d.%d')';  % major version, minor version, revision, build

function versiontext = getversionstring(versionnumber)

validateattributes(versionnumber, {'numeric'}, {'nonempty','real','integer','row'});
versionnumber = standardizeversion(versionnumber);
versiontext = sprintf('%d.%d.%d.%d', versionnumber(1), versionnumber(2), versionnumber(3), versionnumber(4));