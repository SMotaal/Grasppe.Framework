function [ xI ] = linInterp( x, steps, range )
  %INTERPSPACE Interpolate linear value
  %   Detailed explanation goes here
  
  xI = interp1(linspace(range(1), range(2), steps), 1:steps, x);
  
end

