classdef ColorMapAxes < GrasppeAlpha.Graphics.Axes
  %OVERLAYAXES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Map;
    Peers;
    BarHandle;
    Orientation;
  end
  
  properties (Dependent)
    Steps
  end
  
  methods
    
    function obj = ColorMapAxes(varargin)
      obj = obj@GrasppeAlpha.Graphics.Axes(varargin{:});
    end
    
    function addPeer(obj, peer, limits)
      
      if ~isa(peer, 'GrasppeAlpha.Graphics.PlotAxes'), return; end
      if nargin<2, limits = peer.ZLim; end
      
      peerID = peer.ID;
      
      if ~obj.Peers.isKey(peerID) || ~isValid(obj.Peers(peerID))
        obj.Peers(peerID) = peer;
      end
      
    end
    
    function updateColorBar(obj)
      
      steps = obj.Steps;
      
      [x,y] = meshgrid(0:steps, 0:1);
      
      z = [1 1]' * [1:steps+1];
      
      obj.BarHandle = pcolor(obj.Handle, x, y, z);
      % obj.ParentFigure
    end
    
    function updateColorAxes(obj)
      
    end

  end
  
  methods
    function steps = get.Steps(obj)
      steps = 0;
      
      try steps = size(obj.Map,1); end
    end
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = false;
      Box           = 'on';
      Units         = 'normalized';
      Color         = 'none';
      
      Layer         = 'top';
      Projection    = 'orthographic';
      
      Orientation   = 'horizontal';
            
      Map           = GrasppeAlpha.Kit.ColorMaps.Generate('heatmap');
      Peers         = containers.Map;
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end    
  end
  
  
end

