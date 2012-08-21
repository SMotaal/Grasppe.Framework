function [ str ] = flatcat( c )
  %FLATCAT Cat cell strings
  %   Detailed explanation goes here
  
  str = horzcat(c{:});
  
end

