% Java Swing implementation for a property browser for custom objects.
%
% See also: PropertySheet

% Copyright 2009 Levente Hunyadi
classdef SwingPropertySheet < PropertySheet
    properties (Access = protected)
        % Java object reference for property sheet.
        JSheet;
    end
    methods
        function obj = SwingPropertySheet(varargin)
            obj = obj@PropertySheet(varargin{:});
        end
        
        function obj = Instantiate(obj, parent)
            sheet = com.l2fprod.common.propertysheet.PropertySheetPanel();
            sheet.setMode(com.l2fprod.common.propertysheet.PropertySheet.VIEW_AS_FLAT_LIST);  % alternative: VIEW_AS_CATEGORIES
            sheet.setDescriptionVisible(false);
            sheet.setSortingCategories(true);
            sheet.setSortingProperties(true);
            sheet.setRestoreToggleStates(false);

            jhandle = handle(sheet, 'CallbackProperties');
            set(jhandle, 'VetoableChangeCallback', @obj.OnPropertyChanged);

            if nargin > 1
                panel = uipanel(parent);
            else
                panel = uipanel;
            end
            jcontrol(panel, sheet, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);

            obj.JSheet = sheet;
            obj.Container = panel;
        end
    end
    methods (Access = protected)
        % Occurs when a new item is set whose properties are to be shown.
        function OnItemSet(obj, item)
            n = numel(obj.ItemProperties);
            if n == 0
                obj.JSheet.clearProperties();
                return;
            end

            jprops = javaArray('com.l2fprod.common.propertysheet.DefaultProperty', n);
            for k = 1 : n;
                jprops(k) = SwingPropertySheet.GetProperty(item, obj.ItemProperties(k));
            end
            obj.JSheet.setProperties(jprops);  % set new properties on user interface at once to avoid repeated UI updates
        end

        % Occurs when the user is finished editing the value of a property.
        function OnPropertyChanged(obj, source, event) %#ok<INUSL>
            %oldvalue = get(event, 'OldValue');
            newvalue = get(event, 'NewValue');
            propname = get(event, 'PropertyName');
            propnameparts = regexp(propname, ':', 'split');
            
            ix = obj.ItemProperties.FindByName(propnameparts);
            if ~isempty(ix)
                props = obj.ItemProperties;
                jprops = obj.JSheet.getProperties();
                try
                    obj.UpdateItemPropertyValue(propnameparts, newvalue);                      % update property value
                    SwingPropertySheet.RefreshDependentProperties(obj.Item, props, jprops);  % requery values of dependent and possibly updated properties
                catch me  % update failed
                    if isjava(newvalue)
                        valuetext = char(newvalue);
                    else
                        valuetext = num2str(newvalue);
                    end
                    msgbox(sprintf('The value "%s" is invalid for the property "%s".\nSee the console for more details.', valuetext, propname), 'Invalid property value', 'error');
                    prettyexception(me);
                    SwingPropertySheet.RefreshProperties(obj.Item, props, jprops);
                end
            end
        end
    end
    methods (Static, Access = protected)
        % Get Java representation of MatLab property.
        % This representation is passed to L2FProd.com Common Components'
        % PropertySheet implementation.
        function jprop = GetProperty(item, prop, prefix)
            if nargin < 3
                prefix = '';
            end
            
            propname = prop.Name;
            prefixedname = [prefix propname];
            qname = [class(item) '.' propname];  % fully qualified property name
            %description = helptext(qname);
            description = '';
            value = item.(propname);

            if ~isempty(description) && (ischar(description) || iscellstr(description))
                if iscellstr(description)
                    description = strjoin(sprintf('\n'), description);
                end
            end
            if prop.HasJavaType()
                propjavatype = prop.GetJavaType();
            else  % MatLab objects cannot be passed to Java
                propjavatype = [];
            end
            
            %jprop = com.l2fprod.common.propertysheet.DefaultProperty();
            %jprop.setName(prefixedname);
            %jprop.setType(propjavatype);
            %jprop.setDisplayName(propname);
            %jprop.setShortDescription(description);
            %jprop.setCategory('Category');

            jprop = com.l2fprod.common.propertysheet.DefaultProperty(prefixedname, propjavatype, propname, description);
            if ~isempty(propjavatype)
                jprop.setValue(javamatrix(value));
            else
                jprop.setEditable(false);
            end
            
            if ~isempty(prop.SubProperties)  % explore subproperties
                for k = 1 : numel(prop.SubProperties)
                    subprop = prop.SubProperties(k);
                    jsubprop = SwingPropertySheet.GetProperty(value, subprop, [prefix propname ':']);
                    jprop.addSubProperty(jsubprop);
                end
            end
        end

        % Update all properties of an object.
        function RefreshProperties(item, props, jprops)
            assert(numel(jprops) == numel(props));
            for k = 1 : numel(props)
                prop = props(k);
                jprop = jprops(k);
                
                if prop.HasJavaType()
                    value = item.(prop.Name);
                    jprop.setValue(javamatrix(value));
                end
                if ~isempty(prop.SubProperties)  % property has nested properties
                    value = item.(prop.Name);
                    SwingPropertySheet.RefreshDependentProperties(value, prop.SubProperties, jprop.getSubProperties());
                end
            end
        end
        
        % Update dependent properties of an object.
        function RefreshDependentProperties(item, props, jprops)
            assert(numel(jprops) == numel(props));
            for k = 1 : numel(props)
                prop = props(k);
                jprop = jprops(k);
                
                if prop.Dependent && prop.HasJavaType()
                    value = item.(prop.Name);
                    jprop.setValue(javamatrix(value));
                end
                if ~isempty(prop.SubProperties)  % property has nested properties
                    value = item.(prop.Name);
                    SwingPropertySheet.RefreshDependentProperties(value, prop.SubProperties, jprop.getSubProperties());
                end
            end
        end
    end
end
