function [ str ] = camelCase (str)
  %CAMELCASE convert normal text to camelCase
  
  if ~validCheck(str, 'char')
    error('Grasppe:CamelCase:InvalidInput', 'The argument must be a valid string of type char');
  end
   
  %% Invalid Characters
  str = strtrim(str);
  str = regexprep(str, '[^\w]|[_]',' ');

  %% First Word
  str = regexprep(str,'^(?:\s*)([a-z0-9]*)(?:\s*)(.*)$','${lower($1)} $2');
  
  %% Proper Word
  str = regexprep(str, '(\s+)\<[0-9]*(\w)([a-z]*)\>','${upper($2)}${lower($3)}');
  
  %% Space Characters
  str = regexprep(str ,'\s*' ,'');
  
end
