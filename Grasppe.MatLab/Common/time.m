function [ seconds ] = time( value )
  %TIME Summary of this function goes here
  %   Detailed explanation goes here
  
  if nargin==0
    seconds = now*24*60*60;
  elseif nargin==1
    seconds = value*24*60*60;
  end
end

