classdef Figure < Grasppe.Graphics.GraphicsHandle
  %FIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Layout
    Objects                 = struct;
    AltKeyDown              = false;
    ControlKeyDown          = false;
    ShiftKeyDown            = false;
    MetaKeyDown             = false;
    JavaFrame
  end
  
  properties (Hidden, Transient)
    GestureComponent;
    MouseRobot;
    GestureListener;
    GestureListenerHandle;
    
    Zooming                 = false;
    Rotating                = false;
    Swiping                 = false;
    Scrolling               = false;
  end
  
  events
    CloseRequest
    
    % Help
    % KeyPress
    % KeyRelease
    % Resize
    
    WindowButtonDown
    WindowButtonMotion
    WindowButtonUp
    WindowKeyPress
    WindowKeyRelease
    WindowScrollWheel
    
    % Swipe
    % Scroll
    % Zoom
    % Rotate
    % ButtonDown
    % Delete
    
  end
  
  
  methods (Access=protected)
    function obj = Figure(primitive, varargin) %(object, parent,
      global debugConstructing;
      
      figureDefaults              = {'NumberTitle', 'off', 'ToolBar', 'none', 'Renderer', 'opengl', 'PaperOrientation', 'landscape'};
      
      if ~exist('primitive', 'var') || isempty(primitive) || (isscalar(primitive) && ~ishghandle(primitive)) % ~ischar(primitive) || 
        primitive                 = 'figure';
      end
      
      obj                         = obj@Grasppe.Graphics.GraphicsHandle(primitive, figureDefaults{:}, varargin{:}); % object, parent,
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 5, obj); end
      
      % if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
      
      %% Create Gesture Component
      try
        hGestureComponent         = javacomponent('com.grasppe.jive.gesture.GestureComponent', 'Overlay');
        obj.GestureComponent      = handle(hGestureComponent, 'CallbackProperties');
        obj.GestureListener       = Grasppe.Prototypes.JavaActionListener(obj.GestureComponent.getActionWrapper());
        obj.GestureListenerHandle = obj.GestureListener.addlistener('JavaEvent', @obj.gestureEventCallback);
        obj.GestureComponent.setVisible(false);
      end
      
    end
  end
  
  methods
        
    gestureEventCallback(obj, src, evt);
    dispatchClick(obj, button, clicks);
    
    panAxes(obj, plotAxes, panXY, panAmount);
    
    targetHandle            = getTargetAxesHandle(obj, targetObject);
    
    function component = getComponentFromHandle(obj, primitive)
      component             = [];
      
      if isa(primitive, 'Grasppe.Graphics.GraphicsHandle')
        try component       = primitive.GraphicsHandleObject; end
      elseif ishghandle(primitive)
        try 
          component         = getappdata(primitive, 'Prototype');
          if isempty(component)
            component       = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(primitive);
          end
        end
      end
    end
    
    function javaFrame = get.JavaFrame(obj)
      javaFrame                   = [];
      try javaFrame               = get(obj.Object, 'JavaFrame'); end
    end
    
    function delete(obj)
      % try delete(obj.Object); end     % Closes figure
    end
    
    function showFigure(obj)
      try obj.Object.Visible = 'on'; end
    end
    
    function hideFigure(obj)
      try obj.Object.Visible = 'off'; end
    end    
    
  end
  
  methods
    
    onKeyPress(obj, src, evt);
    onKeyRelease(obj, src, evt);    
    
    onWindowButtonUp(obj, src, evt);
    onScroll(obj, src, evt);
    onZoom(obj, src, evt);
    
    function onSwipe(obj, src, evt)
      dispf('%s: \t\t%s', evt.EventType, char(evt.Direction));
    end
    
    function onRotate(obj, src, evt)
      dispf('%s: %f\t\t%s', evt.EventType, evt.Angle, char(evt.Direction));
    end  
    
    function onResize(obj, src, evt)
      obj.handleEvent(src, evt);
    end
    
    function onCloseRequest(obj, src, evt)
      obj.hideFigure;
    end
    
    function onWindowButtonDown(obj, src, evt)
      obj.handleEvent(src, evt);
    end
    
    function onWindowButtonMotion(obj, src, evt)
      obj.handleEvent(src, evt);
    end
        
    function onClick(obj, src, evt)
      obj.handleEvent(src, evt);
    end
    
    function onDoubleClick(obj, src, evt)
      obj.handleEvent(src, evt);
    end
    
    function onWindowScrollWheel(obj, src, evt)
      obj.GestureComponent.setVisible(true);
      
      Grasppe.Kit.Utilities.DelayedCall(@(s, e)obj.GestureComponent.setVisible(false), 1,'start');
      
    end
    
  end
  
  methods(Access=protected)

  end
  
  methods(Static, Hidden)
%     obj                     = testFigureObject(hObject);
%     function component = CreateComponent(object, parent, varargin)
%       component = feval(mfilename('class'), object, parent, varargin{:});
%     end
%     
%     function component = CreateNewComponent(parent, varargin)
%       component = feval(mfilename('class'), [], parent, varargin{:});
%     end
%     
%     function component = CreateComponentFromObject(object, parent, varargin)
%       component = feval(mfilename('class'), object, parent, varargin{:});
%     end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Graphics.GraphicsHandle;
    end
    
    
    function inspectHandle(obj)
      try
        inspect(obj.Object); %.CurrentObject);
      catch err
        obj.inspect();
      end
    end
    
  end
  
  
  methods (Static)
    function obj = Create(varargin)
      obj                   = feval(mfilename('class'), varargin{:});
    end
  end
  
  methods (Static, Hidden)
    
    function obj = CreateTestFigure()
      global debugConstructing;
      
      figureOptions         = {'Visible', 'on', 'Name', 'Figure with Gesture Control'}; % 'ToolBar', 'none',
      
      obj                   = feval(mfilename('class'), [], figureOptions{:});
      
      % uitoolbar(obj.Handle);
      for m = 1:4
        % set(0, 'CurrentFigure', obj.Object);
        mStr                = int2str(m);
        subplot(2,2,m);
        ezplot3(['s/' mStr], [mStr '*s'], ['s^' mStr]); % ezplot3('s/2','2*s','s^2', 'LineSmoothing', 'on')
      end
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 1, obj); end
      if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
  end
  
  
end
