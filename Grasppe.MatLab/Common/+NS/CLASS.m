function [ command ] = CLASS()
  %CLASS returns command for eval
  
%   global GetClass 
%   GetClass = @()evalin('caller',Class);
  
  command = 'mfilename(''class'')';
end

