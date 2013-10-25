classdef Kit < Grasppe.Prototypes.Instance
  %UTILITIES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Constant)
    Singlton  = Grasppe.Graphics.Kit.GetSinglton();
  end
  
  properties (Dependent)
    Root
  end
  
  methods
    
    function root = get.Root(obj)
      root          = Grasppe.Graphics.Kit.GetRoot();
    end
  end
  
  methods (Static)
    singlton        = GetSinglton();
    root            = GetRoot();
    obj             = GraphicsFactory(primitive, parent, varargin);
  end
  
end

