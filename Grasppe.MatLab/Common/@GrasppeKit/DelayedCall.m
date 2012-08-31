function delayTimer = DelayedCall(callback, delay, mode)
  %DELAYEDCALL Execute callback after delay
  %   Create and return a new timer that executes a callback after some
  %   delay.
  
  st = dbstack('-completenames');
  
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
    'StartFcn',   @(s, e)debugStamp('Delay Timer Started', 3), ... % eval('disp(''StartFcn'');  disp(s);  disp(e);  disp(e.Data);'), ...
    'StopFcn',    @(s, e)delete(s), ...
    'TimerFcn',   @(s, e)callback(s,e), ...  %eval('disp(''TimerFcn'');  error(''No:Id'', ''testing'');'), ...
    'ErrorFcn',   @(s, e)feval('debugStamp', ...
    struct('message', e.Data.message, 'identifier', e.Data.messageID, 'stack', st), 1)  ...
    );
  
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

