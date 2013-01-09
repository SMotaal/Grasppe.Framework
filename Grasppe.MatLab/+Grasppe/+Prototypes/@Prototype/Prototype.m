classdef (HandleCompatible) Prototype < hgsetget
  %HANDLECLASS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  %% ...
  
  %% Imports
  
  properties (SetAccess=private, GetAccess=public, Hidden, Transient) %, GetAccess=protected)
    Imports
    ClassName
    ClassPath
    SimpleName
    MetaClass
    PackageName
  end
  
  properties (SetAccess=private, GetAccess=public, Hidden, Transient)
    prototypeProperties = struct;
    %     prototypeSetter     = struct;
    %     prototypeGetter     = struct;
  end
  
  methods
    
    function obj=Prototype(varargin)
      if (nargin > 0), obj.setOptions(varargin{:}); end
    end
    
    function imports = get.Imports(obj)
      imports               = obj.imports();
    end
    
    importList  = imports(obj, varargin);
    
    function className = get.ClassName(obj)
      className             = obj.ClassName;
      if isempty(className)
        className           = class(obj);
        obj.ClassName       = className;
      end
    end
    
    function classPath = get.ClassPath(obj)
      classPath             = obj.ClassPath;
      if isempty(classPath)
        classPath           = fullfile(which(obj.ClassName));
        obj.ClassPath       = classPath;
      end
    end
    
    function metaClass = get.MetaClass(obj)
      metaClass             = obj.MetaClass;
      if isempty(metaClass)
        metaClass           = metaclass(obj);
        obj.MetaClass       = metaClass;
      end
    end
    
    function simpleName = get.SimpleName(obj)
      simpleName            = obj.SimpleName;
      if isempty(simpleName)
        simpleName          = char(regexp(obj.ClassName, '[^.]+$', 'match'));
        obj.SimpleName      = simpleName;
      end
    end
    
    function packageName = get.PackageName(obj)
      packageName           = obj.PackageName;
      if isempty(packageName)
        packageName         = regexprep(class(obj), '(\.?[^.]+$)', '');
        obj.PackageName     = packageName;
      end
    end
    
    function value = prototypeGet(obj, field, callback)
      
      field                 = lower(field);
      property              = obj.getPrototypeProperty(field);
      
        
      try
        if ~isempty(property.Getter)
          if isequal(property.Getting, false)
            obj.prototypeProperties.(field).Getting = true;
            obj.prototypeProperties.(field).Value   = feval(property.Getter);
            obj.prototypeProperties.(field).Getting = false;
          end
        else
          if nargin>2
            obj.prototypeProperties.(field).Value   = feval(callback);
            obj.prototypeProperties.(field).Getter  = callback;
          end
        end
      catch err
        obj.prototypeProperties.(field).Getting = false;
        rethrow(err);
      end
      
      
      value                 = obj.prototypeProperties.(field).Value;
      
    end
    
    function value = prototypePeak(obj, field)
      field                 = lower(field);
      property              = obj.getPrototypeProperty(field);
      value                 = property.Value;
    end
    
    function value = prototypeSet(obj, field, newValue)
      
      field                 = lower(field);
      property              = obj.getPrototypeProperty(field);
      
      % if property.Setting, return; end
      obj.prototypeProperties.(field).Setting = true;
      
      if ~isempty(property.Setter)
        value               = feval(property.Setter, newValue);
      else
        value               = newValue;
      end
      
      obj.prototypeProperties.(field).Setting = false;      
      obj.prototypeProperties.(field).Value   = value;      
      
    end
    
    function property = getPrototypeProperty(obj, field)
      % field                 = lower(field);
      property              = [];
      try
        property            = obj.prototypeProperties.(field);
        return;
      end
      
      if isempty(property) %~isfield(obj.prototypeProperties, field);
        
        value               = [];
        getter              = [];
        setter              = [];
        
        methodNames         = methods(obj);
        
        %% Getter
        methodIndex         = strcmpi(['get' field], methodNames);
        if any(methodIndex)
          getter            = @()feval(methodNames{methodIndex}, obj);
        end
        
        %% Setter
        methodIndex         = strcmpi(['set' field], methodNames);
        if any(methodIndex)
          setter            = @(value)feval(methodNames{methodIndex}, obj, value);
        end
        
        property            = struct('Getter', getter, 'Setter', setter, 'Value', value, 'Getting', false, 'Setting', false);
        
        obj.prototypeProperties.(field) = property;
      end
    end
        
  end
  
  methods (Access=protected)
    
    function privateSet(obj, propertyName, value)
      if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
    end
    
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
    end
    
    function varargout = static(obj, methodName, varargin)
      varargout         = cell(1,nargout);
      %if nargout>0, varargout = cell(1,nargout); end
      [varargout{:}]    = feval([obj.ClassName '.' methodName], varargin{:});
    end
    
    
    [names values]              = setOptions(obj, varargin);
  end
  
end

