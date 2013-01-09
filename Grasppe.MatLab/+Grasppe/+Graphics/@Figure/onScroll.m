function onScroll(obj, src, evt)
  %ONSCROLL Figure Scroll Event Handling
  %   Detailed explanation goes here
  
  deltaH = 0;
  deltaV = 0;
  
  switch (lower(char(evt.Direction)))
    case 'left'
      deltaH = -1;
    case 'right'
      deltaH = 1;
    case 'up'
      deltaV = 1;
    case 'down'
      deltaV = -1;
    otherwise
      return;
  end
  
  amount = 2*log(evt.Amount); %max(1, round(mod(evt.Amount, 10))); % /10
  
  if obj.AltKeyDown
    if obj.MetaKeyDown
      try
        camzoom(obj.getTargetAxesHandle(evt.TargetObject), 1);
        campan(deltaH* amount, deltaV);
      end
    else
      % try
      %   disp(evt.TargetObject.InstanceID);
      % catch err
      %   disp(evt.TargetObject);
      % end
      % try disp(hittest(obj.Object)); end
      obj.panAxes(handle(evt.TargetObject), [deltaH deltaV]  * amount, 1);
    end
  end
end
