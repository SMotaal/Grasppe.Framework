function panAxes(obj, plotAxes, panXY, panAmount)
  %PANAXES Relative Axes Panning
  %   Detailed explanation goes here
  
  if isempty(plotAxes), return; end
  
  lastPanXY             = [];
  
  panStickyThreshold    = 3;
  panStickyAngle        = 45/2;
  panWidthReference     = 600;
  
  deltaPanXY            = panXY;
  position              = obj.Object.Position;
  panFactor             = position([3 4])./panWidthReference;
  deltaPanXY            = round(deltaPanXY ./ (panFactor));
  
  try
    
    if isa(plotAxes, 'Grasppe.Graphics.GraphicsHandle')
      plotAxes            = plotAxes.Object;
    end
    
    newView             = plotAxes.View - deltaPanXY;
    
    if newView(2) < 0
      newView(2)        = 0;
    elseif newView(2) > 90
      newView(2)        = 90;
    end
    
    if panStickyAngle-mod(newView(1), panStickyAngle)<panStickyThreshold || ...
        mod(newView(1), panStickyAngle)<panStickyThreshold
      newView(1)        = round(newView(1)/panStickyAngle)*panStickyAngle;
    end
    if panStickyAngle-mod(newView(2), panStickyAngle)<panStickyThreshold || ...
        mod(newView(2), panStickyAngle)<panStickyThreshold
      newView(2)        = round(newView(2)/panStickyAngle)*panStickyAngle; % - mod(newView(2), 90)
    end
    
    if ~isempty(newView) && isnumeric(newView) && all(~isnan(newView)) && all(~isinf(newView))
      plotAxes.View     = newView;
    end
    
  catch err
    warning('Grasppe:MouseEvents:PanningFailed', err.message);
  end
  
end
