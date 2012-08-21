function tf = argPassed(v)
  %ARGPASSED Check if argument exists and is not empty
  %   TF = ARGPASSED(V) returns true if V exists and is not an empty matrix
  
  tf = evalin('caller', ['exist(''' v ''', ''var'')>0 && ~isempty(' v ')']);
  
end

