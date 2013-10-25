classdef ValueClass
  %VALUECLASS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  %% ...
  
  %% Imports
  
  properties
    Imports
  end
  
  methods
    function imports = get.Imports(obj)
      imports = obj.imports();
    end
        
    importList  = imports(obj, varargin);
  end

  
end

