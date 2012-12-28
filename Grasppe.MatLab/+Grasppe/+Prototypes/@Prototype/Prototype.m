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
      
      methodCall                = [obj.ClassName '.' methodName];
      
      switch(nargout)
        case 0  % Good Practice
          feval(methodCall, varargin{:});
        case 1  % Good Practice
          [v1]                  = feval(methodCall, varargin{:});
        case 2  % Bad Practice
          [v1 v2]               = feval(methodCall, varargin{:});
        case 3  % Bad Practice
          [v1 v2 v3]            = feval(methodCall, varargin{:});
        case 4  % Bad Practice
          [v1 v2 v3 v4]         = feval(methodCall, varargin{:});
        case 5  % Bad Practice
          [v1 v2 v3 v4 v5]      = feval(methodCall, varargin{:});
        case 6  % Bad Practice
          [v1 v2 v3 v4 v5 v6]   = feval(methodCall, varargin{:});
      end
      
      for m = 1:nargout
        varargout{m}            = eval(['v' int2str(m)']);
      end
    end
    
    
    [names values]              = setOptions(obj, varargin);    
  end
  
end

