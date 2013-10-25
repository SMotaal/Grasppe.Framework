classdef JavaComponentHandle < Grasppe.UI.ComponentHandle
  %JAVACOMPONENTHANDLE Superclass for Java User-Interface Handles
  %   Detailed explanation goes here
  
  properties
    JavaObject
  end
  
  methods
    function obj = JavaComponentHandle(primitive, varargin) %(object, parent,
      global debugConstructing;
      
      handleDefaults  = {};
      
      %if ~exist('primitive', 'var') || ~ishghandle(primitive)
      
      if ~exist('primitive', 'var') || ischar(primitive) || (isscalar(primitive) && ~ishghandle(primitive))
        %primitive = 'figure';
        error('Grasppe:JavaComponenHandleConstructor:InvalidPrimitive', 'Attempting to construct a JavaComponentHandle with a missing, invalid or unsupported primitive');
      end
      
      obj             = obj@Grasppe.UI.ComponentHandle(primitive, handleDefaults{:}, varargin{:}); % object, parent,
      
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

