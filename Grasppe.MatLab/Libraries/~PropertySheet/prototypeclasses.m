% A cell array of classes that can be instantiated with empty constructor.
%
% Input arguments:
% packagename:
%    the package in which to look for classes with zero argument (or
%    so-called default) constructors
% option:
%    "disk" or "memory", indicating whether to look for any .m file on the
%    directory hierarchy or consider only memory-resident classes
%    accessible via meta.package.Classes

% Copyright 2008-2009 Levente Hunyadi
function instances = prototypeclasses(packagename, option)

if nargin < 2
    option = 'disk';
else
    option = validatestring(option, {'disk','memory'});
end
switch option
    case 'disk'
        instances = diskprototypeclasses(packagename);
    case 'memory'
        instances = memoryprototypeclasses(packagename);
end

% Prototype classes by inspecting classes loaded in memory.
function instances = memoryprototypeclasses(packagename)

% count number of non-abstract classes in memory
n = 0;
classmetalist = meta.package.fromName(packagename).Classes;
for i = 1 : length(classmetalist)
    classmeta = classmetalist{i};
    if ~isabstractclass(classmeta)
        n = n + 1;
    end
end

% instantiate non-abstract classes
instances = cell(n, 1);
n = 0;
for i = 1 : length(classmetalist)
    classmeta = classmetalist{i};
    if ~isabstractclass(classmeta)
        n = n + 1;
        instance = feval(classmeta.Name);  % instantiate class using constructor name
        instances{n} = instance;
    end
end

function tf = isabstractclass(classmeta)

validateattributes(classmeta, {'meta.class'}, {});

for i = 1 : length(classmeta.Methods)
    methodmeta = classmeta.Methods{i};
    if methodmeta.Abstract && methodmeta.DefiningClass == classmeta
        tf = true;
        return;
    end
end
tf = false;

% Prototype instances by directory inspection.
% Locates directories with the specified package name that are not within the
% standard MatLab toolbox path and successively tries to instantiate any
% classes it finds with the default constructor.
%
% Output arguments:
%    a list of class instances that could be instantiated with a zero argument
%    constructor
function instances = diskprototypeclasses(packagename)

n = 0;
items = what(packagename);  % locate package candidates
for i = 1 : numel(items)
    dir = items(i).path;
    if ~ismatlabtoolbox(dir)  % test if package is in a MatLab toolbox
        mfilenames = items(i).m;
        for j = 1 : numel(mfilenames)
            if istypicalclassname(mfilenames{j})  % test if name is likely to be a class name
                [pathstr, name, ext, versn] = fileparts(mfilenames{j}); %#ok<NASGU>
                try
                    instance = feval([packagename '.' name]);  % try to instantiate class
                    n = n + 1;
                    instances{n} = instance; %#ok<AGROW>
                catch me
                    switch me.identifier
                        case 'MATLAB:class:abstract'
                            % do nothing if instantiation fails
                        otherwise
                            rethrow(me);
                    end
                end
            end
        end
    end
end

% Test if a directory corresponds to a standard MatLab toolbox directory.
function tf = ismatlabtoolbox(directory)

n = numel(matlabroot);
tf = numel(directory) >= n && strncmp(directory, matlabroot, n);  % directory is within MatLab installation path

% Test if a file name is a typical class name.
% Typical class names are mixed case, e.g. "AutoregressiveMovingAverage.m".
function tf = istypicalclassname(filename)

tf = ~strncmp(filename, 'Contents', numel('Contents')) && filename(1) == upper(filename(1));