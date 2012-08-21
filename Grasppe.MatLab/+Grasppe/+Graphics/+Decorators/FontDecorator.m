classdef FontDecorator < Grasppe.Core.Prototype & Grasppe.Core.PropertyDecorator
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
      obj = obj@Grasppe.Core.Prototype;
      obj = obj@Grasppe.Core.PropertyDecorator(varargin{:});
    end
    
  end
  
  methods(Static, Hidden)
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

