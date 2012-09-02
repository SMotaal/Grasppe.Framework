classdef Component < Grasppe.Core.Instance
  %GRASPPE.CORE.COMPONENT with enhanced get/set
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    Defaults    = [];
    Initialized = false;
    SubHandles  = [];
    SubHandleObjects = {};
    IsDeleting  = false;
  end
  
  properties (Access=private)
    ComponentOptions
  end
  
  methods
    function obj = Component(varargin)
      obj = obj@Grasppe.Core.Instance;
      
      obj.ComponentOptions = varargin;
      
      obj.createComponent;
      
    end
    
    function componentOptions = getComponentOptions(obj)
      componentOptions = obj.ComponentOptions;
    end
    
    function delete(obj)
      debugStamp(5, obj);
      obj.IsDeleting = true;
      obj.deleteHandles;
    end
    
    function bless(obj)
      isBlessed = isvalid(obj) && ~isequal(obj.IsDeleting, true)
      
      if ~isBlessed
        debugStamp('Component Not Blessed', 5, obj);
        evalin('caller', 'return');
        return;
      end
      debugStamp('Component Blessed', 5, obj);
    end
    
    
  end
  
  methods (Hidden) %Access=protected)
    
    function value = DefaultValue(obj, propertyName, fallbackValue)
      value     = [];
      try
        value = obj.MetaProperties.(propertyName).NativeMeta.DefaultValue;
      catch err
        if nargin>1
          value = fallbackValue;
        else
          rethrow(err);
        end
      end
    end
    
    function registerHandle(obj, handles)
      % try
      %   if isa(handles, 'Grasppe.Core.Prototype')
      %     dispf('Registering %s @ %s', handles.ID, obj.ID);
      %   else
      %     dispf('Registering %s @ %s', toString(handles), obj.ID);
      %   end
      % catch
      %   dispf('Registering %s @ %s', 'objects', obj.ID);
      % end
      if ishandle(handles) && isnumeric(handles)
        try obj.SubHandles = [obj.SubHandles handles]; end
      elseif isobject(handles)
        try obj.SubHandleObjects = {obj.SubHandleObjects{:}, handles}; end
      elseif iscell(handles)
        for m = 1:numel(handles)
          handle = handles{m};
          if isobject(handle)
            try obj.SubHandleObjects = {obj.SubHandleObjects{:}, handle}; end
          end
        end
      end
    end
    
    function deleteHandles(obj)
      
      %objects = obj.SubHandleObjects;
      for m = 1:numel(obj.SubHandleObjects)
        try obj.SubHandleObjects{m}.obj.IsDeleting = true; end
      end
      
      %handles = obj.SubHandles;
      for m = 1:numel(obj.SubHandles)
        % try dispf('Deleting %s @ %s', toString(handles(m)), obj.ID); end
        %try obj.SubHandles(m).obj.IsDeleting = true;
        try delete(obj.SubHandles(m)); end
        obj.SubHandles(m) = [];
      end
      
      obj.SubHandles = [];
      
      for m = 1:numel(obj.SubHandleObjects)
        % try dispf('Deleting %s @ %s', toString(handles{m}), obj.ID); end        
        try delete(obj.SubHandleObjects{m}); end
        obj.SubHandleObjects{m} = [];
      end
      obj.SubHandleObjects = {};
    end
    
  end
  
  methods(Access=protected)
    
    function createComponent(obj)
      
      try
        componentType = obj.ComponentType;
      catch err
        error('Grasppe:Component:MissingType', ...
          'Unable to determine the component type to create the component.');
      end
      
      obj.intializeComponentOptions;
      
      obj.Initialized = true;
      
    end
    
    function [names values] = intializeComponentOptions(obj)
      
      componentOptions  = obj.ComponentOptions;
      
      [defaultNames defaultValues]  = obj.setOptions(obj.Defaults);
      [initialNames initialValues]  = obj.setOptions(componentOptions{:});
      
      names   = unique([defaultNames, initialNames]);
      if ~isempty(names)
        options = obj.getOptions(names{:});
        values  = options(2:2:end);
      else
        values  = names;
      end
      
    end
    
  end
  
  methods (Hidden=true)
    
    function options = getOptions(obj, varargin)
      
      switch nargin
        case 2
          names = varargin{1};
        case 1
          return;
        otherwise
          names = varargin;
      end
      
      options = cell(1, numel(names).*2);
      if isa(names, 'char')
        names = {names};
      end
      for i = 1:numel(names)
        name  = names{i};
        value = obj.(name);
        
        idx = 1+(i-1)*2;
        
        options(idx)    = {name};
        options(idx+1)  = {value};
      end
      
    end
    
    function [names values] = setOptions(obj, varargin)
      
      [names values paired pairs] = obj.parseOptions(varargin{:});
      
      if (paired)
        for i=1:numel(names)
          try
            if ~isequal(obj.(names{i}), values{i})
              obj.(names{i}) = values{i};
            end
          catch err
            if ~strcontains(err.identifier, 'noSetMethod')
              try debugStamp(obj.ID, 5); end
              disp(['Could not set ' names{i} ' for ' class(obj)]);
            end
          end
        end
      end
      
    end
    
    function [names values paired pairs] = parseOptions(obj, varargin)
      
      names        = varargin;
      extraArgs   = {};
      
      %% Parse Lead Structures
      while (~isempty(names) && isstruct(names{1}))
        stArgs    = structArgs(names{1});
        extraArgs = [extraArgs stArgs]; %#ok<*AGROW>
        
        if length(names)>1
          names = names(2:end);
        else
          names = {};
        end
        
      end
      
      names = [extraArgs, names];
      
      [pairs paired names values ] = pairedArgs(names{:});
      
    end
    
  end
  
  
  methods
    function defaults = get.Defaults(obj)
      try if isempty(obj.Defaults), obj.Defaults = obj.DefaultOptions; end; end
      defaults = obj.Defaults;
    end
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions();
  end
  
end

