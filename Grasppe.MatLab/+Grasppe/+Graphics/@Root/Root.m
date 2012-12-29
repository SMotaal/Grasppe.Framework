classdef Root < Grasppe.Graphics.GraphicsHandle
  %ROOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    
  end
   
  
  methods % (Access=protected)
    function obj = Root(varargin)
      obj             = obj@Grasppe.Graphics.GraphicsHandle('root', handle(0), [], varargin{:});

      debugStamp('Constructing', 5, obj);
      
      if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
      
    end
  end
  
  methods
    
    
  end
  
  methods(Static, Hidden)
    obj                     = testFigureObject(hObject);
    
    function component = GetRoot()
      
      try
        component = getappdata(0, 'HandleComponent');
        if isa(component, mfilename('class')), return; end
      end
      
      component = feval(mfilename('class'));
    end
    
    function component = CreateComponent(object, parent, varargin)
      component = feval(mfilename('class'), varargin{:});
    end
    
    function component = CreateNewComponent(parent, varargin)
      component = feval(mfilename('class'), varargin{:});
    end
    
    function component = CreateComponentFromObject(object, parent, varargin)
      component = feval(mfilename('class'), varargin{:});
    end
    
  end  
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Graphics.GraphicsHandle;
    end
  end
  
end
