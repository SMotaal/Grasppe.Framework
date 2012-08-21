classdef EventData < event.EventData
  %EVENTDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Name
    SourceHandle
    SourceFigure    
    Timestamp
    Consumed      = false;
    Data
  end
  
  methods
    function obj = EventData(name, data)
      obj.Timestamp = time();
      try obj.Data      = data; end
      try obj.Name      = name; end
    end
    
  end
  
end

