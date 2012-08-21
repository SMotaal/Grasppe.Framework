function [str] = firstMatch(strs, pattern, varargin)
  
%   argFirst = anyCell(regexpi(varargin,'first'));
  argLast = anyCell(regexpi(varargin,'last'));
  
  if (argLast)
    findArg = 'last';
  else
    findArg = 'first';
  end
  
  [str idx] = regexpi(strs(:),pattern,'match','once');  
  idx = find(cellfun(@(x) ~isempty(x),str),1, findArg);
  
  if validCheck(idx, 'double')
    str = str{idx};
  else
    str = '';
  end
end
