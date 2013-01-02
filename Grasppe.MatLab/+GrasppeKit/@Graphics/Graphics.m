classdef (Sealed) Graphics
  %GRAPHICS Grasppe Graphics Utilities (Prototypes 2)
  %   Detailed explanation goes here
  
  properties (Constant)
    Root                    = GrasppeKit.Graphics.GetRoot;
  end
  
  methods(Access=private)
    function obj = Utilities()
    end
  end
  
  
  methods (Static, Hidden)
    component               = GetRoot;
  end
  
end

