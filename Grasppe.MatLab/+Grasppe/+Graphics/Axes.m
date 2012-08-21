classdef Axes < Grasppe.Graphics.InFigureComponent
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  
  properties (Transient, Hidden)
    AxesProperties = {
      'ALim',         'Alpha',            'Plot Limits',    'limits',   '';   ...
      'CLim',         'Color Map',        'Plot Limits',    'limits',   '';   ...
      'XLim',         'X',                'Plot Limits',    'limits',   '';   ...
      'YLim',         'Y',                'Plot Limits',    'limits',   '';   ...
      'ZLim',         'Z',                'Plot Limits',    'limits',   '';   ...
      ...
      'View',         'Viewpoint',        'Plot View',      'view',     '';   ...
      'Projection',   'Projection',       'Plot View',      'view',     '';   ...
      ...
      'Color',        'Axes Background',  'Plot Style',     'color',    '';   ...
      ...
      'XLable',       'X',                'Plot Labels',    'string',   '';   ...
      'YLable',       'Y',                'Plot Labels',    'string',   '';   ...
      'ZLable',       'Z',                'Plot Labels',    'string',   '';   ...      
      };
    
    AxesHandleProperties = { ...
      'Box', 'Color', 'Projection', 'Layer', ... 
      ...
      'OuterPosition', {'PositionMode', 'ActivePositionProperty'}, ...
      ...
      'XScale', 'XDir', 'XColor', 'XLabel', 'XAxisLocation', ...
      'XGrid', 'XMinorGrid', 'XMinorTick', ...
      ...
      'YScale', 'YDir', 'YColor', 'YLabel', 'YAxisLocation', ...
      'YGrid', 'YMinorGrid', 'YMinorTick', ...
      ...
      'ZScale', 'ZDir', 'ZColor', 'ZLabel', ...
      'ZGrid', 'ZMinorGrid', 'ZMinorTick', ...
      };
    
    ComponentType = 'axes';
  end
  
  
  properties (SetObservable, GetObservable, AbortSet)
    Color, Box,
    
    PositionMode, OuterPosition,
    
    Projection, Layer
        
    XScale, XDir, XColor, XLabel, XAxisLocation
    XGrid, XMinorGrid, XMinorTick
    
    YScale, YDir, YColor, YLabel, YAxisLocation
    YGrid, YMinorGrid, YMinorTick
    
    ZScale, , ZDir, ZColor, ZLabel
    ZGrid, ZMinorGrid, ZMinorTick    

  end
  
  properties (Dependent, SetObservable, GetObservable, AbortSet)
    %DataAspectRatioMode
    AspectRatio
    
    %CLimMode   ALimMode
    CLim,       ALim
    
    %XLimMode   XTickMode,  XTickLabelMode
    XLim,       XTick,      XTickLabel
    
    %YLimMode   YTickMode,  YTickLabelMode
    YLim,       YTick,      YTickLabel
    
    %ZLimMode   ZTickMode,  ZTickLabelMode
    ZLim,       ZTick,      ZTickLabel
    
    %View
    View
  end
  
  
  methods
    function obj = Axes(varargin)
      % obj = obj@Grasppe.Core.DecoratedComponent();
      % obj = obj@Grasppe.Core.EventHandler();
      obj = obj@Grasppe.Graphics.InFigureComponent(varargin{:});
      % obj = obj@Grasppe.Graphics.HandleGraphicsComponent(varargin{:});
    end
    
    
    
    %% AspectRatio / DataAspectRatio
    function set.AspectRatio(obj, value)
      obj.autoSet('DataAspectRatio', value);
    end
    
    function value=get.AspectRatio(obj)
      value = obj.autoGet('DataAspectRatio');
    end
    
    %% CLim
    function set.CLim(obj, value)
      obj.autoSet('CLim', value);
    end
    
    function value=get.CLim(obj)
      value = obj.autoGet('DataAspectRatio');
    end
    
    %% ALim
    function set.ALim(obj, value)
      obj.autoSet('ALim', value);
    end
    
    function value=get.ALim(obj)
      value = obj.autoGet('ALim');
    end
    
    %% XLim
    function set.XLim(obj, value)
      obj.autoSet('XLim', value);
    end
    
    function value=get.XLim(obj)
      value = obj.autoGet('XLim');
    end
    
    % XTick
    function set.XTick(obj, value)
      obj.autoSet('XTick', value);
    end
    
    function value=get.XTick(obj)
      value = obj.autoGet('XTick');
    end
    
    % XTickLabel
    function set.XTickLabel(obj, value)
      obj.autoSet('XTickLabel', value);
    end
    
    function value=get.XTickLabel(obj)
      value = obj.autoGet('XTickLabel');
    end
    
    %% YLim
    function set.YLim(obj, value)
      obj.autoSet('YLim', value);
    end
    
    function value=get.YLim(obj)
      value = obj.autoGet('YLim');
    end
    
    % YTick
    function set.YTick(obj, value)
      obj.autoSet('YTick', value);
    end
    
    function value=get.YTick(obj)
      value = obj.autoGet('YTick');
    end
    
    % YTickLabel
    function set.YTickLabel(obj, value)
      obj.autoSet('YTickLabel', value);
    end
    
    function value=get.YTickLabel(obj)
      value = obj.autoGet('YTickLabel');
    end
    
    %% ZLim
    function set.ZLim(obj, value)
      obj.autoSet('ZLim', value);
    end
    
    function value=get.ZLim(obj)
      value = obj.autoGet('ZLim');
    end
    
    % ZTick
    function set.ZTick(obj, value)
      obj.autoSet('ZTick', value);
    end
    
    function value=get.ZTick(obj)
      value = obj.autoGet('ZTick');
    end
    
    % ZTickLabel
    function set.ZTickLabel(obj, value)
      obj.autoSet('ZTickLabel', value);
    end
    
    function value=get.ZTickLabel(obj)
      value = obj.autoGet('ZTickLabel');
    end
    
    % View    
    function set.View(obj, value)
        obj.setView(value);
    end
    
    function value = get.View(obj)
      value = [];
      try value = obj.handleGet('View'); end
    end
    
    function setView(obj, view, varargin)
      obj.handleSet('View', view);
    end
    
  end
  
  methods (Hidden=true)
  end
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.Handle = axes; % ('Visible', 'off');
    end
    
    function decorateComponent(obj)
      % Grasppe.Graphics.Decorators.AxesViewDecorator(obj);
      Grasppe.Graphics.Decorators.FontDecorator(obj);
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

