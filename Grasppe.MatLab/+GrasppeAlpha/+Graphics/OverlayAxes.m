classdef OverlayAxes < GrasppeAlpha.Graphics.Axes
  %OVERLAYAXES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj = OverlayAxes(varargin)
      obj = obj@GrasppeAlpha.Graphics.Axes(varargin{:});
      obj.handleSet('Tag', '#OverlayAxes');      
    end    
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions( )
      
      IsVisible     = false;
      IsClickable   = false;
      Box           = 'off';
      Units         = 'normalized';
      Position      = [0 0 1 1];
      Color         = 'none';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
    
  end
  
  
end

