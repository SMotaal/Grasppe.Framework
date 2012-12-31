classdef Property < Grasppe.Core.Prototype
  %MEDIATEDPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Component
    MetaProperty
    Value
    DefaultValue
    PreviousValue
    Revertable    = false;
    RedundantSet  = false;
  end
  
  properties (Dependent)
    Name            % Interal property name, not necessarily displayed, used as a key to identify the property.
    DisplayName     % A short property name shown in the left column of the property grid.
    Description     % A concise description of the property, shown at the bottom of the property pane, below the grid.
%     Class           % The Java type associated with the property, used to invoke the appropriate renderer or editor.
    Mode
%     EditorContext   % An editor context object. If set, both the type and the context are used to look up the renderer or editor to use. This lets, for instance, one flag value to display as a true/false label, while another as a checkbox.
    Category        % A string specifying the property?s category, for grouping purposes.
    Editable        % Specifies whether the property value is modifiable or read-only.
  end
  
  methods
    function obj = Property(component, propertyMeta, value) % Component, Name, DisplayName, Description, Type, EditorContext, Category, Editable, Value)
      obj = obj@Grasppe.Core.Prototype();
      
      obj.Component     = component;
      obj.MetaProperty  = propertyMeta;
      
      try obj.Value     = value; end
      
    end
    
    function set.Value(obj, value)
      [value changed] = obj.newValue(value, obj.Value);
      if (changed), obj.Value = value; end
    end
    
    function [value changed] = newValue(obj, value, currentValue)
      changed = false;
      
      if obj.RedundantSet || ~isequal(currentValue, value)
        if obj.Revertable
          obj.PreviousValue = currentValue;
        else
          obj.PreviousValue = [];
        end;
        changed = true;
      end
    end
  end
    
  methods % Meta Getters
    function value = get.Name(obj)
      value = obj.MetaProperty.Name;
    end
    
    function value = get.DisplayName(obj)
      value = obj.MetaProperty.DisplayName;
    end
    
    function value = get.Description(obj)
      value = obj.MetaProperty.Description;
    end
    
    function value = get.Mode(obj)
      value = obj.MetaProperty.Mode;
    end
    
    function value = get.Category(obj)
      value = obj.MetaProperty.Category;
    end
    
    function value = get.Editable(obj)
      value = obj.MetaProperty.Editable;
    end
  end
  
  methods (Static)
%     function obj = DefineByStruct(metaStruct, Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation)
%       if ~isempty(metaStruct) && isstruct(metaStruct)
%         [Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation] = deal([]);
%         structVars(metaStruct);
%       end
%       obj = Grasppe.Core.Property(Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation);
%     end
  end
  
  
end

