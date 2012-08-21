function [ a ] = flat( a )
  %FLAT Reshape to a one dimension
  
  a = reshape(a, 1, []);  %   a = a(:);
end

