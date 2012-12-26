% An editor instance for changing matrix element values.

% Copyright 2008-2009 Levente Hunyadi
function dlg = MatrixEditorDialog()

persistent instance;
if isempty(instance)
    instance = EditorDialog( ...
        'EditorControl', MatrixEditor());
end
dlg = instance;