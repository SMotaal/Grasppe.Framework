classdef MediatedProperty < Grasppe.Core.Prototype & Grasppe.Core.Property
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
      obj = obj@Grasppe.Core.Prototype();
      obj = obj@Grasppe.Core.Property(mediator, [], []);
      
      %       obj.Mediator    = mediator;
      
      obj.Subject     = subject;
      obj.SubjectMeta = propertyMeta;
      
      propertyName    = propertyMeta.Name;
      propertyValue   = subject.(propertyName);
      
      if isa(alias, 'Grasppe.Core.MetaProperty')
        obj.MetaProperty  = alias;
        
        obj.Value         = propertyValue;
        
      elseif isa(alias,'char')
        name              = propertyMeta.Name;
        displayName       = propertyMeta.DisplayName;
        category          = propertyMeta.Category;
        mode              = propertyMeta.Mode;
        description       = propertyMeta.Description;
        
        obj.MetaProperty  = Grasppe.Core.MetaProperty.Declare( ...
          alias, class(obj), displayName, category, mode, description);
        
        obj.Value         = propertyValue;
      else
        error('Grasppe:MediatedProperty:MissingMeta', 'Unable to construct a Grasppe.Core.MediatedProperty without a valid MediatorMeta.');
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
      subject.(propertyName)  = obj.Value;

    end
    
    function [value changed] = newValue(obj, value, currentValue)
      [value changed] = obj.newValue@Grasppe.Core.Property(value, currentValue);
      
      if isempty(obj.Subject), return; end
      
      subjects = [{obj.Subject}, obj.Subjects];
      
      if changed
        for m = 1:numel(subjects)
          subject         = subjects{m};
          propertyName    = obj.SubjectMeta.Name;
          subject.(propertyName) = value;
        end
      end
    end
    
  end
  
end

