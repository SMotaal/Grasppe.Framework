function components = getChildComponents(obj)
  %GETCHILDCOMPONENTS Summary of this function goes here
  %   Detailed explanation goes here
  
  try
    components          = [];
    
    if ~ishandle(obj.Object), return; end
    
    children            = obj.Object.Children;
    components          = Grasppe.Graphics.GraphicsHandle.empty;
    
    for m = 1:numel(children)
      child           = handle(children(m));
      component       = getappdata(child, 'HandleComponent');
      
      if isempty(component) || ~isa(component, 'Grasppe.Graphics.GraphicsHandle')
        childType     = get(child, 'Type');
        component     = Grasppe.Graphics.GraphicsHandle.CreateComponentFromObject(child, obj);
      end
      
      if isa(component, 'Grasppe.Graphics.GraphicsHandle')
        components(end+1) = component;
      end
    end
  catch err
    debugStamp(err,1,obj);
    return;
  end
end
