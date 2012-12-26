% An editor instance of editing strings.

% Copyright 2008-2009 Levente Hunyadi
function dlg = StringEditorDialog()

persistent instance;
if isempty(instance)
    instance = EditorDialog( ...
        'EditorControl', uicontrol('Style','edit'));
end
dlg = instance;
