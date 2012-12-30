function delayTimer = DelayedCall(callback, delay, mode)
  %DELAYEDCALL Execute callback after delay
  %   Create and return a new timer that executes a callback after some
  %   delay.
  
  st = dbstack('-completenames');
  
  if ~exist('callback', 'var') || ~isa(callback, 'function_handle') || ~isscalar(callback)
    err = MException('Grasppe:DelayedCall:InvalidCallback', ...
      'Callbacks can only be function_handles instead of %s.', class(callback));
    debugStamp(err, 1);
    throw(err);
  end
  
  if ~exist('delay', 'var') || ~isnumeric(delay) || ~isscalar(delay)
    delay = 0.1;
  end
  
  if ~exist('mode', 'var')
    mode  = 'hold';
  end
  
  delayTimer = timer('Tag',['GrasppeDelayTimer'], ...
    'ExecutionMode', 'singleShot', ...
    'BusyMode',   'drop', ...
    'StartDelay', delay, ...
    'ObjectVisibility',  'on', ...
    ...
    'StartFcn',   @displayStart, ... % eval('disp(''StartFcn'');  disp(s);  disp(e);  disp(e.Data);'), ...
    'StopFcn',    @deleteTimer, ...
    'TimerFcn',   @(s, e)callback(s, e), ...  %eval('disp(''TimerFcn'');  error(''No:Id'', ''testing'');'), ...
    'ErrorFcn',   @displayError ...
    );
  
  %     'ErrorFcn',   @(s, e)feval('debugStamp', ...
  %  struct('message', e.Data.message, 'identifier', e.Data.messageID, 'stack', st), 1)  ...
  
  
  switch lower(mode)
    case 'start'
      start(delayTimer);
    case 'hold'
    case 'persists'
      delayTimer.StopFcn = [];
  end
  %if exist('start', 'var') && ~isequal(start, false)
  
  %end
end

function displayStart(s, e)
  debugStamp('Delay Timer Started', 3)  
end

function displayError(s, e)
  %   feval('debugStamp', ...
  %     struct('message', e.Data.message, 'identifier', e.Data.messageID, 'stack', st), 1)  ...
  %     );
  st = dbstack('-completenames');
  try debugStamp(struct('message', e.Data.message, 'identifier', e.Data.messageID, 'stack', st), 1);
  catch err
    debugStamp(err, 1);
  end
end

function deleteTimer(s, e)
  clearCallbacks(s);
  try stop(s);    end
  try delete(s);  end
end


function clearCallbacks(s)
  try s.TimerFcn    = []; end
  try s.ErrorFcn    = []; end
  try s.StopFcn     = []; end
  %try s.DeleteFcn   = []; end
  try s.StartFcn    = []; end
end
