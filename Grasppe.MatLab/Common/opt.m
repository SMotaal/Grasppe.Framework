function [ result err ] = opt( varargin )
%OPT Safely execute a statement returning any caught exceptions

statement = '';
err = [];

for var = varargin
  var = strtrim(char(var));
  var = regexprep(var,'^"([^"]*)"$','''$1''');
  statement = strcat(statement,' ', var);
end

statement = strtrim(statement);

try
  result = evalin('caller', [statement ';']);
catch err
  result = false;
end

end

