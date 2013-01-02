function callback = createCallbackFunction( obj, schemaProperty, alias )
  %CREATECALLBACKFUNCTION Summary of this function goes here
  %   Detailed explanation goes here
  
  global DebugCallbackFunction;
  
  propertyName                        = schemaProperty.Name;
  eventName                           = regexprep(propertyName, 'Fcn$', '');
  callback                            = struct;
  
  if ~exist('alias', 'var'), alias = ''; end
  
  try
    callback.Name                     = eventName;
    callback.Alias                    = alias;
    callback.DefaultValue             = [];
    callback.Property                 = [];
    
    try
      callback.DefaultValue           = obj.Delegate.(propertyName);
      callback.Property               = schemaProperty;
    end
    
    if any(strcmp(alias, events(obj)))
      evt.EventName                   = alias;
    else
      evt.EventName                   = eventName;
      callback.Alias                  = '';
    end    

    evt.AffectedObject                = obj;
    src                               = obj.Object;
        
    callback.Function                 = @(s, e)obj.handleHandleEvent(src, evt, e);
    
    S                                 = warning('off', 'MATLAB:class:invalidEvent');
    try
      callback.Listener               = addlistener(obj.Object, eventName, callback.Function);
      if isequal(DebugCallbackFunction, true),
        dispf('Added listener %s to %s of class %s.', eventName, obj.InstanceID, class(obj.Object));
      end
    catch err
      obj.Object.(propertyName)       = callback.Function;
    end
    warning(S);
  catch err
    debugStamp(err, 1);
  end
  
  obj.HandleFunctions.(eventName)     = callback;
end

