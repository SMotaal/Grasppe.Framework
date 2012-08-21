function [ args ] = structArgs( argStruct )
  %STRUCTARGS Summary of this function goes here
  %   Detailed explanation goes here
  
  args = {};
    
  [names values nPairs] = structPair(argStruct);
  
  nArgs = nPairs*2;
  
  if nPairs>0
    args = cell(1,nArgs);
    
    args(1:2:end) = names(:);
    args(2:2:end) = values(:);
  end
  
end

