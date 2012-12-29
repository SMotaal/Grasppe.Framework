classdef DataModel < Grasppe.Prototypes.Instance
  %MODEL Component Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj=DataModel(varargin)
      obj = obj@Grasppe.Prototypes.Instance(varargin{:});
    end      
  end
  
end

