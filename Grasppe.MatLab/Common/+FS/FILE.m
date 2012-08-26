function [ command ] = FILE()
  %FILE returns command for eval
  
%   global GetClass 
%   GetClass = @()evalin('caller',Class);
  
  command = 'mfilename(''fullpath'')';
end

