function base = addExceptions(base, varargin)
  %ADDEXCEPTION combine cause with base exception
  
  if (nargin > 2)
    if (isempty(varargin{1}) && (numel(varargin) > 1))
      for i = 2:numel(varargin)
        base   = addExceptions(base, varargin{i});
      end
      return;
    else
      cause     = addExceptions(varargin{:});
    end
  elseif nargin==2
    cause     = varargin{1};
    if isempty(cause)
      base = [];
    end
  else
    return;
  end
  
  try
    if isempty(base) && ~isempty(cause)
      base = cause;
    elseif ~isempty(base) && ~isempty(cause)
      base = addCause(base, cause);
    end
  end
end
