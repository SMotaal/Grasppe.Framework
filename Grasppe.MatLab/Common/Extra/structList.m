function [ c ] = structList( s )
  %STRUCTLIST Convert fields and values to cell pairs
  %   Detailed explanation goes here
    
  f = fieldnames(s);
  c = cell(size(f)); %1, numel(f));
    
  c(:) = strcat(f ,':', {' '}, struct2cell(s));
end

