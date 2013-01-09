function dispatchClick(obj, button, clicks)
  %DISPATCHCLICK Java Gesture Component Click Dispatcher
  %   Detailed explanation goes here
  
  if ~isjava(obj.MouseRobot), obj.MouseRobot = javaObject('java.awt.Robot'); end
  
  lastVisible = false;
  
  try
    lastVisible = obj.GestureComponent.isVisible();
    obj.GestureComponent.setVisible(false);
  end
  
  if ~exist('button', 'var') || isempty(button),  button  = 1; end
  
  if ~exist('clicks', 'var') || isempty(clicks),  clicks  = 1; end
  
  switch (button)
    case 1
      button = java.awt.event.InputEvent.BUTTON1_MASK;
  end
  
  obj.MouseRobot.setAutoDelay(1);
  
  for m = 1:clicks
    obj.MouseRobot.mousePress(button);
    obj.MouseRobot.mouseRelease(button);
    pause(0.01);
    obj.MouseRobot.waitForIdle();
  end
  
  if clicks==2, obj.Object.SelectionType = 'open'; end
  
  if lastVisible
    try obj.GestureComponent.setVisible(true); end;
  end
  
end
