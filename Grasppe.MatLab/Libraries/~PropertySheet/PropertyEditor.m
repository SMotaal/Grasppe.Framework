% A property editor for custom objects.
% The property editor consists of a dropdown list that the contains a list
% of object instances and a property browser that lets the user inspect and
% modify the property values of the selected instance.

% Copyright 2008-2009 Levente Hunyadi
classdef PropertyEditor < UIControl
    properties
        % The list of items selectable in the object browser.
        Items;
        % Whether to automatically add new elements when an item is set
        % through SelectedItem that does not exist in Items.
        AutoAdd = true;
    end
    properties (Dependent)
        Control;
        % The caption displayed at the top of the propety editor.
        Title;
        % The item currently selected in the dropdown list
        SelectedItem;
    end
    properties (Access = protected)
        Panel;
        ComboBox;
        PropertySheet;
        % The index of the item currently selected in the dropdown list.
        SelectedIndex;
    end
    methods
        function obj = PropertyEditor(varargin)
            obj = obj@UIControl(varargin{:});
            if ~isempty(obj.Items)
                obj.PropertySheet.Item = obj.Items{1};
            end
        end
        
        function obj = Instantiate(obj, parent)
            if nargin > 1
                obj.Panel = uipanel(parent);
            else
                obj.Panel = uipanel();
            end
            set(obj.Panel, 'ResizeFcn', @obj.OnResize);
            obj.ComboBox = uicontrol(obj.Panel, ...
                'Units', 'normalized', ...
                'Position', [0, 0.8, 1, 0.2], ...
                'String', {'[empty]'}, ...
                'Style', 'popupmenu', ...
                'Callback', @obj.OnSelectedIndexChanged);
            obj.PropertySheet = PropertySheetFactory.Create(obj.Panel, ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 0.8]);
        end

        function control = get.Control(obj)
            control = obj.Panel;
        end
        
        function title = get.Title(obj)
            title = set(obj.Panel, 'Title');
        end
        
        function obj = set.Title(obj, title)
            set(obj.Panel, 'Title', title);
        end
        
        function obj = set.Items(obj, items)
            validateattributes(items, {'cell'}, {'vector'});
            
            obj.Items = items;
            % explore object instances
            names = cell(length(items), 1);
            for i = 1 : length(items)
                itemclass = metaclass(items{i});
                names{i} = itemclass.Name;
            end
            set(obj.ComboBox, 'String', names);
        end
        
        function obj = set.SelectedItem(obj, item)
            for i = 1 : length(obj.Items)
                if item == obj.Items{i}  % test for object equality
                    set(obj.ComboBox, 'Value', i);
                    obj.SelectedIndex = i;
                    return;
                end
            end
            if obj.AutoAdd
                obj.Items{ numel(obj.Items)+1 } = item;  % add as new element if not found
                set(obj.ComboBox, 'Value', numel(obj.Items));
                obj.SelectedIndex = numel(obj.Items);
            else  % item not found in list of items
                obj.SelectedIndex = 0;  % no item is selected
            end
        end
        
        function item = get.SelectedItem(obj)
            index = obj.SelectedIndex;
            if index > 0
                item = obj.Items{index};
            else
                item = [];  % nothing is selected
            end
        end
        
        function obj = set.SelectedIndex(obj, newindex)
            if ~isempty(obj.Items)
                oldindex = obj.SelectedIndex;
                
                % persist previously selected item if any
                item = obj.PropertySheet.Item;
                if ~isempty(oldindex) && oldindex > 0 && ~isempty(item)
                    obj.Items{oldindex} = item;  % this has no virtual effect for reference objects but necessary for value objects
                end

                % get item that corresponds to selected index
                item = obj.Items{newindex};

                % fill property browser
                obj.PropertySheet.Item = item;
            else
                obj.PropertySheet.Item = [];
            end
            obj.SelectedIndex = newindex;
        end
    end
    methods (Access = protected)
        function obj = OnSelectedIndexChanged(obj, source, event) %#ok<INUSD>
            % get index of selected item
            index = get(obj.ComboBox, 'Value');
            if ~isempty(index)
                obj.SelectedIndex = index;
            else
                obj.SelectedIndex = 0;
            end
        end
        
        function obj = OnResize(obj, source, event) %#ok<INUSD>
            % set default height
            [width,height] = position2size(getpixelposition(obj.Panel));
            padding = 10;
            comboheight = 25;
            setpixelposition(obj.ComboBox, [padding, height - comboheight - 2*padding, width - 2*padding, comboheight]);
            targetwidth = width - 2*padding;
            if targetwidth < 10
                targetwidth = 10;
            end
            targetheight = height - comboheight - 3*padding;
            if targetheight < 10
                targetheight = 10;
            end
            setpixelposition(obj.PropertySheet, [padding, padding, targetwidth, targetheight]);
        end
    end
end
