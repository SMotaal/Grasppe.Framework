function [ value ] = let( var, varargin )
%LET Sets specified variable to a specified value

space = 'caller';

value = '';
if numel(varargin)==1
  value = strtrim(char(varargin));
elseif numel(varargin)>1
%   firstarg = ;
  if strcmp(varargin{1},'=')
    varargin{1}='';
  end
  for arg = varargin
    arg = strtrim(char(arg));
    arg = regexprep(arg,'^"([^"]*)"$','''$1''');
    value = [value ' ' arg];
  end
end
value = strtrim(regexprep(value,'^"(.*)"$','''$1'''));

try value = eval(['[' value ']']); end

assignin(space, var, value);

end

