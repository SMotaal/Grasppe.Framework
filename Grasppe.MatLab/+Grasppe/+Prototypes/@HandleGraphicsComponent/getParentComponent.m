function component = getParentComponent(obj)
  %GETPARENTCOMPONENT Summary of this function goes here
  %   Detailed explanation goes here
  
  component = [];
  
  if isa(obj.Object, 'root'), return; end
  try
    parent              = handle(obj.Object.Parent);
    component           = getappdata(parent, 'HandleComponent');
    
    if isempty(component) || ~isa(component, 'Grasppe.Prototypes.HandleGraphicsComponent')
      parentType        = get(parent, 'Type');
      component         = Grasppe.Prototypes.HandleGraphicsComponent.ComponentFactory(parent, []);
    end
    
  catch err
    debugStamp(err,1,obj);
    return;
  end
end
