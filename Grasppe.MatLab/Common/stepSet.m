function [ value ] = stepSet( value, step, length, offset )
  %STEP Relative value setting
  
  try	
    value = offset + mod(value-offset+step, length);
    return;
  catch err
    if ~exists('length') || ~isnumeric(length)
      value = value+step;
      return;
    end
    
    if ~exists('offset') || ~isnumeric(offset)
      value = stepSet(value, step, length, 0);
      return;
    end
    
    rethrow(err);
  end
  
end
