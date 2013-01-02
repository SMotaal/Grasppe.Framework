function [names values paired pairs] = ParseOptions(varargin)
  
  names                 = varargin;
  extraArgs             = {};
  
  %% Parse Lead Structures
  while (~isempty(names) && isstruct(names{1}))
    stArgs              = stArgs(names{1});
    extraArgs           = [extraArgs stArgs]; %#ok<*AGROW>
    
    if length(names)>1
      names = names(2:end);
    else
      names = {};
    end
    
  end
  
  names = [extraArgs, names];
  
  [pairs paired names values ] = pairedArgs(names{:});
  
  if nargout<2 && paired && numel(names)>0
    stArgs              = cell(numel(names)*2,1);
    
    stArgs(1:2:end)     = names;
    stArgs(2:2:end)     = values;
    
    names               = struct(stArgs{:});
    
    %     if nargout==0
    %       disp(names);
    %       %clear names;
    %     end
  end
  
  
end

function [ nargs even names values ] = pairedArgs(varargin)
  %PAIREDARGS number of variable arguments
  %   Return the number of arguments, if the number of arguments is even,
  %   the names from every other argument, and the values from every next
  %   other argument.
  
  even    = false;
  names   = {};
  values  = {};
  
  if length(varargin)==1 && iscell(varargin{1})
    args  = varargin{1}(:);
  elseif length(varargin)>1
    args  = varargin(:);
  else
    args  = {};
  end
    
  nargs = numel(args);
      
  if nargout > 1
    even = rem(nargs,2)==0;
  end
  
  if nargout == 3
    names = args(1:2:end);
    if (~iscellstr(names))
      warning('Grasppe:VarArgs:InvalidOutputs', ...
          ['Invalid number of outputs. Names and values must be parsed together.\n' ...
          'Consider adding or removing one output to properly parse the names']);      
    end
  end
  
  if (nargout > 3 && even)
    names   = cell(1,nargs/2);
    values  = cell(1,nargs/2);
    pairs   = 0;
    voids   = [];
    
    for i=1:2:length(args)
      name  = args{i};
      value = args(i+1);
      
      if (ischar(name) && ~isempty(name))
        pairs = pairs+1;        
        names(pairs)  = {name};
        values(pairs) = value;
      else
        voids = [voids i];
      end
    end
    
    names   = names(1:pairs);
    values  = values(1:pairs);
    
    if (pairs ~= nargs/2)
%       warning('Grasppe:VarArgs:InvalidNames', ...
%         ['Invalid names fields [' int2str(voids) ']. These pairs were dropped.']);
    end
  end
  
end

