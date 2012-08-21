function [ check level ] = isSuper( super, subclass )
  %ISSUPER Verify class inheritance relation
  
  if ~validCheck(subclass, 'char')
    subclass = class(subclass);
  end
  
  level = find(strcmp(super,superclasses(subclass)));
  check = ~isempty(level);
  
end

