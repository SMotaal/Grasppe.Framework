function createDynamicProperties(obj)
  %CREATEDYNAMICPROPERTIES Summary of this function goes here
  %   Detailed explanation goes here
  
  
  if ~isempty(obj.HandleProperties), return; end
  
  object                = handle(obj.Object);
  classSchema           = classhandle(object);
  classProperties       = classSchema.Properties;
  
  for m = 1:numel(classProperties)
    try
      if isscalar(regexp(classSchema.Properties(m).Name, 'Fcn$'))
        obj.createCallbackFunction(classSchema.Properties(m));
      else
        dynamicProperty               = obj.createDynamicProperty(classSchema.Properties(m));
        
        if isempty(obj.HandleProperties)
          obj.HandleProperties        = dynamicProperty;
        else
          obj.HandleProperties(end+1) = dynamicProperty;
        end
        
      end
    catch err
      debugStamp(err, 1, obj)
    end
  end
  
end
