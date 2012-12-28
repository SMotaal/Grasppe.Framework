classdef Operation < Grasppe.Prototypes.TaskGroup
  %OPERATION Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties  

  end
  
  methods
    function obj=Operation(varargin)
      obj = obj@Grasppe.Prototypes.TaskGroup(varargin{:});
    end      
  end
  
end

