classdef MediatedProperty < GrasppeAlpha.Core.Prototype & GrasppeAlpha.Core.Property
  %MEDIATEDPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    %     Mediator
    
    Subject
    SubjectMeta
    
    Subjects    = {};
  end
  
  properties (Dependent)
  end
  
  methods
    function obj = MediatedProperty(mediator, subject, propertyMeta, alias)
      obj = obj@GrasppeAlpha.Core.Prototype();
      obj = obj@GrasppeAlpha.Core.Property(mediator, [], []);
      
      %       obj.Mediator    = mediator;
      
      obj.Subject     = subject;
      obj.SubjectMeta = propertyMeta;
      
      propertyName    = propertyMeta.Name;
      propertyValue   = subject.(propertyName);
      
      if isa(alias, 'GrasppeAlpha.Core.MetaProperty')
        obj.MetaProperty  = alias;
        
        if ~isequal(obj.Value, propertyValue)
          obj.Value         = propertyValue;
        end
        
      elseif isa(alias,'char')
        name              = propertyMeta.Name;
        displayName       = propertyMeta.DisplayName;
        category          = propertyMeta.Category;
        mode              = propertyMeta.Mode;
        description       = propertyMeta.Description;
        
        obj.MetaProperty  = GrasppeAlpha.Core.MetaProperty.Declare( ...
          alias, obj, class(obj), displayName, category, mode, description);
        
        if ~isequal(obj.Value, propertyValue)
          obj.Value         = propertyValue;
        end
      else
        error('Grasppe:MediatedProperty:MissingMeta', 'Unable to construct a GrasppeAlpha.Core.MediatedProperty without a valid MediatorMeta.');
      end
    end
    
    %     function components = get.Subjects(obj)
    %       % subject = {obj.Subject};
    %       % class(obj.Subjects)
    %       % components = {subject{:}, obj.Subjects{:}};
    %       %if isempty(obj.Components), components = obj.Component; end
    %     end
    
    function addSubject(obj, subject)
      subjects = obj.Subjects;
      
      if ~iscell(subjects), subjects = {}; end
      
      for m = 1:numel(subjects)
        s = subjects{m};
        if isequal(s, subjects), return; end
      end
      
      subjects{end+1} = subject;
      
      if numel(subjects)>0
        obj.Subjects = subjects; %{2:end};
      else
        obj.Subjects = {};
      end
      
      propertyName            = obj.SubjectMeta.Name;
      
      if ~isequal(subject.(propertyName), obj.Value)
        subject.(propertyName)  = obj.Value;
      end
      
    end
    
    function [value changed] = newValue(obj, value, currentValue)
      [value changed] = obj.newValue@GrasppeAlpha.Core.Property(value, currentValue);
      
      if isempty(obj.Subject), return; end
      
      subjects = [{obj.Subject}, obj.Subjects];
      
      if true %changed
        for m = 1:numel(subjects)
          subject         = subjects{m};
          propertyName    = obj.SubjectMeta.Name;
          
          if ~isequal(subject.(propertyName), value)
            subject.(propertyName) = value;
          end
          
        end
        
      end
      
    end
    
  end
  
end

