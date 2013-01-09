function onKeyRelease(obj, src, evt)
  %ONKEYRELEASE Figure Key Release Event Handling
  %   Detailed explanation goes here
  
  if strcmp('alt',      evt.Key), obj.AltKeyDown      = false; end
  if strcmp('control',  evt.Key), obj.ControlKeyDown  = false; end
  if strcmp('shift',    evt.Key), obj.ShiftKeyDown    = false; end
  if strcmp('command',  evt.Key), obj.MetaKeyDown     = false; end
  
  Grasppe.Prototypes.Utilities.StampEvent(obj, struct('Name', evt.Key), evt);
  
  obj.GestureComponent.setVisible(obj.AltKeyDown);
end
