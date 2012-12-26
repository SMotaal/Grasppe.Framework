% A modal dialog box which encapsulates a single item editor control.
% The dialog box usually appears when the value of a complex property is
% about to be modified but it cannot be edited in-place as a string, such
% as a matrix or a MatLab object.
%
% See also: MatrixEditor, PropertySheet

% Copyright 2008-2009 Levente Hunyadi
classdef EditorDialog < UIControl
    properties
        Item;
        EditorControl;
    end
    properties (Dependent)
        Control;
    end
    properties (Access = protected)
        Dialog;
    end
    methods
        function obj = EditorDialog(varargin)
            obj = obj@UIControl(varargin{:});
        end
        
        function obj = Instantiate(obj, parent) %#ok<INUSD>
            if isempty(obj.Dialog)
                obj.Dialog = dialog( ...
                    'Name', 'Edit item', ...
                    'Visible', 'off', ...
                    'CloseRequestFcn', @obj.OnClose);
            end
        end
        
        function obj = ShowDialog(obj)
            set(obj.Dialog, 'Visible', 'on');
            uiwait(obj.Dialog);
        end

        function control = get.Control(obj)
            control = obj.Dialog;
        end
        
        function obj = set.Item(obj, item)
            obj.Item = item;
            if ~isempty(obj.EditorControl)
                obj.SetEditorControlValue();
            end
        end
        
        function obj = set.EditorControl(obj, control)
            obj.EditorControl = control;
            if isobject(obj.EditorControl) && isa(obj.EditorControl, 'UIControl')  % a UIControl with the Parent property
                obj.EditorControl.Parent = obj.Dialog;
                obj.EditorControl.NormalizedPosition = [0,0,1,1];  % enlarge control to take up all available space
            elseif ishandle(obj.EditorControl)  % a handle graphics object with Parent property
                set(obj.EditorControl, 'Parent', obj.Dialog);
                set(obj.EditorControl, 'Units', 'normalized');
                set(obj.EditorControl, 'Position', [0,0,1,1]);
                if strcmp(get(obj.EditorControl, 'Type'), 'uicontrol') && strcmp(get(obj.EditorControl, 'Style'), 'edit')  % make handle graphics edit control left-aligned and multi-line
                    set(obj.EditorControl, 'HorizontalAlignment', 'left');
                    set(obj.EditorControl, 'Max', 16);  % Max-Min > 1 makes edit control multi-line
                    set(obj.EditorControl, 'Min', 1);
                end
            end
            if ~isempty(obj.Item)
                obj.SetEditorControlValue();
            end
        end
    end
    methods (Access = protected)
        % Set the editor's Item property based on the editor control value.
        function obj = RetrieveEditorControlValue(obj)
            if isobject(obj.EditorControl) && isa(obj.EditorControl, 'UIControl')  % a UIControl with the Item property
                obj.Item = obj.EditorControl.Item;
            elseif ishandle(obj.EditorControl)  % a handle graphics object with String property
                obj.Item = get(obj.EditorControl, 'String');
            end
        end
        
        % Set the editor control value based on the editor's Item property.
        function obj = SetEditorControlValue(obj)
            if isobject(obj.EditorControl) && isa(obj.EditorControl, 'UIControl')  % a UIControl with the Item property
                obj.EditorControl.Item = obj.Item;
            elseif ishandle(obj.EditorControl)  % a handle graphics object with String property
                set(obj.EditorControl, 'String', obj.Item);
            end
        end

        % Occurs when the editor is about to be closed.
        function obj = OnClose(obj, source, event) %#ok<INUSD>
            try  % even if an error occurs, hide the window
                % persist edited item to class property
                obj.RetrieveEditorControlValue();
                uiresume(obj.Dialog);
                set(obj.Dialog, 'Visible', 'off');
            catch me
                obj.Item = [];
                uiresume(obj.Dialog);
                set(obj.Dialog, 'Visible', 'off');
                rethrow(me);
            end
        end
    end
end