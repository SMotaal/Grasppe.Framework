function [ result ] = isQuitting( newState )
  %ISQUITTING persistent toggle called by a finish script
  
  persistent state;
  
  if (validCheck('newState','logical'))
    state = newState;
    return;
  end
  
  if (~validCheck('state','logical'))
    state = false;
  end
  
  result = state;  
  
end

