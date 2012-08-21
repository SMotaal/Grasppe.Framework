function [meta propertyList methodList ] = metaList( metaClass )
  %METALIST Summary of this function goes here
  %   Detailed explanation goes here
  
  logicalFlag = @(v, f) (resolve(v,f,''));
  
  metaProperty = metaClass.PropertyList;  
  propertyList = {...
    metaProperty.Name; metaProperty.GetAccess; metaProperty.SetAccess; ...
    metaProperty.Dependent; metaProperty.Hidden}';
  
  metaMethod    = metaClass.MethodList;
  methodList = {metaMethod.Name};  
    
  if nargout == 0
    disp(['Properties:  ' toString({metaProperty.Name}) ]);
    disp(['Methods:     ' toString({metaMethod.Name}) ]);
  elseif nargout > 0
    meta.Properties = toString({metaProperty.Name});
    meta.Methods    = toString({metaMethod.Name});
  end
end

