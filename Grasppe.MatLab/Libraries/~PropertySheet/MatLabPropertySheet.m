% MatLab implementation of a property browser for custom objects.
%
% See also: PropertySheet

% Copyright 2008-2009 Levente Hunyadi
classdef MatLabPropertySheet < PropertySheet
    properties (Access = private)
        % Stores the value for SelectedIndex.
        CurrentIndex;
    end
    methods
        function obj = MatLabPropertySheet(varargin)
            obj = obj@PropertySheet(varargin{:});
        end
        
        function obj = Instantiate(obj, parent)
            contextmenu = uicontextmenu;
            uimenu(contextmenu, ...
                'Label', 'Edit', 'Callback', @(sender,event) obj.OnEditCell());
            uimenu(contextmenu, ...
                'Separator', 'on');
            uimenu(contextmenu, ...
                'Label', 'Edit as matrix', 'Callback', @(sender,event) obj.OnEditCellAsMatrix());
            uimenu(contextmenu, ...
                'Label', 'Edit as string', 'Callback', @(sender,event) obj.OnEditCellAsString());
            uimenu(contextmenu, ...
                'Separator', 'on');
            uimenu(contextmenu, ...
                'Label', 'Help', 'Callback', @(sender,event) obj.OnHelp());

            if nargin > 1
                obj.Container = uitable(parent);
            else
                obj.Container = uitable();
            end
            set(obj.Container, ...
                'ColumnEditable', true, ...
                'ColumnFormat', {'char'}, ...
                'ColumnName', {[]}, ...
                'ColumnWidth', {'auto'}, ...
                'TooltipString', 'Right-click for context menu, F2 to edit, F1 for help', ...
                'UIContextMenu', contextmenu, ...
                'ButtonDownFcn', @obj.OnMouseDown, ...
                'KeyPressFcn', @obj.OnKeyPressed, ...
                'CellSelectionCallback', @obj.OnPropertySelectedChanged, ...
                'CellEditCallback', @obj.OnPropertyChanged);
        end
        
        function index = SelectedIndex(obj)
            index = obj.CurrentIndex;
        end
    end
    methods (Access = protected)
        % Updates the property value displayed in the given row.
        % In addition to the specified property, all dependent properties
        % are also updated.
        function UpdateTableValue(obj, index, value)
            if nargin < 3
                value = obj.Item.(obj.ItemProperties(index).Name);
            end
            data = get(obj.Container, 'Data');
            data{index} = obj.ItemProperties(index).GetDisplayedText(value);
            for k = 1 : numel(obj.ItemProperties)  % requery values of dependent properties
                if obj.ItemProperties(k).Dependent
                    data{k} = obj.ItemProperties(k).GetDisplayedText(obj.GetPropertyValue(k));
                end
            end
            set(obj.Container, 'Data', data);
        end
        
        % Occurs when a new object is assigned for display.
        function OnItemSet(obj, item)
            n = numel(obj.ItemProperties);
            captions = cell(n, 1);  % property name as presented to user
            data = cell(n, 1);      % property value
            for k = 1 : n
                propname = obj.ItemProperties(k).Name;
                namelen = numel(propname);
                if namelen > 12  % abbreviate long names
                    captions{k} = [ propname(1:12) '...' ];
                else
                    captions{k} = propname;
                end
                value = item.(propname);
                data{k} = obj.ItemProperties(k).GetDisplayedText(value);
            end
            obj.CurrentIndex = [];
            set(obj.Container, 'RowName', captions);
            set(obj.Container, 'Data', data);
        end
        
        % Occurs when the user selects "Edit" in the context menu.
        function OnEditCell(obj)
            row = obj.CurrentIndex;
            if ~isempty(row)
                % fetch property value and text displayed in table
                name = obj.ItemProperties(row).Name;
                value = obj.Item.(name);
                
                if isa(value, 'Root')  % supports framework metadata facility
                    value = selectobjecttype(value);
                end

                % bring forth the appropriate editor
                editor = obj.ItemProperties(row).GetEditor();
                if ~isempty(editor)
                    % save value currently in editor (editor dialogs are re-used)
                    editoritem = editor.Item;
                    
                    % let the user change the value with the editor
                    editor.Item = value;
                    editor.ShowDialog();
                    value = editor.Item;
                    
                    % reset original value in editor
                    editor.Item = editoritem;
                    
                    % update property value and text displayed in table
                    obj.UpdateItemPropertyValue(name, value);
                    obj.UpdateTableValue(row);
                    
                    % notify event listeners
                    notify(obj, 'PropertyValueChanged', PropertyChangedEventData(row, name));
                end
            end
        end
        
        % Occurs when "Edit as matrix" is selected in the context menu.
        function OnEditCellAsMatrix(obj)
            
        end
        
        % Occurs when "Edit as string" is selected in the context menu.
        function OnEditCellAsString(obj)
            row = obj.CurrentIndex;
            if ~isempty(row)
                % fetch true and displayed value
                name = obj.ItemProperties(row).Name;
                value = obj.Item.(name);
                defaulttext = obj.ItemProperties(row).GetDisplayedText(value);
                
                % prompt user for new data
                answer = inputdlg(sprintf('Type new value for %s', name), 'Edit value', 8, {defaulttext});
                if ~isempty(answer)
                    text = answer{1};
                else
                    text = defaulttext;
                end
                
                % update changes if necessary
                if ~strcmp(defaulttext, text)  % user changed default string
                    [value,error] = obj.ItemProperties(row).GetTrueValue(text);
                    if isempty(error)
                        % update property value and text displayed in table
                        obj.UpdateItemPropertyValue(obj.ItemProperties(row).Name, value);
                        obj.UpdateTableValue(row);
                        
                        % notify event listeners
                        notify(obj, 'PropertyValueChanged', PropertyChangedEventData(row, name));
                    end
                end
            end
        end

        % Occurs when the user selects "Help" in the context menu.
        function OnHelp(obj)
            item = obj.SelectedProperty;
            if ~isempty(item)
                name = [class(obj.Item) '.' item.Name];  % fully qualified property name
                helpdialog(name);
            end
        end
        
        function OnMouseDown(obj, source, event)
            fig = ancestor(obj.Container, 'figure');
            p = get(fig, 'CurrentPoint');
        end
        
        function OnKeyPressed(obj, source, event) %#ok<INUSL>
            if isempty(event.Modifier)  % no control, alt or shift key pressed
                switch event.Key
                    case 'f1'
                        obj.OnHelp();
                    case 'f2'
                        obj.OnEditCell();
                end
            end
        end

        % Occurs when the user selects a property.
        function OnPropertySelectedChanged(obj, source, event) %#ok<INUSL>
            if numel(event.Indices) > 0
                obj.CurrentIndex = event.Indices(1);
            else
                obj.CurrentIndex = [];
            end
        end

        % Occurs when the user has finished editing the value of a property.
        function OnPropertyChanged(obj, source, event) %#ok<INUSL>
            if numel(event.Indices) > 0
                row = event.Indices(1);
                if ~strcmp(event.PreviousData, event.EditData)  % user changed displayed string
                    [value,error] = obj.ItemProperties(row).GetTrueValue(event.EditData);
                    if isempty(error)
                        % update property value, text displayed in table is already set
                        obj.UpdateItemPropertyValue(obj.ItemProperties(row).Name, value);
                        obj.UpdateTableValue(row);
                    else
                        % reset previous data
                        obj.UpdateTableValue(row, event.PreviousData);
                    end
                end
            end
        end
    end
end
