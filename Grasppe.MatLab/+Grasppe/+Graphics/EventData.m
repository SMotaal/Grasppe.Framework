classdef EventData < Grasppe.Prototypes.EventData
  %EVENTDATA Grasppe Graphics Superclass
  %   Detailed explanation goes here
  
  methods
    function data = EventData(varargin) %, varargin)
      data = data@Grasppe.Prototypes.EventData(varargin{:});
    end
  end
  
  methods(Static)
    function data = CreateData(eventType, sourceData, varargin)
      data    = feval(mfilename('class'), eventType, sourceData, varargin{:});
    end
    
    function data = DataFactory(eventType, sourceData, varargin)
      data    = Grasppe.Prototypes.EventData.DataFactory(eventType, sourceData, varargin);
    end
  end
  
end

