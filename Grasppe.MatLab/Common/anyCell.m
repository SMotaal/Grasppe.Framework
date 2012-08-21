function [ result ] = anyCell( obj )
  %ANYCELL Summary of this function goes here
  %   Detailed explanation goes here
  
  result = iscell(obj) && ~isempty(cell2mat(obj));
  
end

