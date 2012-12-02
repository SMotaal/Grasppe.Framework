classdef Process < Grasppe.Prototypes.TaskGroup
  %PROCESS Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj=Process(varargin)
      obj@Grasppe.Prototypes.TaskGroup(varargin{:});
    end  
    
  end
  
end

