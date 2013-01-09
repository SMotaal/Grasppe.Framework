function targetHandle = getTargetAxesHandle(obj, targetObject)
  %GETTARGETAXESHANDLE Find Selected Figure Axes Component
  %   Detailed explanation goes here
  
  
  targetHandle = obj.Object.CurrentAxes;
  
  while(isa(targetObject, 'Grasppe.Prototypes.HandleGraphicsComponen') && ...
      any(strcmp(targetObject.ObjectType, {'axes', 'root', 'figure'})))
    
    targetObject = targetObject.ParentComponent;
  end
  
  if isa(targetObject, 'Grasppe.Prototypes.HandleGraphicsComponen')
    targetHandle  = handle(targetObject.Object);
  end
  
end
