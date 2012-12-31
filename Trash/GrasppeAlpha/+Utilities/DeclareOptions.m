function DeclareOptions(var)
  %DEFINEOPTIONS Capture variables into options
  %   Detailed explanation goes here
  
  clearing = false;
  if nargin==0
    var = '';
  elseif strcmp(var, 'clear')
    clearing = true;
    var = '';
  end
  
  if isempty(var), var = 'OPTIONS'; end
  
  if clearing
    vars = evalin('caller', 'WorkspaceVariables(true)');
  else
    vars = evalin('caller', 'WorkspaceVariables');
  end
  
  assignin('caller', var, vars);
end

