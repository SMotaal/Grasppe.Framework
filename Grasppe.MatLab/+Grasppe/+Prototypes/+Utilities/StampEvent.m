function StampEvent(obj, src, evt)
  %STAMPEVENT Print Event Stamp fto Console
  %   Detailed explanation goes here
  
  dbTag                               = 'NotifyEvent';
  try dbTag                           = ['Grasppe' ':' evt.EventName]; end
  try dbTag                           = [dbTag ':' evt.AffectedObject.InstanceID]; end
  
  try if isfield(src, 'Name'), dbTag  = [dbTag ':' src.Name]; end; end
  
  debugStamp( dbTag, 2, obj );
  
  return;
  
end
