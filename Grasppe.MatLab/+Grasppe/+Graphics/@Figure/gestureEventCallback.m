function gestureEventCallback(obj, src, evt)
  %GESTUREEVENTCALLBACK Java Gesture Component Event Handling
  %   Detailed explanation goes here
  
  e                               = [];
  try e                           = evt.SourceData.Data.Data; end
  
  direction                       = [];
  try direction                   = evt.SourceData.Data.Metadata; end
  try evt.addField('Direction', direction); end
  
  currentObject                   = [];
  
  
  try obj.Object.CurrentAxes      = overobj('axes'); end
  try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(obj.Object.CurrentAxes);  end; end  
  try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(hittest(obj.Object)); end; end
  try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(obj.Object.CurrentObject);  end; end
  
  try evt.addField('TargetObject', currentObject); end
  
  switch(evt.EventType)
    case 'Click'
      obj.dispatchClick(e.getButton());
    case 'Double Click'
      obj.dispatchClick(e.getButton(), 2);
    case 'Hover'
      %       if obj.GestureComponent.isVisible
      %         obj.GestureComponent.setVisible(false);
      %         try if isempty(currentObject) || isequal(currentObject, obj), currentObject = obj.getComponentFromHandle(overobj('axes')); end; end
      %         obj.GestureComponent.setVisible(true);
      %       end
      if ~obj.AltKeyDown, obj.GestureComponent.setVisible(false); end
    case{'Scroll Up', 'Scroll Down', 'Scroll Left', 'Scroll Right'}
      evt.addField('Amount', round(e.getWheelRotation()));
      obj.notify('Scroll', evt);
    case{'Swipe Up', 'Swipe Down', 'Swipe Left', 'Swipe Right'}
      if obj.AltKeyDown, return; end
      obj.notify('Swipe', evt);
    case{'Zoom In', 'Zoom Out'}
      if ~obj.AltKeyDown; obj.GestureComponent.setVisible(false); return; end
      evt.addField('Scale', double(e.getMagnification()));
      obj.notify('Zoom', evt);
    case{'Rotate'};
      if ~obj.AltKeyDown; obj.GestureComponent.setVisible(false); return; end
      evt.addField('Angle', double(e.getRotation()));
      obj.notify('Rotate', evt);
  end
end
