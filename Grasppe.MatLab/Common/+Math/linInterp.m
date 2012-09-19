function [ xI ] = linInterp( x, steps, range, method)
  %INTERPSPACE Interpolate linear value
  %   Detailed explanation goes here
  
  if ~exist('method', 'var'), method = 'linear'; end
  
  xI = interp1(linspace(range(1), range(2), steps), 1:steps, x, method);
  
end

