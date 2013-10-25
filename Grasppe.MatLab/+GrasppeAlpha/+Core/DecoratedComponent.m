classdef DecoratedComponent < GrasppeAlpha.Core.Prototype % & GrasppeAlpha.Core.HandleComponent
  %DECORATEDOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    Decorators = {};
    DecoratorNames = {};
    PropertyDecorations
  end
  
  methods
    function obj = DecoratedComponent()
      obj = obj@GrasppeAlpha.Core.Prototype;
      % obj = obj@GrasppeAlpha.Core.HandleComponent;
      obj.decorateComponent;
    end
  end
  
  methods (Access=protected, Hidden)
    function decorateComponent(obj)
    end
  end
  
  methods
    function decorate(obj, decorator)
      
      if ~(GrasppeAlpha.Core.DecoratedComponent.checkInheritence(decorator) && isvalid(decorator))
        return;
      end
      
      decorators          = obj.Decorators;
      decoratorProperties = decorator.MetaClass.PropertyList;
      
      decorations         = decorator.ComponentDecorations;
      nDecorations        = length(decorations);
      
      try
        if stropt(decorator.ClassName, obj.DecoratorNames)
          return;
        end
      end
      
      for i = 1:nDecorations
        obj.attachDecoratorProperty(decorator, decorations{i});
        decorator.(decorations{i}) = obj.(decorations{i});
      end
      
      obj.Decorators      = {obj.Decorators{:}, decorator};
      obj.DecoratorNames  = {obj.DecoratorNames{:}, decorator.ClassName};
      
    end
    
    function attachDecoratorProperty(obj, decorator, decoration)
      %% Attach a property by meta class
      % componentProperties = obj.MetaClass.PropertyList;
      
      % if ~isprop(obj, decoration) %isempty(findprop(obj, decoration)) %~stropt(decoration, {componentProperties.Name})
      %   obj.addprop(decoration);
      % end
      
      propertyMeta = obj.findprop(decoration);
      
      if isempty(propertyMeta)
        propertyMeta = obj.addprop(decoration);
      end
      
      propertyMeta.GetObservable = true;
      propertyMeta.SetObservable = true;
      
      %       mb1.SetMethod = {@setView, ;
      
      addlistener(obj, decoration, 'PreGet', @GrasppeAlpha.Core.PropertyDecorator.GetDecoratorProperty);
      addlistener(obj, decoration, 'PreSet', @GrasppeAlpha.Core.PropertyDecorator.preSetDecoratorProperty);
      addlistener(obj, decoration, 'PostSet', @GrasppeAlpha.Core.PropertyDecorator.postSetDecoratorProperty);
      
      try
        defaultValue      = obj.Defaults.(decoration);
        %         obj.(decoration)  = defaultValue;
        if ishandle(obj.HandleComponent)
          set(obj.HandleComponent, decoration, defaultValue);
          dispf('\t%s.%s(%s) = %s', obj.ID, decoration, class(defaultValue), toString(defaultValue));          
        end
        %         obj.handleSet(decoration, obj.(decoration));
      end
            
    end
  end
  
end

