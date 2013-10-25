classdef PlotAxes < GrasppeAlpha.Graphics.Axes
  %OVERLAYAXES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    PlotAxesProperties = {
      'ViewLock',     'Lock Viewpoint',   'Plot View',      'logical',     '';   ...
      };
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    ViewLock            = false;
    IsHidden            = false;
  end
  
  methods
    
    function obj = PlotAxes(varargin)
      obj = obj@GrasppeAlpha.Graphics.Axes(varargin{:});
    end
    
    function setView(obj, view, varargin)
      if nargin==2
        lock = obj.ViewLock;
        if ~lock, obj.setView@GrasppeAlpha.Graphics.Axes(view); end
      elseif nargin==3
        obj.ViewLock = varargin{1};
        obj.setView@GrasppeAlpha.Graphics.Axes(view);
      end
      
      
    end
    
  end
  
  methods % (Hidden)
    
    function OnMouseDoubleClick(obj, source, event)
      try obj.ViewLock = ~obj.ViewLock;
      catch, obj.ViewLock = false; end
    end
  end
  
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.createHandleObject@GrasppeAlpha.Graphics.Axes;
      obj.handleSet('NextPlot', 'replacechildren');
      obj.handleSet('Tag', '#PlotAxes');
    end
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      Box           = 'off';
      Units         = 'normalized';
      Position      = [0 0 1 1];
      Color         = 'none';
      
      AspectRatio   = [1 1 1];
      View          = [0 90];
      
      OuterPosition = [0.1 0.1 0.8 0.8];
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
    
  end
  
  
end

