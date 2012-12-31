classdef Surf < Grasppe.Graphics.PlotComponent % & Grasppe.Core.DecoratedComponent & Grasppe.Core.EventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'surf';
    
    SurfHandleProperties = { 'Clipping', 'DisplayName', {'AntiAliasing' 'LineSmoothing'}, ...
      'FaceColor', 'FaceAlpha', 'EdgeColor', 'EdgeAlpha', ...
      'BackFaceLighting', 'FaceLighting', 'EdgeLighting', ...
      'AmbientStrength', 'DiffuseStrength', 'SpecularStrength', 'SpecularExponent', ...
      'LineStyle', 'LineWidth', ...
      'Marker', 'MarkerEdgeColor', 'MarkerFaceColor', 'MarkerSize'};
    
    DataProperties = {'AData', 'CData', 'XData', 'YData', 'ZData'}; %, 'CData', 'AData'}; %, 'SheetID', 'CaseID', 'SetID'};    
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Clipping, DisplayName='', AntiAliasing = 'on', CDataMapping;
    AData, CData, XData, YData, ZData
    
    FaceColor, FaceAlpha, EdgeColor, EdgeAlpha
    BackFaceLighting, FaceLighting, EdgeLighting
    AmbientStrength, DiffuseStrength, SpecularStrength, SpecularExponent, SpecularColorReflectance
    
    LineStyle, LineWidth
    Marker, MarkerEdgeColor, MarkerFaceColor, MarkerSize
  end
  
  properties (Dependent)
  end
  
  methods (Hidden)
    function OnMouseClick(obj, source, event)
      % dispf('%s => %s:%s [%s]', source.ID, obj.ID, event.Name, ...
      %  toString( event.Data.CurrentXY ));
    end
    
    function OnMouseDoubleClick(obj, source, event)
      % dispf('%s => %s:%s [%s]', source.ID, obj.ID, event.Name, ...
      %  toString( event.Data.CurrentXY ));
      obj.OnMouseDoubleClick@Grasppe.Graphics.PlotComponent(source, event);
    end    
    
    function OnMousePan(obj, source, event)
      % dispf('%s => %s:%s [%s]', source.ID, obj.ID, event.Name, ...
      %   toString( event.Data.Panning ));
      
%       obj.ParentAxes.panAxes(event.Data.Panning.Current, event.Data.Panning.Length)
%       consumed = true;
%       disp(WorkspaceVariables);
    end        
  end
  
  
  methods
    function obj = Surf(parentAxes, varargin)
      obj = obj@Grasppe.Graphics.PlotComponent(parentAxes, varargin{:});
    end
    
        
    function value = get.AData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      value = obj.dataGet('AlphaData');
    end
    function set.AData(obj, value)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.dataSet('AlphaData', value);
    end
    
    function value = get.CData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      value = obj.dataGet('CData');
    end
    function set.CData(obj, value)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.dataSet('CData', value);
    end
    
    function value = get.XData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      value = obj.dataGet('XData');
    end
    function set.XData(obj, value)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.dataSet('XData', value);
    end
    
    function value = get.YData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      value = obj.dataGet('YData');
    end
    function set.YData(obj, value)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.dataSet('YData', value);
    end
    
    function value = get.ZData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      value = obj.dataGet('ZData');
    end
    function set.ZData(obj, value)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.dataSet('ZData', value);
    end   
        
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.createComponent@Grasppe.Graphics.PlotComponent;
    end
    
    function createHandleObject(obj)
      obj.Handle = surf(obj.ParentAxes.Handle);
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

