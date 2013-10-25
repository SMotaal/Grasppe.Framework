classdef Singleton < handle
  %SINGLETON Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Names = struct;
  end
  
  methods (Access=private)
    function obj = Singleton()
    end
  end
  
  methods (Static)
    function instance = Get()
      persistent Instance;
      if ~isa(Instance, eval(NS.CLASS)) || ~isvalid(Instance)
        Instance = eval(eval(NS.CLASS));
      end
      instance = Instance;
    end
  end
  
end

