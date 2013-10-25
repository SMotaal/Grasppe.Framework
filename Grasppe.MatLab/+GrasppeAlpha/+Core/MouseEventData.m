classdef MouseEventData < event.EventData
  %MOUSEEVENTDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    Type
    SourceHandle
    SourceFigure    
    Timestamp
    GlobalLocation
    ObjectLocation
    FigureLocation
    SelectionType
    Consumed = false;
    PanVector;
  end
  
  methods
    function obj = MouseEventData(type, source)
      obj.Timestamp       = time();
      obj.GlobalLocation  = get(0, 'PointerLocation');      
      obj.Type            = type;
      obj.SourceHandle    = GrasppeAlpha.Core.MouseEventData.GetHandle(obj.Source);
      obj.SourceFigure    = GrasppeAlpha.Core.MouseEventData.GetFigureHandle(obj.SourceHandle);
      
      try obj.ObjectLocation  = get(obj.SourceHandle, 'CurrentPoint'); end
      try obj.FigureLocation  = get(obj.SourceFigure, 'CurrentPoint'); end
      try obj.SelectionType   = get(obj.SourceFigure, 'SelectionType'); end
    end
    
  end
  
  methods(Static)
    function handle = GetHandle(handle)
      try
        if ishandle(handle)
          return;
        elseif isobject(handle) && ishandle(handle.Handle)
          handle = handle.Handle;
          return;
        end
      end
      handle = [];
    end
    
    function handle = GetFigureHandle(handle)
      try
        handle = ancestor(handle, 'figure');
        return;
      end
      handle = [];
    end
  end
  
end

