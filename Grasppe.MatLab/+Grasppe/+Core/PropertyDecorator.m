classdef PropertyDecorator < Grasppe.Core.Prototype % & Grasppe.Core.HandleComponent
  %HANDLEDECORATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    Component;
    ComponentDecorations;
    DecorationProperties;
  end
  
  methods
    
    function obj = PropertyDecorator(component)
      obj = obj@Grasppe.Core.Prototype;
      try
        obj.Component = component;
        component.decorate(obj);
      end
    end
    
    function decorations = get.ComponentDecorations(obj)
      decorations = obj.ComponentDecorations;
      if isempty(decorations) || ~iscell(decorations)
        decorations = {};
        try
          decorations = obj.DecoratingProperties;
        end
      end
    end
    
    function set.Component(obj, value)
      obj.Component = value;
      obj.Component.decorate(obj);
    end
    
    function properties = get.DecorationProperties(obj)
      if ~isstruct(obj.DecorationProperties)
        obj.DecorationProperties = struct();
      end
      properties = obj.DecorationProperties;
    end
    
    function set.DecorationProperties(obj, properties)
      if isstruct(properties)
        obj.DecorationProperties = properties;
      end
    end
    
    function setDecoratorProperty(obj, source, event)
      
      propertyName  = source.Name;
      
      handleValue   = obj.Component.handleGet(propertyName);
      
      %       try currentValue  = obj.(propertyName);
      %       catch err, currentValue  = []; end
      
      try componentValue  = obj.Component.(propertyName);
      catch err, currentValue  = []; end
      
      %       if ~isequal(currentValue, handleValue) || ~isequal(handleValue, componentValue)
      %         dispf('\t%s.%s(%s) = %s', obj.ID, propertyName, class(currentValue), toString(currentValue));
      obj.Component.handleSet(propertyName, componentValue); %obj.Component.(propertyName));
      %       end
      %       disp('done!');
      obj.DecorationProperties.(propertyName) = obj.Component.handleGet(propertyName);
      %       obj.(propertyName) = obj.Component.handleGet(propertyName);
      
    end
    
    function getDecoratorProperty(obj, source, event)
      
      propertyName  = source.Name;
      
      handleValue   = obj.Component.handleGet(propertyName);
      
      try currentValue  = obj.DecorationProperties.(propertyName);
      catch err, currentValue  = []; end
      
      if ~isequal(currentValue, handleValue)
        obj.DecorationProperties.(propertyName) = currentValue;
        obj.Component.(propertyName) = handleValue;
      end
      
    end
  end
  
  methods(Static, Hidden)
    function preSetDecoratorProperty(source, event)
      obj = event.AffectedObject;
      
      currentValue = obj.(source.Name);
      
      if Grasppe.Core.PropertyDecorator.checkInheritence(obj) && isvalid(obj)
        for i = 1:numel(obj.Decorators)
          try
            %             obj.(source.Name) = currentValue;
            obj.Decorators{i}.(source.Name) = currentValue;
          end
        end
      end
      
    end
    
    function postSetDecoratorProperty(source, event)
      obj = event.AffectedObject;
      
      currentValue = obj.(source.Name);
      
      if Grasppe.Core.PropertyDecorator.checkInheritence(obj) && isvalid(obj)
        for i = 1:numel(obj.Decorators)
          try
            obj.Decorators{i}.setDecoratorProperty(source, event);
          end
        end
      end
      
      
    end
    
    function GetDecoratorProperty(source, event)
      obj = event.AffectedObject;
      if Grasppe.Core.PropertyDecorator.checkInheritence(obj) && isvalid(obj)
        for i = 1:numel(obj.Decorators)
          try
            decorator = obj.Decorators{i};
            if stropt(source.Name, decorator.ComponentDecorations)
              decorator.getDecoratorProperty(source, event);
              return;
            end
          end
        end
      end
    end
    
  end
  
end

