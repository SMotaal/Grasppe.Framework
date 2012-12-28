function obj = testFigureObject(hObject)
  %TESTSCHEMAPROPERTIES Summary of this function goes here
  %   Detailed explanation goes here
      
      objectType    = 'figure';
      parent        = [];
      
      if exist('hObject', 'var') && isvalid(hObject)
        object      = handle(hObject);
      else
        v = -2.9:0.2:2.9;
        fb = figure;
        hb = bar(v,exp(-v.*v));
        object      = handle(fb); %ancestor(hb,'figure'));
      end
      
      obj           = Grasppe.Prototypes.HandleGraphicsComponent.ComponentFactory(objectType, object, parent, 'Name', 'Test Figure!');
      
      obj.inspect;
      
end

