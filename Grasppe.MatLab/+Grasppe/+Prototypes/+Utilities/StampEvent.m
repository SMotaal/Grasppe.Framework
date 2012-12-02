function StampEvent(obj, src, evt)
  %STAMPEVENT Print Event Stamp fto Console
  %   Detailed explanation goes here
  
  dbTag               = 'NotifyEvent';
  try dbTag           = ['Grasppe' ':' evt.EventName]; end
  try dbTag           = [dbTag ':' evt.AffectedObject.ID]; end
  try dbTag           = [dbTag ':' src.Name]; end
  
  debugStamp( dbTag, 1, obj );
  
  return;
  
end
