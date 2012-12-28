classdef Figure < Grasppe.Prototypes.HandleGraphicsComponent
  %FIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Layout
    Objects         = struct;
    AltKeyDown      = false;
    ControlKeyDown  = false;
    ShiftKeyDown    = false;
    MetaKeyDown     = false;
    JavaFrame
  end
  
  properties (Hidden)
    GestureComponent;
    MouseRobot;
    GestureListener;
    GestureListenerHandle;
    
    Zooming     = false;
    Rotating    = false;
    Swiping     = false;
    Scrolling   = false;
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
    
    %     Swipe
    %     Scroll
    %     Zoom
    %     Rotate
    % ButtonDown
    % Delete
    
  end
  
  
  methods % (Access=protected)
    function obj = Figure(object, parent, varargin)
      figureDefaults  = {'NumberTitle', 'off', 'ToolBar', 'none', 'Renderer', 'opengl', 'PaperOrientation', 'landscape'};
      obj             = obj@Grasppe.Prototypes.HandleGraphicsComponent('figure', object, parent, figureDefaults{:}, varargin{:});
      
      debugStamp('Constructing', 5, obj);
      
      if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
      
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
    function javaFrame = get.JavaFrame(obj)
      javaFrame           = [];
      try javaFrame       = get(obj.Object, 'JavaFrame'); end
    end
    
    function gestureEventCallback(obj, src, evt)
      e                         = [];
      try e                     = evt.SourceData.Data.Data; end
      
      direction                 = [];
      try direction             = evt.SourceData.Data.Metadata; end
      try evt.addField('Direction', direction); end
      
      currentObject             = []; 
      try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(obj.CurrentObject);  end; end
      try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(hittest(obj.Object)); end; end
      try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(obj.CurrentAxes);  end; end

      try evt.addField('TargetObject', currentObject); end
      
      switch(evt.EventType)
        case 'Click'
          obj.dispatchClick(e.getButton());
          % obj.notify('Click', evt);
        case 'Double Click'
          obj.dispatchClick(e.getButton(), 2);
          % obj.notify('DoubleClick', evt);
        case 'Hover'
          if ~obj.AltKeyDown, obj.GestureComponent.setVisible(false); end
        case{'Scroll Up', 'Scroll Down', 'Scroll Left', 'Scroll Right'}
          evt.addField('Amount', round(e.getWheelRotation()));
          obj.notify('Scroll', evt);
        case{'Swipe Up', 'Swipe Down', 'Swipe Left', 'Swipe Right'}
          if obj.AltKeyDown, return; end
          obj.notify('Swipe', evt);
        case{'Zoom In', 'Zoom Out'}
          if ~obj.AltKeyDown; obj.GestureComponent.setVisible(false); return; end
          evt.addField('Scale', double(e.getMagnification()));
          obj.notify('Zoom', evt);
        case{'Rotate'};
          if ~obj.AltKeyDown; obj.GestureComponent.setVisible(false); return; end
          evt.addField('Angle', double(e.getRotation()));
          obj.notify('Rotate', evt);
      end
    end
    
    function onScroll(obj, src, evt)
      %% if obj.MetaKeyDown
        deltaH = 0;
        deltaV = 0;
        
        switch (lower(char(evt.Direction)))
          case 'left'
            deltaH = -1;
          case 'right'
            deltaH = 1;
          case 'up'
            deltaV = 1;
          case 'down'
            deltaV = -1;
          otherwise
           return;
        end
        
        amount = max(1, round(mod(evt.Amount, 10))); % /10
        
        if obj.AltKeyDown
          if obj.MetaKeyDown
            camzoom(obj.getTargetAxesHandle(evt.TargetObject), 1);
            campan(deltaH* amount, deltaV);
          else %if ~obj.MetaKeyDown
            obj.panAxes(handle(obj.getTargetAxesHandle(evt.TargetObject)), [deltaH deltaV]  * amount, 1);  
          end
        end
      % end
      %dispf('%s: %d\t\t%s', evt.EventType, evt.Amount, char(evt.Direction));
    end
    
    function panAxes(obj, plotAxes, panXY, panLength) % (obj, source, event)
      % persistent lastPanXY
      lastPanXY = [];
      % obj.bless;
            
      panStickyThreshold  = 3;
      panStickyAngle      = 45/2;
      panWidthReference   = 600;
      
%       if isempty(lastPanXY) || panLength==0;
%         deltaPanXY  = [0 0];
%       else
        deltaPanXY  = panXY; % - lastPanXY;
        position    = obj.Position;
        panFactor   = position([3 4])./panWidthReference;
        deltaPanXY  = round(deltaPanXY ./ (panFactor));
%       end
      
      try
        newView = plotAxes.View - deltaPanXY;
        
        if newView(2) < 0
          newView(2) = 0;
        elseif newView(2) > 90
          newView(2) = 90;
        end
        
        if panStickyAngle-mod(newView(1), panStickyAngle)<panStickyThreshold || ...
            mod(newView(1), panStickyAngle)<panStickyThreshold
          newView(1) = round(newView(1)/panStickyAngle)*panStickyAngle;
        end
        if panStickyAngle-mod(newView(2), panStickyAngle)<panStickyThreshold || ...
            mod(newView(2), panStickyAngle)<panStickyThreshold
          newView(2) = round(newView(2)/panStickyAngle)*panStickyAngle; % - mod(newView(2), 90)
        end
        
        plotAxes.View = newView;
        
      catch err
        warning('Grasppe:MouseEvents:PanningFailed', err.message);
      end
      
      lastPanXY   = panXY;
      lastPanTic  = tic;
      
      %consumed = obj.mousePan@GraphicsObject(source, event);
    end
    
    
    function onSwipe(obj, src, evt)
      dispf('%s: \t\t%s', evt.EventType, char(evt.Direction));
    end
    
    
    function targetHandle = getTargetAxesHandle(obj, targetObject)
      
        targetHandle = obj.CurrentAxes;
        
        while(isa(targetObject, 'Grasppe.Prototypes.HandleGraphicsComponen') && ...
            any(strcmp(targetObject.ObjectType, {'axes', 'root', 'figure'})))

          targetObject = targetObject.ParentComponent;
        end
        
        if isa(targetObject, 'Grasppe.Prototypes.HandleGraphicsComponen')
          targetHandle  = handle(targetObject.Object);
        end
      
    end
    
    function onZoom(obj, src, evt)
      newScale = 0;
      
      if evt.Scale > 0
        newScale = 1 + evt.Scale * 2;
      elseif evt.Scale < 0
        newScale = 1 - abs(evt.Scale) * 2;
      end
      
      try
        
        % if ishandle(targetHandle)
        camzoom(obj.getTargetAxesHandle(evt.TargetObject), newScale);
        return;
        %end
      end
      
      dispf('%s: %f\t\t%s', evt.EventType, newScale, char(evt.Direction));
    end
    
    function onRotate(obj, src, evt)
      dispf('%s: %f\t\t%s', evt.EventType, evt.Angle, char(evt.Direction));
    end    
    
    function dispatchClick(obj, button, clicks)
      if ~isjava(obj.MouseRobot), obj.MouseRobot = javaObject('java.awt.Robot'); end
      
      lastVisible = false;
      
      try
        lastVisible = obj.GestureComponent.isVisible();
        obj.GestureComponent.setVisible(false);
      end
      
      if ~exist('button', 'var') || isempty(button),  button  = 1; end
      
      if ~exist('clicks', 'var') || isempty(clicks),  clicks  = 1; end
      
      switch (button)
        case 1
          button = java.awt.event.InputEvent.BUTTON1_MASK;
      end
      
      obj.MouseRobot.setAutoDelay(1);
      
      for m = 1:clicks
        obj.MouseRobot.mousePress(button);
        obj.MouseRobot.mouseRelease(button);
        pause(0.01);
        obj.MouseRobot.waitForIdle();
      end
      
      if clicks==2, obj.Object.SelectionType = 'open'; end
      
      if lastVisible
        % obj.MouseRobot.waitForIdle();
        try obj.GestureComponent.setVisible(true); end;
        % GrasppeKit.DelayedCall(@(s, e)obj.GestureComponent.setVisible(true),1,'start');
      end
      
    end
    
  end
  
  methods
    
    function onResize(obj, src, evt)
      obj.handleEvent(src, evt);
    end
    
    function onCloseRequest(obj, src, evt)
      obj.hideFigure;
      % delete(obj);
    end
    
    function onWindowButtonDown(obj, src, evt)
      obj.handleEvent(src, evt);
      %disp(evt)
    end
    
    function onWindowButtonMotion(obj, src, evt)
      obj.handleEvent(src, evt);
      %disp(evt)
    end
    
    function onWindowButtonUp(obj, src, evt)
      
      persistent clickTimer lastButton;
%       if isempty(clickTimer) || ~isa(clickTimer, 'timer') || ~isvalid(clickTimer)
%         clickTimer = GrasppeKit.DelayedCall(@(s, e)obj.notify('Click', evt.addField('Button', 'Primary')), 0.25,'hold');
%       end
      
      try stop(clickTimer);   end;
      
      switch(lower(obj.Object.SelectionType))
        case 'normal'     % Click left mouse button
          try delete(clickTimer); end;
          clickTimer = GrasppeKit.DelayedCall(@(s, e)obj.notify('Click', evt.addField('Button', 'Primary')), 0.20,'start');
          lastButton = 1;
        case 'open'       % Double-click any mouse button
          if ~isequal(lastButton, 1)
            obj.notify('Click', evt.addField('Button', 'Primary'));
          else
            obj.notify('DoubleClick', evt.addField('Button', 'Primary'));
          end
          lastButton = 1;
        case 'alt'        % Control-click left mouse button or click right mouse button
          lastButton = 2;
          obj.notify('Click', evt.addField('Button', 'Secondary')); % Alternate
        case 'extend'     % Shift - click left mouse button or click middle (or both left and right mouse buttons on Windows)
          lastButton = 3;
          obj.notify('Click', evt.addField('Button', 'Extended')); % Extended
        otherwise
          obj.handleEvent(src, evt);
      end
      
      %
      %disp(evt);
      % disp(obj.Object.SelectionType);
    end
    
    function onClick(obj, src, evt)
      disp(evt);
    end
    
    function onDoubleClick(obj, src, evt)
      disp(evt);
    end
    
    function onKeyPress(obj, src, evt)
      obj.AltKeyDown          = any(strcmp('alt',     evt.Modifier));
      obj.ControlKeyDown      = any(strcmp('control', evt.Modifier));
      obj.ShiftKeyDown        = any(strcmp('shift',   evt.Modifier));
      obj.MetaKeyDown         = any(strcmp('command', evt.Modifier));               % any(strcmp('meta',    evt.Modifier))
      
      try
        switch evt.Character
          case 'i'
            if isequal({'COMMAND'}, sort(upper(evt.Modifier)))
              obj.inspect();
            elseif isequal({'COMMAND', 'SHIFT'}, sort(upper(evt.Modifier)))
              obj.inspectHandle();
            end
            return;
        end
        
      catch err
        debugStamp(err, 1, obj);
      end
      
      Grasppe.Prototypes.Utilities.StampEvent(obj, struct('Name', evt.Key), evt);
      
      obj.GestureComponent.setVisible(obj.AltKeyDown);
    end
    
    function onKeyRelease(obj, src, evt)
      if strcmp('alt',      evt.Key), obj.AltKeyDown      = false; end
      if strcmp('control',  evt.Key), obj.ControlKeyDown  = false; end
      if strcmp('shift',    evt.Key), obj.ShiftKeyDown    = false; end
      if strcmp('command',  evt.Key), obj.MetaKeyDown     = false; end
      
      Grasppe.Prototypes.Utilities.StampEvent(obj, struct('Name', evt.Key), evt);
      
      obj.GestureComponent.setVisible(obj.AltKeyDown);
    end
    
    function onWindowScrollWheel(obj, src, evt)
      obj.GestureComponent.setVisible(true);
      
      GrasppeKit.DelayedCall(@(s, e)obj.GestureComponent.setVisible(false), 1,'start');
      
      %       persistent lastSwipe lastScroll;
      %
      %       scrollCount             = abs(evt.VerticalScrollCount); % scrollSign = sign(scrollCount);
      %
      %       switch(sign(scrollCount)) %(scrollSign)
      %         case 1
      %           scrollDirection     = Grasppe.Enumerations.GestureDirection.Up;
      %         case 0
      %           scrollDirection     = Grasppe.Enumerations.GestureDirection.Fixed;
      %         case -1
      %           scrollDirection     = Grasppe.Enumerations.GestureDirection.Down;
      %       end
      %
      %       scrollMultiplier        = evt.VerticalScrollAmount;
      %
      %       evt.addField('Magnitude', scrollCount);
      %       evt.addField('Direction', scrollDirection);
      %       evt.addField('Multipier', scrollMultiplier);
      %
      %       % if scrollCount < 3, return; end
      %
      %       if isequal(obj.AltKeyDown, true)
      %         if scrollCount < 5,                                         return; end
      %         if ~isempty(lastSwipe)  && now-lastSwipe  < 0.35/60/60/24,  return; end
      %         if ~isempty(lastScroll) && now-lastScroll < 1.0/60/60/24,   return; end
      %
      %         lastSwipe             = now; %
      %         obj.notify('Swipe',   evt);
      %
      %       else
      %         if scrollCount < 3,                                         return; end
      %         if ~isempty(lastSwipe)  && now-lastSwipe  < 1.0/60/60/24,   return; end
      %
      %         obj.notify('Scroll',  evt);
      %
      %         lastScroll            = now;
      %       end
    end
    
    
    function delete(obj)
      try delete(obj.Object); end     % Closes figure
    end
    
    function showFigure(obj)
      try obj.Visible = true; end
    end
    
    function hideFigure(obj)
      try obj.Visible = false; end
    end
    
    
  end
  
  methods(Static, Hidden)
    obj                     = testFigureObject(hObject);
    
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
    
    function handleFigureMouseEvent(obj, evt)
      currentPosition         = obj.Object.CurrentPoint;
      currentObject           = hittest(obj.Object);
      
    end
    
    function inspectHandle(obj)
      try
        inspect(obj.Object.CurrentObject);
      catch err
        obj.inspect();
      end
    end
    
  end
  
end
