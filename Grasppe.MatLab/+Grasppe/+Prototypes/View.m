classdef View < Grasppe.Prototypes.Component
  %VIEW Component Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
    
  end
  
  methods
    function obj=View(varargin)
      obj@Grasppe.Prototypes.Component(varargin{:});
    end
    
    function createView(obj)
    end
    
    function showView(obj)
    end
    
    function hideView(obj)
    end
    
    function inspect(obj)
      obj.inspectModel;
    end
    
    function inspectModel(obj)
      inspect(obj.Model);
    end
  end
  
end

