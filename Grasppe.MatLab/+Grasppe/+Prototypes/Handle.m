classdef Handle < Grasppe.Prototypes.Prototype & dynamicprops
  %HANDLECLASS Prototype 2 SuperClass for Handle, Property & Event Listener functionality
  %   HandleClass...
  
  properties(SetAccess=private, GetAccess=public, Transient, Hidden) %, GetAccess=protected)
    EventListeners          = struct();
    PropertyEventListeners  = struct();
    SelfListeners           = struct();
  end
  
  methods
    function obj= Handle(varargin)
      obj@Grasppe.Prototypes.Prototype(varargin{:});      
    end
    
    function delete(obj)
      obj.deleteRecursively(obj.EventListeners);
      obj.deleteRecursively(obj.PropertyEventListeners);      
      obj.deleteRecursively(obj.SelfListeners);
    end
    
    function deleteRecursively(obj, items)
      if isobject(items)
        try delete(items); end
      elseif iscell(items)
        for m = numel(items):-1:1   % LIFO
          try obj.deleteRecursively(items{m}); end
        end
      elseif isstruct(items)
        try obj.deleteRecursively(struct2cell(items)); end
      end
    end
    
    
    function addEventListener(obj, eventName, listener)
      
      if ~isfield(obj.EventListeners, eventName)
        obj.EventListeners.(eventName) = {};
      end
      
      listeners           = obj.EventListeners.(eventName);
      
      try
        if any(cellfun(@(x)isequal(x, listener), listeners(:,1))), return; end %lidx = cellfun(@(x)isequal(x, listener), listeners(:,1)); if any(lidx), return; end
      end
      
      lh                  = obj.addlistener(eventName, @listener.handleEvent); ...
        % Callback: obj ==> src, listener ==> obj, EventData ==> evt
      
      listeners(end+1,:)  = {listener, lh};
      
      obj.EventListeners.(eventName)  = listeners;
      
    end
    
    function addPropertyListener(obj, listener, propertyName, eventName)
      
      if ~exist('eventName', 'var'), eventName = 'PostSet'; end
      
      propertyID          = lower([propertyName eventName]);
      
      if ~isfield(obj.PropertyEventListeners, propertyID)
        obj.PropertyEventListeners.(propertyID) = {};
      end
      
      listeners           = obj.PropertyEventListeners.(propertyID);
      
      try
        if any(cellfun(@(x)isequal(x, listener), listeners(:,1))), return; end %lidx = cellfun(@(x)isequal(x, listener), listeners(:,1)); if any(lidx), return; end
      end
      
      lh                  = obj.addlistener(propertyName, eventName, @listener.handlePropertyEvent); ...
        % Callback: obj ==> src, listener ==> obj, EventData ==> evt
      
      listeners(end+1,:)  = {listener, lh};
      
      obj.PropertyEventListeners.(propertyID)   = listeners;
      
    end
    
    function handlePropertyEvent(obj, src, evt)
      % source object is evt.AffectedObject (src is metaProperty)
      
      dbTag               = 'PropertyEvent';
      try dbTag           = [obj.InstanceID ':Handle' evt.EventName]; end
      try dbTag           = [dbTag ':' evt.AffectedObject.InstanceID]; end
      try dbTag           = [dbTag ':' src.Name]; end
      
      debugStamp( dbTag, 5, obj );
      
      return;
    end
    
    function handleEvent(obj, src, evt)
      dbTag               = 'Event';
      try dbTag           = [obj.InstanceID ':Handle' evt.EventName]; end
      % try dbTag           = ['Grasppe' ':' evt.EventName]; end
      try dbTag           = [dbTag ':' evt.AffectedObject.InstanceID]; end
      try dbTag           = [dbTag ':' src.InstanceID]; end
      
      debugStamp( dbTag, 5, obj );
      
      return;
    end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.Prototype;
      
      obj.attachPropertyListeners();
      obj.attachEventListeners();
    end
  end
  
  methods (Access=private)
    
    function attachEventListeners(obj)
      eventNames          = {obj.MetaClass.EventList(:).Name};  %events(obj);
      methodNames         = {obj.MetaClass.MethodList(:).Name}; %methods(obj);
      
      for m = 1:numel(eventNames)
        eventName         = eventNames{m};
        
        %% Attach onEvent methods
        
        methodName        = ['on' eventName];
        
        if any(strcmp(methodName, methodNames));
          try
            
            try delete(obj.SelfListeners.([eventName 'Event'])); end
            
            lh            = obj.addlistener( eventName, @(s,e)feval(methodName, obj, s, e));
            
            obj.SelfListeners.([eventName 'Event']) = lh;
            continue;
          catch err
            disp(err);
          end
        end
        
      end
      
    end
    
    function attachPropertyListeners(obj)
      metaProperties      = obj.MetaClass.PropertyList;
      eventNames          = {obj.MetaClass.EventList(:).Name}; %events(obj);
      
      for m = 1:numel(metaProperties)
        propertyMeta      = metaProperties(m);
        propertyName      = propertyMeta.Name;
        
        %% Attach generic handlePropertyEvent callbacks
        
        if propertyMeta.SetObservable, obj.addPropertyListener(obj, propertyName, 'PostSet'); end
        if propertyMeta.GetObservable, obj.addPropertyListener(obj, propertyName, 'PreGet'); end
        
        %% Attach PropertChange events
        
        eventName         = [propertyName 'Change'];
        
        if propertyMeta.SetObservable && any(strcmp(eventName, eventNames));
          try
            
            try delete(obj.SelfListeners.([propertyName 'PostSet'])); end
            
            lh            = obj.addlistener( propertyName, 'PostSet', @(s,e)obj.notify(eventName, e)); %eval(['@obj.' propertyName 'Change']) );
            
            obj.SelfListeners.([propertyName 'PostSet']) = lh;
            continue;
          catch err
            disp(err);
          end
        end
        
      end
    end
  end
  
  
end

