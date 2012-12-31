classdef Model < Grasppe.Prototypes.Handle  & matlab.mixin.Copyable & hgsetget
  %MODEL Model Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj=Model(varargin)
      obj@Grasppe.Prototypes.Handle(varargin{:});
    end
    
  end
  
end

