function tf = varExists(v)
  %VAREXISTS Check if variable exists
  %   TF = VAREXISTS(V) returns true if variable V exists
  
  tf = evalin('caller', ['exist(' v ', ''var'')>0']);
  
end

