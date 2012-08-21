classdef MouseEventHandler < Grasppe.Core.Prototype & Grasppe.Core.EventHandler
  %KEYEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MouseEventHandlers
    % MousePressEvents = 0;
  end
  
  properties
  end
  
  events
    MouseDown
    MouseUp
    MouseMotion
    MouseWheel
    
    MouseClick
    MouseDoubleClick
    MousePan
    MouseScroll
  end
  
  methods (Hidden)
    
    function OnMouseDown(obj, source, event)
    end

    function OnMouseUp(obj, source, event)
    end
    
    function OnMouseMotion(obj, source, event)
    end
    
    function OnMouseWheel(obj, source, event)
    end
    
    
    function OnMouseClick(obj, source, event)
    end
    
    function OnMouseDoubleClick(obj, source, event)
    end
    
    function OnMousePan(obj, source, event)
    end
    
    function OnMouseScroll(obj, source, event)
    end
    
%     function OnMouse(obj, source, event)
%     end
%     

  end
  
  methods
    
    function obj = MouseEventHandler()
      obj = obj@Grasppe.Core.EventHandler;
      obj.attachMouseEvents;
    end
    
    function attachMouseEvents(obj)
      events = {'MouseDown', 'MouseUp', 'MouseMotion', 'MouseWheel'};
      for m = 1:numel(events)
        obj.addlistener(events{m}, @obj.triggerMouseEvent);
      end
    end
    
    function registerMouseEventHandler(obj, handler)
      obj.registerEventHandler('MouseEventHandlers', handler);
    end
    
    function triggerMouseEvent(obj, source, event, eventName)
      try if nargin<4, eventName = event.EventName; end; end
      try obj.processMouseEvent(source, eventName, event); end
    end
    
    
    function processMouseEvent(obj, source, type, event)
      persistent lastDownTic lastUpTic ...
        lastDownID lastUpID ...
        lastDownXY clickTimer ...
        lastPanTic lastScrollSwipeTic  ...
        fireClickTimer lastMouseStateHandle MouseButtonState;
      
      doubleClickRate     = 0.2;
      
      scrollingThreshold  = 0;
      
      currentXY           = get(0,'PointerLocation');
      
      lastDownDeltaXY     = [0 0];
      try lastDownDeltaXY = currentXY - lastDownXY; end
      
      lastDownToc         = 0;
      try lastDownToc     = toc(lastDownTic); end
      
      lastUpToc           = 0;
      try lastUpToc       = toc(lastUpTic); end
      
      lastDownSameID      = false;
      try lastDownSameID  = isequal(lastDownID, obj.ID); end
      
      lastUpSameID        = false;
      try lastUpSameID    = isequal(lastUpID, obj.ID); end
      
      
      if isempty(fireClickTimer) || ~isvalid(fireClickTimer)
        fireClickTimer = timer( 'StartDelay', doubleClickRate);
      end
      
      sourceData = event.Data;
      
      eventData.Type             = type; ...
        eventData.DoubleClickRate  = doubleClickRate; ...
        eventData.CurrentXY        = currentXY; ...
        eventData.LastDownDeltaXY  = lastDownDeltaXY; ...
        eventData.LastDownToc      = lastDownToc; ...
        eventData.LastUpToc        = lastUpToc; ...
        eventData.LastDownSameID   = lastDownSameID; ...
        eventData.LastUpSameID     = lastUpSameID;
      
      event.Data = eventData;
      
      
      figureObject = [];
      try
        if isequal(obj.ComponentType,  'figure')
          figureObject = obj;
        else
          figureObject = obj.ParentFigure;
        end
      end
      
      try currentObject = get(lastMouseStateHandle, 'UserData'); end
      
      switch lower(type)
        case 'mousedown'
          MouseButtonState = 'down';
          try lastMouseStateHandle = figureObject.handleGet('CurrentObject');
          catch, lastMouseStateHandle = [], end
          
          %if isempty(lastDownTic) % || lastDownToc > 2*doubleClickRate
          lastDownTic = tic;
          %end
          
          lastDownID  = obj.ID;
          lastDownXY  = currentXY;
          
        case 'mouseup'
          
          MouseButtonState = 'up';
          lastMouseStateHandle = [];
          lastUpTic = tic;
          lastUpID  = obj.ID;
          lastUpXY  = currentXY;
          lastPanTic = [];
          
          
          try
            if isobject(currentObject) && isequal(lastDownXY, lastUpXY)
              selectionType = figureObject.handleGet('SelectionType');
              if isequal(selectionType, 'normal')
                event.Name = 'MouseClick';
                
                clickFunction = {@Grasppe.Core.EventHandler.callbackEvent, obj, event.Name, currentObject, event};
                
                if isempty(clickTimer) || ~isvalid(clickTimer)
                  clickTimer = timer('name', 'ClickTimer', 'Period', doubleClickRate, 'StartDelay', doubleClickRate, ...
                  'TimerFcn', clickFunction);
                else
                  stop(clickTimer);
                  set(clickTimer, 'TimerFcn', clickFunction);
                end
                start(clickTimer);
              elseif isequal(selectionType, 'open') %&& lastUpToc < doubleClickRate %if lastUpToc < doubleClickRate %&& lastDownToc < doubleClickRate                
                if ~isempty(clickTimer) && isvalid(clickTimer)
                  stop(clickTimer);
                end
                event.Name = 'MouseDoubleClick';
                Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
              end
              
              
            end
          catch err
            disp(err.message);
          end
          
          
          
        case 'mousemotion'
          isPanning = true;
          try isPanning = isequal(lastMouseStateHandle, figureObject.handleGet('CurrentObject')); end
          try isPanning = isPanning && (...
              isequal(MouseButtonState, 'down') || isequal(MouseButtonState, 'dragging')); end
          if isPanning
            if isempty(lastPanTic)
              lastPanTic = tic;
              event.Data.Panning.Length  = 0;
            else
              lastPanToc = 0;
              try lastPanToc = toc(lastPanTic); end
              event.Data.Panning.Length  = lastPanToc;
            end
            event.Data.Panning.Start   = lastDownXY;
            event.Data.Panning.Current = currentXY;
            event.Data.Panning.Delta   = lastDownDeltaXY;
            
            try
              if isobject(currentObject)
                event.Name = 'MousePan';
                Grasppe.Core.EventHandler.callbackEvent(currentObject, event, figureObject, event.Name);
                Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
              end
            end
          else
            try
              if isobject(currentObject)
                event.Name = 'MouseMotion';
                Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
              end
            end
          end
        case 'mousewheel'
          lastScrollToc = 0;
          try lastScrollToc = toc(lastScrollSwipeTic); end;
          
          lastScrollSwipeTic = tic;
          
          try
            event.Data.Scrolling.Length        = lastScrollToc;
            event.Data.Scrolling.Vertical      = [sourceData.VerticalScrollCount sourceData.VerticalScrollAmount];
            event.Data.Scrolling.Momentum      = lastScrollToc < scrollingThreshold; % && lastScrollToc>1;
            % disp(event);
          catch err
            disp(err.message);
            disp(event);
            % beep;
          end
          
          
          hoverObject =[];
          
          h = hittest;
          
          switch get(h, 'Type')
            case 'axes'
              children = get(h, 'Children');
              try hoverObject = get(children(1), 'UserData'); end
            case {'surface'}
              try hoverObject = get(h, 'UserData'); end
          end
          
          try
            if isobject(hoverObject)
              event.Name = 'MouseScroll';
              Grasppe.Core.EventHandler.callbackEvent(obj, event, hoverObject, event.Name);
            end
          end
          
        otherwise
          % disp(type);
      end
      
    end
    
    
    %     function consumed = OnKeyPress(obj, source, event)
    %       disp (['KeyPress for ' obj.ID]);
    %       if obj.KeyPressEvents >5
    %         return;
    %       end
    %       obj.KeyPressEvents = obj.KeyPressEvents + 1;
    %       consumed = obj.callEventHandlers('Key', 'KeyPress', source, event);
    %       obj.KeyPressEvents = obj.KeyPressEvents - 1;
    %     end
    %
    %     function consumed = OnKeyRelease(obj, source, event)
    %       disp (['KeyRelease for ' obj.ID]);
    %       consumed = obj.callEventHandlers('Key', 'KeyRelease', source, event);
    %     end
    
  end
  
end

