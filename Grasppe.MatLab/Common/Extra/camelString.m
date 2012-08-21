function [ str ] = camelString(varargin)
  %CAMELCASE convert normal text to camelCase
  
  warning('Grasppe:Depricated:CamelString', ...
    'CamelString is depricated due to inaccurate output issues');
   
  str = '';
  
  for i = 1:numel(varargin)
    arg = varargin{i};
    if ischar(arg)
      arg = strtrim(arg);
      try
        arg(1) = upper(arg(1));
      end
      str = [str ' ' arg];
    elseif validCheck(arg, 'numeric')
      if arg<0
        str = [str ' 0' int2str(arg)];
      else
        str = [str ' ' int2str(arg)];
      end
    end
  end
  str = camelCase(str);
  
end
