function obj = Factory(primitive, parent, varargin)
  %GRAPHICSFACTORY Summary of this function goes here
  %   Detailed explanation goes here
  
  switch nargin
    case 0
      obj = Grasppe.Graphics.GraphicsHandle();
    case 1
      obj = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(primitive);
    case 2
      obj = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(primitive, parent);
    otherwise
      obj = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(primitive, parent, varargin{:});
  end
  
end

