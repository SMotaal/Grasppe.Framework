classdef FontDecorator < GrasppeAlpha.Core.Prototype & GrasppeAlpha.Core.PropertyDecorator
  %AXESVIEWDECORATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    DecoratingProperties = {'FontAngle', 'FontName', 'FontSize', 'FontUnits', 'FontWeight'};
  end
  
  properties (SetObservable, GetObservable)
    FontAngle, FontName, FontSize, FontUnits, FontWeight
  end
  
  methods
    function obj = FontDecorator(varargin)
      obj = obj@GrasppeAlpha.Core.Prototype;
      obj = obj@GrasppeAlpha.Core.PropertyDecorator(varargin{:});
    end
    
  end
  
  methods(Static, Hidden)
    function OPTIONS  = DefaultOptions()
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  
end

