classdef (Sealed) Root < Grasppe.Graphics.GraphicsHandle
  %ROOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    
  end
   
  
  methods (Access=protected)
    function obj = Root()
      obj                   = obj@Grasppe.Graphics.GraphicsHandle(handle(0));
      obj.initialize();
      
    end
  end
  
  methods (Access=protected)
    function attachHandleEvents(obj)
    end
    
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Graphics.GraphicsHandle;
    end
  end
  
  methods (Static)
    function obj = Create(varargin)
      obj           = feval(mfilename('class'), varargin{:});
    end
  end
  
end
