% An editor instance for editing objects.

% Copyright 2008-2009 Levente Hunyadi
function dlg = PropertySheetDialog()

persistent instance;
if isempty(instance)
    instance = EditorDialog( ...
        'EditorControl', PropertySheetFactory.Create());
end
dlg = instance;