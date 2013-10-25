classdef ComponentHandle < Grasppe.Graphics.GraphicsHandle
  %COMPONENTHANDLE Superclass for User-Inteface Components
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj = ComponentHandle(primitive, varargin) %(object, parent, 
      global debugConstructing;
      
      handleDefaults  = {};
      
      %if ~exist('primitive', 'var') || ~ishghandle(primitive)
      
      if ~exist('primitive', 'var') || ischar(primitive) || (isscalar(primitive) && ~ishghandle(primitive))
        error('Grasppe:JavaComponenHandleConstructor:InvalidPrimitive', 'Attempting to construct a ComponentHandle with a missing, invalid or unsupported primitive');
      end
      
      obj             = obj@Grasppe.Graphics.GraphicsHandle(primitive, handleDefaults{:}, varargin{:}); % object, parent,
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 5, obj); end
      
      if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
            
    end    
    
  end
  
  methods (Static)
    function obj = Create(varargin)
      obj           = feval(mfilename('class'), varargin{:});
    end
  end  
  
end

