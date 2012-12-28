function callback = createCallbackFunction( obj, schemaProperty )
  %CREATECALLBACKFUNCTION Summary of this function goes here
  %   Detailed explanation goes here
  
  propertyName                        = schemaProperty.Name;
  eventName                           = regexprep(propertyName, 'Fcn$', '');
  callback                            = struct;
  
  try
    callback.(eventName).Name         = eventName;
    callback.(eventName).Property     = schemaProperty;
    callback.(eventName).DefaultValue = obj.Object.(propertyName);
    
    evt.EventName                     = eventName;
    evt.AffectedObject                = obj;
    src                               = obj.Object;
    
    obj.Object.(propertyName)         = @(s, e)obj.handleHandleEvent(src, evt, e); %src, evt);
  end
  
  obj.HandleFunctions.(eventName)     = callback;
end

