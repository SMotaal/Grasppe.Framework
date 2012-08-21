function [ value ] = limit( value, minimum, maximum)
  %LIMIT values to specified range
  %   Detailed explanation goes here
  
  if ~isnumeric(value) || isempty(value)
    value = minimum;
    return;
  end

  if isnumeric(minimum)
    value   = max(minimum, value);
  end
  
  if isnumeric(maximum)
    value   = min(maximum, value);
  end
  
end

