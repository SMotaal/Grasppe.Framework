function [ err ] = dealwith(err)
  %DEALWITH Handle caugth exceptions
  %   Detailed explanation goes here
  
  debugmode = true;
  
  if debugmode
    debugStamp(err,1);
    keyboard;
    dbstop in dealwith>debugError if error;
    debugError(err);
    dbclear in dealwith;
  elseif ~debugmode
    debugStamp(err,1);
  else
    return;
  end
    
end


function debugError(err)
    rethrow(err);
end
