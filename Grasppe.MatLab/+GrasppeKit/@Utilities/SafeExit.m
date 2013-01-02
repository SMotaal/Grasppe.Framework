function SafeExit(terminateCallback, abortCallback, forceCallback, cancelCallback)
  %SAFEEXIT Quit Confirmation Mechanism
  %   Grasppe SafeExit provides an unobtrusive mechanism to prevent
  %   accidental quitting. The function must be called from the finish.m
  %   file located in MatLab's search path. Simply add GrasppeKit.Utilities.SafeExit
  %   to enable the mechanism. Alternatively, you can specify a callback
  %   function as an argument GrasppeKit.Utilities.SafeExit(callback), which will
  %   execute right before quitting.
  
  persistent T M
  
  if ~exist('terminateCallback',  'var') || ~isa(terminateCallback, 'function_handle'), ...
      terminateCallback   = '';             end
  if ~exist('abortCallback',      'var') || ~isa(abortCallback,     'function_handle'), ...
      abortCallback       = '';             end
  if ~exist('forceCallback',      'var') || ~isa(forceCallback,     'function_handle'), ...
      forceCallback       = '';             end
  if ~exist('cancelCallback',     'var') || ~isa(cancelCallback,    'function_handle'), ...
      cancelCallback      = abortCallback;  end
  
  if isempty(M), M = 0; end
  
  if isempty(T) || toc(T)>3
    T = tic;  	M = 1;
    GrasppeKit.Utilities.DisplayText('GRASPPE SAFE EXIT', 'Press CMD+Q again once in the next 3 seconds to quit.');
    isQuitting(true);
    GrasppeKit.Utilities.DelayedCall(@(s, e)abort(abortCallback),4,'start');
    pause(0.1);
    cancel(cancelCallback);
    return;
  else
    if M==1
      GrasppeKit.Utilities.DisplayText('GRASPPE SAFE EXIT', 'Press CMD+Q again once to force quit.');
      pause(0.1);
      terminate(terminateCallback);
      M = 2;
    elseif M==2
      force(forceCallback);
    end
  end
  
end

function abort(callback)
  isQuitting(false);  
  if isa(callback, 'function_handle'), feval(callback); end
  GrasppeKit.Utilities.DisplayText('GRASPPE SAFE EXIT', 'Termination is aborted. To quit, you must press CMD+Q twice within 3 seconds.');
end

function cancel(callback)
  isQuitting(false);  
  if isa(callback, 'function_handle'), feval(callback); end
  quit('cancel');
end

function terminate(callback)
  if isa(callback, 'function_handle'), feval(callback); end
  close all; cleardebug;
  pause(0.1);
end

function force(callback)
  if isa(callback, 'function_handle'), feval(callback); end
  quit('force');
end
