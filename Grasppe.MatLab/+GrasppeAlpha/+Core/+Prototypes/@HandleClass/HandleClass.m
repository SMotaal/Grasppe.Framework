classdef HandleClass < dynamicprops
  %HANDLECLASS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  %% ...
  
  %% Imports
  
  properties
    Imports
    ClassName
    ClassPath
    MetaClass
    MetaProperties
  end
  
  methods
    
    function obj=HandleClass(varargin)
      obj = obj@dynamicprops();
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

    
  end
  
  %   methods (Static)
  %     function name = ClassName(obj)
  %       if nargin>0
  %         name  = class(obj);
  %       end
  %     end
  %   end
  
end

