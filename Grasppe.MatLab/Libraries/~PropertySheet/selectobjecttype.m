% Prompts to choose the object class.
% The function is usually called when the user wishes to assign a new value
% to a class property and the new value has a different but related class
% as compared to the current value. Related is defined as being in the same
% package as the class of the current value.
% The user is prompted a dialog box with a list of class candidates. Two
% buttons are displayed:
% * "Keep": the current object is kept, the value is returned unchanged
% * "Change": the current object is lost and a new instance of the selected
%    class is returned
%
% Input arguments:
% obj:
%    a class for which related classes are to be presented
%
% Output arguments:
% obj:
%    the input argument unchanged, or a new instance of the class selected
%    by the user
function obj = selectobjecttype(obj)

compoundname = class(obj);
dotpositions = strfind(compoundname, '.');  % position of class separator
if isempty(dotpositions)
    packagename = '';  % not included in any package
else
    packagename = compoundname(1 : dotpositions(end)-1);
end
instances = prototypeclasses(packagename);  % class instances in same package
classnames = cell(numel(instances), 1);     % name of classes in same package
initialselection = [];
for i = 1 : numel(instances)
    classnames{i} = class(instances{i});
    if strcmp(compoundname, classnames{i})
        initialselection = i;
    end
end

selection = listdlg( ...
    'SelectionMode', 'single', ...
    'Name', 'Choose object type', ...
    'OKString', 'Change', ...
    'CancelString', 'Keep', ...
    'ListString', classnames, ...
    'InitialValue', initialselection ...
);
if ~isempty(selection) && ~strcmp(compoundname, classnames(selection))  % test for proper button and whether the selection actually changed
    obj = instances{selection};                        
end
