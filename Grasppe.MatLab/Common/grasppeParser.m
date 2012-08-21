classdef grasppeParser < inputParser
  %GRASPPEPARSER Enhanced Input Parser Object
  %   Provides additonal functionality to the inputParser class, including
  %   addConditional.
  
  properties
  end
  
  methods
    function obj = addConditional(obj, varargin)
      obj = conditionalParameter(obj, varargin{:});
    end
  end
  
end

