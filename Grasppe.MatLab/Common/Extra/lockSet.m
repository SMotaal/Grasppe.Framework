function [ newstate, oldstate ] = lockSet( state ) % , forceAbort )
  %LOCKCHECK Summary of this function goes here
  %   Detailed explanation goes here
   
  nout = nargout;
  
  if (state && nout < 2)
    evalin('caller', 'return;');
  end
  
  if nout > 0
    newstate = true;    
    oldstate = state;
  end
  
end

