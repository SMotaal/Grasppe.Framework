classdef ValueClass < Grasppe.Prototypes.Prototype
  %VALUECLASS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  
  properties
    
  end
  
  methods
    function obj=ValueClass(varargin)
      obj@Grasppe.Prototypes.Prototype(varargin{:});
    end
    
    importList  = imports(obj, varargin);
  end
  
  
end

