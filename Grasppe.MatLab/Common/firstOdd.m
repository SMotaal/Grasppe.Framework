function [ value ] = firstOdd( value )
  %FIRSTODD equal to or first greater odd number
  
  
  % value = round(value/2)*2+1;
  value = round(value);
  value = value + (1 - rem(value,2));
end

