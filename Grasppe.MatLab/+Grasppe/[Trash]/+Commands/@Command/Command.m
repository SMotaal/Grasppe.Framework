classdef Command < Grasppe.Prototypes.Prototype & matlab.mixin.Heterogeneous
  %COMMAND Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
    
  end
  
  methods
    function obj=Command(varargin)
      obj = obj@Grasppe.Prototypes.Prototype(varargin{:});
    end      
  end
  
end
