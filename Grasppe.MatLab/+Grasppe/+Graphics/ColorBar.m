classdef ColorBar < Grasppe.Graphics.Axes
  %COLORBAR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ColorBarProperties = {
      %       'ALim',         'Alpha',            'Plot Limits',    'limits',   '';   ...
      %       'CLim',         'Color Map',        'Plot Limits',    'limits',   '';   ...
      %       'XLim',         'X',                'Plot Limits',    'limits',   '';   ...
      %       'YLim',         'Y',                'Plot Limits',    'limits',   '';   ...
      %       'ZLim',         'Z',                'Plot Limits',    'limits',   '';   ...
      %       ...
      %       'View',         'Viewpoint',        'Plot View',      'view',     '';   ...
      %       'Projection',   'Projection',       'Plot View',      'view',     '';   ...
      %       ...
      %       'Color',        'Axes Background',  'Plot Style',     'color',    '';   ...
      %       ...
      %       'XLable',       'X',                'Plot Labels',    'string',   '';   ...
      %       'YLable',       'Y',                'Plot Labels',    'string',   '';   ...
      %       'ZLable',       'Z',                'Plot Labels',    'string',   '';   ...
      'Location',     'Anchor'            'Color Bar',      'anchor',   ''; ...
      % 'Axes',         'Axes'              'Color Bar',      'handle',   ''; ...
      
      };
    
    ColorBarHandleProperties = { ...
      'Location' %, 'Axes'
      };
    
  end
  
  
  properties (SetObservable, GetObservable, AbortSet)
    Location
  end
  
  properties
    Axes
  end
  
  properties (Dependent)
    AxesHandle
  end
  
  methods
    function obj = ColorBar(varargin)
      obj = obj@Grasppe.Graphics.Axes(varargin{:});
    end
    
    function h = get.AxesHandle(obj)
      h = [];
      try h = obj.Axes.Handle; end;
    end
    
    
  end
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.Axes.PropertyQueing = true;
      obj.Handle = colorbar('Peer', obj.AxesHandle); %,'Location', 'manual');
      obj.Axes.PropertyQueing = false;
    end
    
  end
end

