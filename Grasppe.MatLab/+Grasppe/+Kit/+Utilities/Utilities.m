classdef (Sealed) Utilities
  %GRAPHICS Grasppe Graphics Utilities (Prototypes 2)
  %   Detailed explanation goes here
  
  properties (Constant)
    % Root                    = Grasppe.Kit.Graphics.GetRoot;
  end
  
  methods(Access=private)
    function obj = Utilities()
    end
  end
  
  methods (Static)
    ProgressUpdate(progress, varargin)
    SafeExit(terminateCallback, abortCallback, forceCallback, cancelCallback)
    
    message                     = DisplayText(ProductID, varargin);
    message                     = DisplayError(varargin);
    
    delayTimer                  = DelayedCall(callback, delay, mode)
    [names values paired pairs] = ParseOptions(varargin)
  end
  
end

