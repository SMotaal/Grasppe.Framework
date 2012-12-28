function components = getChildComponents(obj)
  %GETCHILDCOMPONENTS Summary of this function goes here
  %   Detailed explanation goes here
  
  try
    components          = [];
    
    if ~ishandle(obj.Object), return; end
    
    children            = obj.Object.Children;
    components          = Grasppe.Prototypes.HandleGraphicsComponent.empty;
    
    for m = 1:numel(children)
      child           = handle(children(m));
      component       = getappdata(child, 'HandleComponent');
      
      if isempty(component) || ~isa(component, 'Grasppe.Prototypes.HandleGraphicsComponent')
        childType     = get(child, 'Type');
        component     = Grasppe.Prototypes.HandleGraphicsComponent.CreateComponentFromObject(child, obj);
      end
      
      if isa(component, 'Grasppe.Prototypes.HandleGraphicsComponent')
        components(end+1) = component;
      end
    end
  catch err
    debugStamp(err,1,obj);
    return;
  end
end
