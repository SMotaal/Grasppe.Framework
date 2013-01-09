function onZoom(obj, src, evt)
  %ONZOOM Figure Zoom Event Handling
  %   Detailed explanation goes here
  
  newScale = 0;
  
  if evt.Scale > 0
    newScale = 1 + evt.Scale * 2;
  elseif evt.Scale < 0
    newScale = 1 - abs(evt.Scale) * 2;
  end
  
  try
    
    % if ishandle(targetHandle)
    camzoom(obj.getTargetAxesHandle(evt.TargetObject), newScale);
    return;
    %end
  end
  
  dispf('%s: %f\t\t%s', evt.EventType, newScale, char(evt.Direction));
end
