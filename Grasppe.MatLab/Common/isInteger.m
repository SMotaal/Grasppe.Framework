function [ check ] = isInteger( object )
  %ISINTEGER Determine if values are round integers
  %   Detailed explanation goes here
  
  try
    if isempty(inputname(1)) && ischar(object)
      object = evalin('caller', object);
    end
  end
  
  try
    check = isnumeric(object) && all(round(object)==object);
  catch err
    check = false;
  end
end

