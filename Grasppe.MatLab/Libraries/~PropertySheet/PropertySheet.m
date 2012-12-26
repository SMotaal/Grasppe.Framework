% A property browser for custom objects.
% The control displays all public properties of a MatLab object instance
% and lets the user inspect and modify each property value individually.

% Copyright 2008-2009 Levente Hunyadi
classdef PropertySheet < UIControl
    properties
        % The object whose properties are listed in the editor.
        Item;
    end
    properties (Dependent)
        Control;
    end
    properties (Access = protected)
        % A MatLab uitable object or a Java PropertySheetPanel object.
        Container;
        % Public properties and type information for the current Item.
        ItemProperties = PropertySheetField.empty(0,1);
    end
    properties (Access = private)
        % Disables triggering the OnSetItem callback on iternal updates.
        % When set to true, the callback is not invoked when the value of
        % the Item property is changed.
        DisableOnItemSetEvent = false;
    end
    events
        PropertyValueChanged;
    end
    methods (Abstract)
        % Abstract method inherited from UIControl.
        % MatLab requires the presence of this method placeholder in
        % intermediary classes.
        obj = Instantiate(obj, parent);
    end
    methods
        function obj = PropertySheet(varargin)
            obj = obj@UIControl(varargin{:});
        end

        function set.Item(obj, item)
            obj.Item = item;
            if ~obj.DisableOnItemSetEvent
                obj.ItemProperties = PropertySheet.GetItemPropertyFields(obj.Item);
                obj.OnItemSet(item);
            end
        end

        function control = get.Control(obj)
            control = obj.Container;
        end

        % Index of the currently selected property.
        function index = SelectedIndex(obj) %#ok<INUSD>
            index = [];
        end
        
        % Constraints on the currently selected property.
        function prop = SelectedProperty(obj)
            row = obj.SelectedIndex;
            if ~isempty(row)
                prop = obj.ItemProperties(row);
            else
                prop = PropertySheetField.empty(0,1);
            end
        end
    end
    methods (Access = protected)
        function value = GetPropertyValue(obj, index)
            value = obj.Item.(obj.ItemProperties(index).Name);
        end
        
        % Updates the value of a single property of Item.
        % The set event is not triggered by this method.
        %
        % Input arguments:
        % nameparts:
        %    a property name or a cell array of hierarchically nested
        %    property name strings of the property that is to be updated
        %
        % See also: PropertySheet/DisableOnItemSetEvent
        function UpdateItemPropertyValue(obj, nameparts, value)
            obj.DisableOnItemSetEvent = true;  % do not trigger update events when data in item is changed
            if isjava(value)
                value = matlabArray(value);
            end
            item = obj.Item;
            try
                if iscellstr(nameparts)
                    obj.Item = PropertySheet.UpdatePropertyValue(obj.Item, nameparts, value);
                else  % nameparts is a single string (row vector of type char)
                    obj.Item.(nameparts) = value;
                end
            catch me
                obj.Item = item;  % reset previous value
                rethrow(me);
            end
            obj.DisableOnItemSetEvent = false;
        end
    end
    methods (Abstract, Access = protected)
        % Occurs when a new object is assigned for display.
        OnItemSet(obj, item);
    end
    methods (Static, Access = private)
        % Recursively update the value of a nested property.
        % This function is necessary because properties might hold value
        % objects. For value objects, the expression
        %    variable = object.property_name;
        % creates a temporary variable independent of the object, and
        % unlike for handle objects, updates to this variable are not
        % reflected in the original object. This approach propagates any
        % deep changes to the shallowmost level, thereby being suitable for
        % both handle and value objects.
        function item = UpdatePropertyValue(item, nameparts, value)
            name = nameparts{1};
            if numel(nameparts) > 1  % a nested property
                item.(name) = PropertySheet.UpdatePropertyValue(item.(name), nameparts(2:end), value);  % update deep and propagate change upwards
            else  % a directly assignable property
                item.(name) = value;
            end
        end
        
        % Set ItemProperties vector by querying public properties of Item.
        function itemprops = GetItemPropertyFields(item)
            props = public_properties(item);  % automatically discover public properties of item
            n = numel(props);

            itemprops = PropertySheetField(n, 1);  % extract property name and type information
            for k = 1 : n
                prop = props{k};           % fetch property data
                value = item.(prop.Name);  % fetch property value
                field = PropertySheetField(prop);
                field = field.SetByValue(value);
                itemprops(k) = field;
                if isobject(value)  % recurse for subproperties of MatLab object
                    itemprops(k).SubProperties = PropertySheet.GetItemPropertyFields(value);
                end
            end
        end
    end
end