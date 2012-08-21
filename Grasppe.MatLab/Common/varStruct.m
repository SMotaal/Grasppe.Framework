function [ s ] = varStruct( varargin )
  %VARSTRUCT Summary of this function goes here
  %   Detailed explanation goes here
  
  names     = {};
  values    = {};
  
  noinputs  = true;
  
  for i = 1:nargin
    name = inputname(i);
    if ~isempty(name)
      names     = {names{:},  name};
      values    = {values{:}, varargin{i}};
      noinputs  = false;
    end
  end
  
  if noinputs
  names     = {};
  values    = {};    
    for i = 1:nargin
      name      = varargin{i};
      value     = evalin('caller', name);
      names{i}  = name;
      values{i} = {value};
    end
  end
  
  args = cell(1,length(names).*2);
  
  args(1:2:end) = names;
  args(2:2:end) = values;
  
  s = struct(args{:});
end

