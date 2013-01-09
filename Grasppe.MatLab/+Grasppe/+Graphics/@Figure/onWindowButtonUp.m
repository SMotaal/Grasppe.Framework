function onWindowButtonUp(obj, src, evt)
  %ONWINDOWBUTTONUP Figure Button Up Event Handling
  %   Detailed explanation goes here
  
  persistent clickTimer lastButton;
  
  try stop(clickTimer);   end;
  
  switch(lower(obj.Object.SelectionType))
    case 'normal'     % Click left mouse button
      try delete(clickTimer); end;
      clickTimer = GrasppeKit.Utilities.DelayedCall(@(s, e)obj.notify('Click', evt.addField('Button', 'Primary')), 0.20,'start');
      lastButton = 1;
    case 'open'       % Double-click any mouse button
      if ~isequal(lastButton, 1)
        obj.notify('Click', evt.addField('Button', 'Primary'));
      else
        obj.notify('DoubleClick', evt.addField('Button', 'Primary'));
      end
      lastButton = 1;
    case 'alt'        % Control-click left mouse button or click right mouse button
      lastButton = 2;
      obj.notify('Click', evt.addField('Button', 'Secondary')); % Alternate
    case 'extend'     % Shift - click left mouse button or click middle (or both left and right mouse buttons on Windows)
      lastButton = 3;
      obj.notify('Click', evt.addField('Button', 'Extended')); % Extended
    otherwise
      obj.handleEvent(src, evt);
  end

end
