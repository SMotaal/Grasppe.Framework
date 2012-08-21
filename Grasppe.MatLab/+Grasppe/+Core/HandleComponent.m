classdef HandleComponent < Grasppe.Core.Component
  %GRASPPEHANDLECOMPONENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    HandleComponentHandleProperties = {{'ID', 'Tag'}, {'Type','Type','readonly'}};
  end
  
  properties (SetObservable, GetObservable, AbortSet, Hidden=true)
    Type
  end
  
  
  properties (Hidden=true)
    HandleFunctions         % Struct holding handle functions
    ObjectPropertyMap       % Object-Handle Map
    HandlePropertyMap       % Handle-Object Map
    HandlePropertyMeta      % Struct holding meta.property for each handle-object property
    
    Handle = [];
    
    PropertyQueue   = {};
    PropertyQueing  = false;
    
    HandleObject
    JavaObject
  end
  
  methods
    function obj = HandleComponent(varargin)
      obj = obj@Grasppe.Core.Component(varargin{:});
    end
    
    function delete(obj)
      debugStamp(5, obj);
      try obj.handleSet('UserData', []); end
    end

    
    function set.PropertyQueing(obj, queing)
      if islogical(queing)
        isqueing = obj.PropertyQueing;
        obj.PropertyQueing = queing;
        if isqueing && ~queing
          % do update
          properties = unique(obj.PropertyQueue);
          for m = 1:numel(properties)
            propertyName  = properties{m};
            propertyAlias = obj.HandlePropertyMap(propertyName);
        
            obj.(propertyAlias) = obj.handleGet(propertyName);
          end
        end
      end
    end
    
    
    function handleSet(obj, name, value)
      try
        switch class(value)
          case 'logical'
            if isOn(value), value = 'on'; else value = 'off'; end
        end
        set(obj.Handle, name, value);
      catch err
        if isvalid(obj), rethrow(err); end
      end
      
    end
    
    function value = handleGet(obj, name)
      try
        value = get(obj.Handle, name);
      catch err
        if isvalid(obj), rethrow(err); end
      end
      
    end
    
    function autoSet(obj, property, value)
      if isnumeric(value)
        obj.handleSet(property, value);
      elseif isequal(lower(value), 'auto')
        obj.handleSet([property 'Mode'], 'auto');
      end
    end
    
    function value = autoGet(obj, property)
      value = obj.handleGet([property 'Mode']);
      if ~isequal(lower(value), 'auto')
        value = obj.handleGet(property);
      end
    end
    
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.createComponent@Grasppe.Core.Component();
      obj.createHandlePropertyMap();
      obj.createHandleObject();
      
      showComponent = isempty(obj.IsVisible) || isOn(obj.IsVisible);
      obj.IsVisible = false;
      if ishandle(obj.Handle)
        try obj.handleSet('UserData', obj); end
        obj.HandleObject = handle(obj.Handle);
        obj.registerHandle(obj.Handle);
        obj.attachHandleProperties();
      end
      
      try refresh(obj.Handle); end
      
      if showComponent
        obj.IsVisible = true;
      end
    end
        
    function createHandleObject(obj)
      error('Grasppe:HandleComponent:CreateMethodUndefined', ...
        'Unable to create the handle component due to undefined create method.');
    end
    
    function attachHandleProperties(obj)
      
      aliases = obj.ObjectPropertyMap.keys;
      names   = obj.ObjectPropertyMap.values;
      
      
      setObservableWarnState = warning('off', 'MATLAB:class:nonSetObservableProp');
      for m = 1:numel(aliases)
        obj.attachHandleProperty(aliases{m}, names{m});
      end
      warning(setObservableWarnState);
      
    end
    
    %     function handleSet(obj, name, value)
    %       switch class(value)
    %         case 'logical'
    %           if isOn(value), value = 'on'; else value = 'off'; end
    %       end
    %
    %       set(obj.Handle, name, value);
    %
    %     end
    %
    %     function value = handleGet(obj, name)
    %
    %       value = get(obj.Handle, name);
    %
    %     end
    
    
    function attachHandleProperty(obj, propertyAlias, propertyName)
      
      h = obj.Handle;
      hObj = obj.HandleObject;
      
      objectValue = obj.(propertyAlias);
      handleValue = get(h, propertyName);
      
      % Determine data type
      handleMeta.schema  = findprop(hObj, propertyName);
      
      % If a default value is defined locally, update the handle,
      % otherwise, update the local property to handle default.
      
      if isempty(objectValue)
        try
          obj.(propertyAlias) = handleValue;
          objectValue = handleValue;
        end
      end
      
      
      % Determine if read-only
      try
        obj.handleSet(propertyName, objectValue);
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
      end
      
      try
        obj.(propertyAlias) = obj.handleGet(propertyName);
      end
      
      addlistener(obj,  propertyAlias,   'PostSet',  @obj.objectPostSet);
      
      addlistener(h,  propertyName,   'PostSet',  @obj.handlePostSet);
      
    end
    
    function attachHandleFunctions(obj)
      
    end
    
    function createHandlePropertyMap(obj)
      
      if isempty(obj.HandlePropertyMap) || isempty(obj.ObjectPropertyMap)
        handlePropertyTables = obj.getRecursiveProperty('HandleProperties');
        handleFunctionTables = obj.getRecursiveProperty('HandleFunctions');
        handlePropertyTable  = [handlePropertyTables{1,:}, handleFunctionTables{1,:}];
        
        nProperties       = numel(handlePropertyTable);
        
        handleProperties  = cell(size(handlePropertyTable));
        objectProperties  = handleProperties;
        
        readonlyIndex     = [];
        
        for m = 1:nProperties;
          property = handlePropertyTable{m};
          
          if isa(property, 'char')
            objectProperties(m) = {property};
            handleProperties(m) = {property};
          elseif isa(property, 'cell')
            
            objectProperties(m) = property(1);
            handleProperties(m) = property(2);
            
            try
              if strcmpi(property(3), 'readonly')
                readonlyIndex(end+1) = m;
              end
            end
          end
          
        end
        
        writableIdx = setdiff([1:nProperties], readonlyIndex);
        
        obj.ObjectPropertyMap = containers.Map(objectProperties(writableIdx), handleProperties(writableIdx));
        obj.HandlePropertyMap = containers.Map(handleProperties, objectProperties);
      end
    end
    
  end
  
  methods
    function set.Handle(obj, h)
      if isempty(obj.Handle) && ishandle(h)
        obj.Handle = h;
      end
    end
  end
  
  
  
  %% Property Update
  methods(Hidden)
    function objectPostSet(obj, source, event)
      try
        propertyAlias = source.Name;
        propertyName  = obj.ObjectPropertyMap(propertyAlias);
        
        obj.handleSet(propertyName, obj.(propertyAlias));
        
        obj.(propertyAlias) = obj.handleGet(propertyName);
      catch err
        if isvalid(obj), rethrow(err); end
      end
      
      return;
    end
    
    
    function handlePostSet(obj, source, event)
      
      % try
      %   dispf('%s.Queuing = %s', obj.ID, toString(obj.PropertyQueing));
      % catch err
      %   disp('HandlePostSet Disp Error!');
      % end
      
      if obj.PropertyQueing
        obj.PropertyQueue{end+1} = source.Name;
        return;
      end
      
      try
        propertyName  = source.Name;
        % dispf('%s:%s.%s = %s', obj.ID, toString(event.AffectedObject), propertyName, toString(event.AffectedObject.(propertyName)));
        propertyAlias = obj.HandlePropertyMap(propertyName);
        
        try obj.(propertyAlias) = event.AffectedObject.(propertyName); end
      catch err
        if strcmp(err.identifier, 'MATLAB:class:noSetMethod')
          return;
        end
        if isvalid(obj), rethrow(err); end
      end
      return;
    end
    
    
    % function objectpreset(obj, source, event)
    %   return;
    % end
    %
    % function objectpreget(obj, source, event)
    %   return;
    % end
    %
    % function objectpostget(obj, source, event)
    %   return;
    % end
    %
    % function handlepreset(obj, source, event)
    %   return;
    % end
    %
    % function handlepreget(obj, source, event)
    %   return;
    % end
    %
    % function handlepostget(obj, source, event)
    %   return;
    % end
    
    
  end
  
  
  
end

