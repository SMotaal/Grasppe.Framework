function [ str ] = statements( varargin )
  %STATEMENT Summary of this function goes here
  %   Detailed explanation goes here
  
str = '';

for var = varargin
  var = strtrim(char(var));
  var = regexprep(var,'^"([^"]*)"$','''$1''');
  str = strcat(str,' ', var);
end

str = strtrim(str);
  
end

