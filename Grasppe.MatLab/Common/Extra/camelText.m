function [ str ] = camelText( str )
  %CAMELSTRING convert camelCase to normal text
  %   Known Bugs:
  %   * camelText('A12B') = 'A 12 $1$2'       % Ending UC after Num
  %   * camelText('A12b') = 'A 12 $1$2'       % Ending LC after Num
  
  if ~validCheck(str, 'char')
    error('Grasppe:CamelCase:InvalidInput', 'The argument must be a valid string of type char');
  end
  
  %% Invalid Characters
  str = strtrim(str);
  
  %% First Letter 
  try
    str(1) = upper(str(1));
  end
  
  %% Camel Words
  str = regexprep(str,  ...
    ['(\w)\s*$' '|' '(\d|[A-Z]?)' ...             % Last character OR 1:(First UC or Num)
    '(' '(?<=\d)\d*' '|' ...                    % Then  2:(Nums after Num)
    '(?<=[A-Z])[A-Z]*(?=[0-9]|[A-Z][a-z])' ...  %  or   2:(UC after UC before Num or before [UC LCs])
    '|[a-z]+' ')'], ...                         %  or   2:LCs
    '$1$2 ');                                   % Reconstruct
  
  try
    if (strcmp(str(end-2:end), '$2 '))
      str = str(1:end-3);
    end
  end
end

