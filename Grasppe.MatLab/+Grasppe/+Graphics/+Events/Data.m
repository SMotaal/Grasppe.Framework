classdef Data < Grasppe.Prototypes.Events.Data
  %EVENTDATA Grasppe Graphics Superclass
  %   Detailed explanation goes here
  
  methods
    function data = Data(varargin) %, varargin)
      data = data@Grasppe.Prototypes.Events.Data(varargin{:});
    end
  end
  
  methods(Static)
    function data = CreateData(eventType, sourceData, varargin)
      data    = feval(mfilename('class'), eventType, sourceData, varargin{:});
    end
    
    function data = DataFactory(eventType, sourceData, varargin)
      data    = Grasppe.Prototypes.Events.Data.DataFactory(eventType, sourceData, varargin);
    end
  end
  
end

