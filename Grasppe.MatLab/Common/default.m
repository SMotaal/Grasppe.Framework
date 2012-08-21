function [ value ] = default( var, varargin) % , flag, space)
%DEFAULT Sets specified variable to a default value if not already defined

space = 'caller';

% value = true;
% try value = evalin(space, ['isempty(' var ')']); end
% 
% if ~isempty(value) %
if evalin(space,['~exist(''' var ''', ''var'') || isempty(' var ')'])
% if value
  value = flatcat(varargin);
  try
    eValue = eval(value);
    if (isnumeric(eValue) || islogical(eValue))
      value = eValue;
    end
  end
  if (numel(varargin)>1 && strcmpi(varargin{1},'='))
%     try
      value = evalin(space, [value(2:end) ';']);
%     catch
%       try
%         value = eval(value);
%       end
%     end
  elseif (numel(varargin)==1 && strcmpi(varargin{1},'='))
    value = [];
  end
  assignin(space, var, value);
end

end

