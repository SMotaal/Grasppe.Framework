function [ sb ] = status( text, h )
  %STATUS Summary of this function goes here
  %   Detailed explanation goes here
  
  if nargin==0, return; end
  
  if nargin<2 || isempty(h), h=0; end
  
  sb = statusbar(h, text); drawnow update; %forcedraw();
  
end

