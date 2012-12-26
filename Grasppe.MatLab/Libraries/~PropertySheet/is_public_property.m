% True if the property designates a public, accessible property.

% Copyright 2008-2009 Levente Hunyadi
function tf = is_public_property(property)

tf = ~property.Abstract && ~property.Hidden && strcmp(property.GetAccess, 'public') && strcmp(property.SetAccess, 'public');
