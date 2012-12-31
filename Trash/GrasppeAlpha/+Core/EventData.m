classdef EventData < event.EventData
  %EVENTDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Name
    SourceHandle
    SourceFigure    
    TimeStamp
    Consumed      = false;
    Data
  end
  
  methods
    function obj = EventData(name, data)
      obj.TimeStamp     = now();
      try obj.Data      = data; end
      try obj.Name      = name; end
    end
    
  end
  
end

