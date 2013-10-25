classdef UIMenu < Grasppe.UI.ComponentHandle
  %UITOOLBAR MatLab UIToolbar Wrapper
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj = UIMenu(primitive, varargin) %(object, parent, 
      global debugConstructing;
      
      handleDefaults  = {};
      
      %if ~exist('primitive', 'var') || ~ishghandle(primitive)
      
      if ~exist('primitive', 'var') || ischar(primitive) || (isscalar(primitive) && ~ishghandle(primitive))
        primitive = 'uimenu';
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

