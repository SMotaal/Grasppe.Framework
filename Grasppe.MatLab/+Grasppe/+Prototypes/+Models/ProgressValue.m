classdef ProgressValue < Grasppe.Prototypes.Value
  %TASKMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Status  = '';
    Step    = 0;
    Steps   = 0;
    Load    = 1;
  end
  
  methods
    function obj=ProgressValue(varargin)
      obj@Grasppe.Prototypes.Value(varargin{:});
    end
  end
  
end

