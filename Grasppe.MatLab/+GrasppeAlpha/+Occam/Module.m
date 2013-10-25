classdef Module < GrasppeAlpha.Occam.Process
  %PATCHGENERATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    View
    Processor
  end
  
  methods (Abstract)
    CreateView(obj)
    CreateProcessor(obj)
  end
  
  methods
    function obj = Module()
      obj = obj@GrasppeAlpha.Occam.Process();
      obj.Initialize;
    end
    
    function Initialize(obj)
      try
        if ~isobject(obj.Processor) || ~isvalid(obj.Processor), obj.CreateProcessor; end      
        if ~isobject(obj.View) || ~isvalid(obj.View), obj.CreateView; end
        addProcess(obj.View);
        addProcess(obj.Process);
      end
    end
    
  end
  
end

