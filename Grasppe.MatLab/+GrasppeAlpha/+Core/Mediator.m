classdef Mediator < GrasppeAlpha.Core.Component % & GrasppeAlpha.Core.Component
  %GRASPPEMEDIATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    MediationProperties
    MediationReferences
    Colleagues
    SettingProperty = '';
    GettingProperty = '';
  end
  
  methods
    function obj = Mediator()
      obj = obj@GrasppeAlpha.Core.Component;
    end
    
    function attachMediatorProperty(obj, subject, property, alias)
      %% Determine mediator-alias for target property
      
      validSubject    = false;
      
      mediatorMeta    = [];
      nativeMeta      = [];
      
      subjectID       = subject.ID;
      mediatorID      = obj.ID;
      
      try
        % Get component metaproperty / value
        subjectMeta   = subject.MetaProperties.(property); % obj.getMetaProperties;
        subjectValue  = subject.(property);
        validSubject  = isa(subject.MetaProperties.(property), 'GrasppeAlpha.Core.MetaProperty');
        
        % Look for mediator metaproperty
        if ~exists('alias'), alias = property; end %[subjectID '_' subjectMeta.Name]; end
        nativeMeta    = obj.findprop(alias); %metaProperty(obj.ClassName, alias);
        
        % Add mediator property if not found or amend components if found
        if isempty(nativeMeta)
          obj.addprop(alias);
          
          nativeMeta        = obj.findprop(alias);
          nativeMeta.GetObservable = true; ...
            nativeMeta.SetObservable = true;
          
          mediationMeta     = GrasppeAlpha.Core.MetaProperty.CreateDuplicate(subjectMeta, 'Grouping', mediatorID, 'Name', alias); ...
            obj.registerHandle(mediationMeta);
          
          mediatorProperty  = GrasppeAlpha.Core.MediatedProperty(obj, subject, subjectMeta, mediationMeta); ...
            obj.registerHandle(mediatorProperty);
          
          % Attach Mediator Listeners
          
          addlistener(obj,  alias,   'PreGet',   @obj.mediatorPreGet);  ...  % Pull
            addlistener(obj,  alias,   'PreSet',   @obj.mediatorPreSet);  ...
            addlistener(obj,  alias,   'PostGet',  @obj.mediatorPostGet); ...
            addlistener(obj,  alias,   'PostSet',  @obj.mediatorPostSet);   % Push
          
          nativeMeta.AbortSet = true;
          
          nativeMeta.SetMethod = @mediationSet;
          
          obj.MediationProperties.(alias)     = mediatorProperty;
          obj.MediationReferences.(property)  = mediatorProperty;
          
        else
          obj.MediationProperties.(alias).addSubject(subject);
          %warning('Grasppe:Mediator:PredefinedPropertyAlias', 'Adding subject %s for predefined alias %s for property %s.', subject.ID, alias, property);
          %error('Grasppe:Mediator:PredefinedPropertyAlias', 'Could not define the alias %s for the property %s since it is already defined.', alias, property);
        end
        
        % Attach Subject Listeners
        addlistener(subject,  property,   'PreGet',   @obj.subjectPreGet);  ...  % Pull
          addlistener(subject,  property,   'PreSet',   @obj.subjectPreSet);  ...
          addlistener(subject,  property,   'PostGet',  @obj.subjectPostGet); ...
          addlistener(subject,  property,   'PostSet',  @obj.subjectPostSet);   % Push
      catch err
        disp(err.message);
        keyboard;
      end
      
    end
    
    function propertyMeta = getSubjectMetaProperties(obj, component, property)
      propertyMeta = component.MetaProperties.(property);
    end
    
    function mediatorPreGet(obj, source, event)
      mediationID       = source.Name;
      
      mediationProperty = obj.MediationProperties.(mediationID);
      
      subjectName       = mediationProperty.SubjectMeta.Name;
      subjectValue      = mediationProperty.Subject.(subjectName);
      
      mediationProperty.Value = mediationProperty.Subject.(subjectName);
      
      obj.(mediationID) = mediationProperty.Value;
      return;
    end
    
    function mediatorPreSet(obj, source, event)
      if isempty(obj.SettingProperty)
        obj.SettingProperty = source.Name;
      else
        alreadySetting = {obj.SettingProperty, source.Name};
      end
      return;
    end
    
    function mediationSet(obj, value)
      mediationID       = obj.SettingProperty;
      mediationProperty = obj.MediationProperties.(mediationID);
      try
        if ~isequal(mediationProperty.Value, value)
          mediationProperty.Value = value;
        end
        if ~isequal(obj.(mediationID), value)
          obj.(mediationID) = value;
        end
      end
    end
    
    function mediatorPostSet(obj, source, event)
      obj.SettingProperty = '';
      return;
    end
    
    function mediatorPostGet(obj, source, event)
      return;
    end
    
    function subjectPreGet(obj, source, event)
      return;
    end
    
    function subjectPreSet(obj, source, event)
      return;
    end
    
    function subjectPostGet(obj, source, event)
      return;
    end
    
    function subjectPostSet(obj, source, event)
      if isempty(obj.SettingProperty)
        mediationProperty = obj.MediationReferences.(source.Name);
        obj.(mediationProperty.Name) = event.AffectedObject.(source.Name);
      end
      return;
    end
    
  end
  
  
  methods (Access=protected, Hidden=false)
    function createComponent(obj, type, varargin)
      %       obj.attachMediatorProperty
      return;
    end
  end
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
end

