function [ nargs even names values ] = varargs(firstArg)
  %NVARARGIN number of variable arguments
  %   Return the number of arguments, if the number of arguments is even,
  %   the names from every other argument, and the values from every next
  %   other argument.
 
  try
    args = evalin('caller', 'varargin{:}');
    
    nargs = numel(args);
    
    if (validCheck('firstArg','double') && firstArg > 0 && firstArg < nargs)
      args  = args(firstArg:end);
      nargs = numel(args);
    end
    
    [ nargs even names values ] = pairedArgs(args{:});
    
    switch nargout
      case 0
        pairedArgs(args);
      case 1
        [ nargs ] = pairedArgs(args);
      case 2
        [ nargs even ] = pairedArgs(args);
      case 3
        [ nargs even names ] = pairedArgs(args);
      case 4
        [ nargs even names values ] = pairedArgs(args);
    end
    
  catch err
    if strcmpi(err.identifier, 'MATLAB:unassignedOutputs')
      nargs   = 0;
      even    = false;
      names   = {};
      values  = {};
    else
      error('Grasppe:VarArgs:InvalidCaller', ...
        'Attempt to execute varargs outside a function is invalid.');
    end
  end
  
end

