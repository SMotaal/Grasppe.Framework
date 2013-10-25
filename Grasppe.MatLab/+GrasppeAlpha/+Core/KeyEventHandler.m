classdef KeyEventHandler < GrasppeAlpha.Core.Prototype & GrasppeAlpha.Core.EventHandler
  %KEYEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    KeyEventHandlers
    LastKeyEvent
    KeyPressEvents = 0;
  end
  
  properties (Hidden=true)
    IsAltDown
    IsControlDown
    IsCommandDown
    IsShiftDown
  end
  
  events
    KeyPress
    KeyRelease
  end
  
  methods
    
    function registerKeyEventHandler(obj, handler)
      obj.registerEventHandler('KeyEventHandlers', handler);
    end
    
    function consumed = OnKeyPress(obj, source, event)
      % disp (['KeyPress for ' obj.ID]);
      if obj.KeyPressEvents >5
        return;
      end
      obj.KeyPressEvents = obj.KeyPressEvents + 1;
      consumed = obj.callEventHandlers('Key', 'KeyPress', source, event);
      obj.KeyPressEvents = obj.KeyPressEvents - 1;
    end
    
    function consumed = OnKeyRelease(obj, source, event)
      % disp (['KeyRelease for ' obj.ID]);
      consumed = obj.callEventHandlers('Key', 'KeyRelease', source, event);
    end
    
  end
  
end

