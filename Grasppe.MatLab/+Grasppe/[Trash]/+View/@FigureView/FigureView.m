classdef FigureView < Grasppe.Prototypes.HandleGraphicsComponent
  %FIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    
  end
  
  events
    CloseRequest
    Help
    KeyPress
    KeyRelease
    Resize
    WindowButtonDown
    WindowButtonMotion
    WindowButtonUp
    WindowKeyPress
    WindowKeyRelease
    WindowScrollWheel
    ButtonDown
    % Create
    Delete
  end
  
  
  methods(Access=protected)
    function obj = FigureView(object, parent, varargin)
      figureDefaults  = {'NumberTitle', 'off', 'ToolBar', 'none', 'Renderer', 'opengl', 'PaperOrientation', 'landscape'};
      obj             = obj@Grasppe.Prototypes.HandleGraphicsComponent('figure', object, parent, figureDefaults{:}, varargin{:});

      debugStamp('Constructing', 5, obj);
      
      if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
      
    end
  end
  
  methods
    
    function onResize(obj, src, evt)
      obj.handleEvent(src, evt);
    end
    
    function onCloseRequest(obj, src, evt)
      obj.Visible='off';
    end
    
    function onWindowButtonMotion(obj, src, evt)
      obj.handleEvent(src, evt);
      %disp(evt)
    end
    
    function onWindowScrollWheel(obj, src, evt)
      obj.handleEvent(src, evt);
      %disp(evt)
    end  
    
    function onKeyPress(obj, src, evt)
      obj.handleEvent(src, evt);
      %disp(evt)
    end
    
  end
  
  methods(Static, Hidden)
    obj                     = testFigureView(hObject);
    
    function component = CreateComponent(object, parent, varargin)
      component = feval(mfilename('class'), object, parent, varargin{:});
    end
    
    function component = CreateNewComponent(parent, varargin)
      component = feval(mfilename('class'), [], parent, varargin{:});
    end    
    
    function component = CreateComponentFromObject(object, parent, varargin)
      component = feval(mfilename('class'), object, parent, varargin{:});
    end
    
  end  
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.HandleGraphicsComponent;
    end
  end
  
end
