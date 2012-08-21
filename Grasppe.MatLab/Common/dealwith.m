function [ err ] = dealwith(err)
  %DEALWITH Handle caugth exceptions
  %   Detailed explanation goes here
  
  debugmode = true;
  
  if debugmode
    disp(err);
    keyboard;
    dbstop in dealwith>debugError if error;
    debugError(err);
    dbclear in dealwith;
  elseif ~debugmode
    disp(err);
  else
    return;
  end
    
end


function debugError(err)
    rethrow(err);
end
