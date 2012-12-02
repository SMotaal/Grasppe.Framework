classdef (HandleCompatible) Prototype
  %HANDLECLASS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  %% ...
  
  %% Imports
  
  properties(SetAccess=private, GetAccess=protected) %, GetAccess=protected)
    Imports
    ClassName
    ClassPath
    SimpleName
    MetaClass
  end
  
  methods
    
    function obj=Prototype(varargin)
      if (nargin > 0), obj.setOptions(varargin{:}); end
      
      % debugStamp('Constructing', 1, obj);
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
    function imports = get.Imports(obj)
      imports = obj.imports();
    end
    
    importList  = imports(obj, varargin);
    
    function className = get.ClassName(obj)
      className = class(obj);
    end
    
    function classPath = get.ClassPath(obj)
      classPath = fullfile(which(obj.ClassName));
    end
    
    function metaClass = get.MetaClass(obj)
      metaClass = metaclass(obj);
    end
    
    function simpleName = get.SimpleName(obj)
      simpleName = char(regexp(obj.ClassName, '[^.]+$', 'match'));
    end
    
  end
  
  methods (Access=protected)
    
    function privateSet(obj, propertyName, value)
      if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
      % try
      %   if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
      % catch err
      %   obj.privateSet@Grasppe.Prototypes.Component(propertyName, value);
      % end
    end
    
    [names values]    = setOptions(obj, varargin);
    
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 1, obj);
    end
  end
  
  
end

