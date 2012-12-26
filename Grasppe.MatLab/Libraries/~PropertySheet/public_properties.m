% Public properties of a MatLab object.
%
% Input arguments:
% obj:
%    the new-style MatLab object whose public properties to extract
%
% Output arguments:
% objprops:
%    a list of public property names as a cell array of strings

% Copyright 2008-2009 Levente Hunyadi
function objprops = public_properties(obj)

n = 0;
objclass = metaclass(obj);
for i = 1 : numel(objclass.Properties)
    objproperty = objclass.Properties{i};
    if is_public_property(objproperty)
        n = n + 1;
    end
end

objprops = cell(n, 1);
j = 0;
for i = 1 : numel(objclass.Properties)
    objproperty = objclass.Properties{i};
    if is_public_property(objproperty)
        j = j + 1;
        objprops{j} = objproperty;
    end
end
