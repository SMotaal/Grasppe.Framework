classdef PlotComponent < Grasppe.Graphics.InAxesComponent ...
    & Grasppe.Core.DecoratedComponent & Grasppe.Core.EventHandler
  % & Grasppe.Core.DecoratedComponent & Grasppe.Core.EventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
  end
  
  properties (Dependent)
  end
  
  
  methods
    function obj = PlotComponent(parentAxes, varargin)
      %try parentAxes.clearAxes; end
      obj = obj@Grasppe.Core.DecoratedComponent();
      % obj = obj@Grasppe.Core.EventHandler();
      obj = obj@Grasppe.Graphics.InAxesComponent(varargin{:},'ParentAxes', parentAxes);
    end
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.createComponent@Grasppe.Graphics.InAxesComponent;
    end
    
    function dataSet(obj, property, value)
      try
        if isequal(lower(value), 'auto')
          obj.handleSet([property 'Mode'], 'auto');
          return;
        end
      end
      try
        if ischar(value)
          obj.handleSet([property 'Source'], value);
          return;
        end
      end
      if isnumeric(value)
        obj.handleSet(property, value);
        return;
      end
      try debugStamp(obj.ID);
        dispf('Could not set %s for %s', property, obj.ID);
      end
    end
    
    function value = dataGet(obj, property)
      try
        value  = obj.handleGet([property 'Source']);
        if ischar(value) && ~isempty(value)
          return;
        end
      end
      try
        value  = obj.handleGet([property 'Mode']);
        if isequal(lower(value), 'auto')
          return;
        end
      end
      value = obj.handleGet(property);
    end    
  end
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  %   methods(Abstract, Static, Hidden)
  %     options  = DefaultOptions()
  %     obj = Create()
  %   end
  
  
end

