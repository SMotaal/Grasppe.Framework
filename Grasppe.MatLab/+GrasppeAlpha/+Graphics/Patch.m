classdef Patch < GrasppeAlpha.Graphics.PlotComponent % & GrasppeAlpha.Core.DecoratedComponent & GrasppeAlpha.Core.EventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'patch';
    
    PatchHandleProperties = { 'Clipping', 'DisplayName', {'AntiAliasing' 'LineSmoothing'}, ...
      'FaceColor', 'FaceAlpha', 'EdgeColor', 'EdgeAlpha', ...
      'BackFaceLighting', 'FaceLighting', 'EdgeLighting', ...
      'AmbientStrength', 'DiffuseStrength', 'SpecularStrength', 'SpecularExponent', ...
      'LineStyle', 'LineWidth', ...
      'Marker', 'MarkerEdgeColor', 'MarkerFaceColor', 'MarkerSize'};
    
    DataProperties = {'CData', 'XData', 'YData', 'ZData'}; %'AData', , 'CData', 'AData'}; %, 'SheetID', 'CaseID', 'SetID'};    
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Clipping, DisplayName='', AntiAliasing = 'off', CDataMapping;
    CData, XData, YData, ZData %AData
    
    FaceColor, FaceAlpha, EdgeColor, EdgeAlpha
    BackFaceLighting, FaceLighting, EdgeLighting
    AmbientStrength, DiffuseStrength, SpecularStrength, SpecularExponent, SpecularColorReflectance
    
    LineStyle, LineWidth
    Marker, MarkerEdgeColor, MarkerFaceColor, MarkerSize
  end
  
  properties (Dependent)
  end
  
  methods % (Hidden)
    function OnMouseClick(obj, source, event)
      % dispf('%s => %s:%s [%s]', source.ID, obj.ID, event.Name, ...
      %  toString( event.Data.CurrentXY ));
    end
    
    function OnMouseDoubleClick(obj, source, event)
      % dispf('%s => %s:%s [%s]', source.ID, obj.ID, event.Name, ...
      %  toString( event.Data.CurrentXY ));
      obj.OnMouseDoubleClick@GrasppeAlpha.Graphics.PlotComponent(source, event);
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
    function obj = Patch(parentAxes, varargin)
      obj = obj@GrasppeAlpha.Graphics.PlotComponent(parentAxes, varargin{:});
    end
    
        
%     function value = get.AData(obj)
%       try debugStamp(obj.ID); catch, debugStamp(); end;
%       value = obj.dataGet('PrintUniformityAlpha.ata');
%     end
%     function set.AData(obj, value)
%       try debugStamp(obj.ID); catch, debugStamp(); end;
%       obj.dataSet('PrintUniformityAlpha.ata', value);
%     end
    
    function value = get.CData(obj)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      value = obj.dataGet('CData');
    end
    function set.CData(obj, value)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      obj.dataSet('CData', value);
    end
    
    function value = get.XData(obj)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      value = obj.dataGet('XData');
    end
    function set.XData(obj, value)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      obj.dataSet('XData', value);
    end
    
    function value = get.YData(obj)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      value = obj.dataGet('YData');
    end
    function set.YData(obj, value)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      obj.dataSet('YData', value);
    end
    
    function value = get.ZData(obj)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      value = obj.dataGet('ZData');
    end
    function set.ZData(obj, value)
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      obj.dataSet('ZData', value);
    end   
        
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.createComponent@GrasppeAlpha.Graphics.PlotComponent;
    end
    
    function createHandleObject(obj)
      obj.Handle = patch(0,0,0,'Parent', obj.ParentAxes.Handle); %patch('Parent',obj.ParentAxes.Handle);
    end
  end
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  %   methods(Abstract, Static, Hidden)
  %     options  = DefaultOptions()
  %     obj = Create()
  %   end
  
  
end

