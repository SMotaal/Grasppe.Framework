classdef ColorMaps
  %COLORMAP Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Constant)
    %% Options
    STEPS   = 64;
    
    %% Maps
    HEATMAP = [1 1 0; 1 0 0];
  end
  
  methods (Access=private)
    function obj = ColorMaps()
    end
  end
  
  methods (Static)
    %% Standard Maps
    % function map = HeatMap(steps)
    %   if nargin<1, steps = GrasppeAlpha.Kit.ColorMaps.STEPS; end
    %   map = GrasppeAlpha.Kit.ColorMaps.Interpolate(GrasppeAlpha.Kit.ColorMaps.HEATMAP, steps);
    % end
    
    %% Functions
    function map = Generate(map, steps)
      if nargin<2, steps = GrasppeAlpha.Kit.ColorMaps.STEPS; end
      
      if isa(map, 'char')
        try
          map = GrasppeAlpha.Kit.ColorMaps.(upper(map));
        catch err
          rethrow(err);
        end
      end
      
      map = GrasppeAlpha.Kit.ColorMaps.Interpolate(map, steps);
    end
    
    function map = Interpolate( map, steps )
      
      if nargin<2, steps = GrasppeAlpha.Kit.ColorMaps.STEPS; end
      
      [cX cY] = meshgrid(1:3,1:steps);
            
      n=(size(map,1));
      
      map = interp2(1:3, (0:1/(n-1):1)*(steps-1) + 1, map,cX,cY);
    end
  end
  
end

