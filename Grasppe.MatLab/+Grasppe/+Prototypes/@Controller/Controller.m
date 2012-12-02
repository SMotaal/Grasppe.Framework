classdef Controller < Grasppe.Prototypes.Component
  %CONTROLLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj=Controller(varargin)
      obj@Grasppe.Prototypes.Component(varargin{:});
    end
    
    function setModel(obj, model)
      if isequal(model, obj.Model), return; end
      
      try delete(obj.Model); end
      
      obj.privateSet('Model', model);
    end
    
    function setView(obj, view)
      if isequal(view, obj.View), return; end
      
      try delete(obj.View); end
      
      obj.privateSet('View', view);
    end
  end
  
end

