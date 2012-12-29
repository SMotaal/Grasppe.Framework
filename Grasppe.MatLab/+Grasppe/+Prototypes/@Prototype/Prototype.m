classdef (HandleCompatible) Prototype
  %HANDLECLASS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  %% ...
  
  %% Imports
  
  properties(SetAccess=private, GetAccess=public, Hidden, Transient) %, GetAccess=protected)
    Imports
    ClassName
    ClassPath
    SimpleName
    MetaClass
    PackageName
  end
  
  methods
    
    function obj=Prototype(varargin)
      if (nargin > 0), obj.setOptions(varargin{:}); end
      
      % debugStamp('Constructing', 5, obj);
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
    function imports = get.Imports(obj)
      imports =               obj.imports();
    end
    
    importList  = imports(obj, varargin);
    
    function className = get.ClassName(obj)
      className = obj.ClassName;
      if isempty(className)
        className             = class(obj);
        obj.ClassName         = className;
      end
    end
    
    function classPath = get.ClassPath(obj)
      classPath = obj.ClassPath;
      if isempty(classPath)
        classPath             = fullfile(which(obj.ClassName));
        obj.ClassPath         = classPath;
      end
    end
    
    function metaClass = get.MetaClass(obj)
      metaClass = obj.MetaClass;
      if isempty(metaClass)
        metaClass             = metaclass(obj);
        obj.MetaClass         = metaClass;
      end
    end
    
    function simpleName = get.SimpleName(obj)
      simpleName = obj.SimpleName;
      if isempty(simpleName)
        simpleName            = char(regexp(obj.ClassName, '[^.]+$', 'match'));
        obj.SimpleName        = simpleName;
      end
    end
    
    function packageName = get.PackageName(obj)
      packageName = obj.PackageName;
      if isempty(packageName)
        packageName           = regexprep(class(obj), '(\.?[^.]+$)', '');
        obj.PackageName       = packageName;
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
      [varargout{:}]    = feval([obj.ClassName '.' methodName], varargin{:});
    end
    
    
    [names values]              = setOptions(obj, varargin);
  end
  
end

