function tf = UpdateState(obj, mode, targetState, abortOnFail)
  %UPDATESTATE Set, Promote, Demote, Check and Test State
  %   Detailed explanation goes here
  
  tf = false;
  
  if exist('targetState') && ischar(targetState)
    targetState = obj.GetNamedState(targetState);
  end
  
  try
    switch lower(mode)
      case {'promote'}
        if isempty(obj.State) || all(obj.State < targetState) || all(obj.State.ID < targetState.ID)
          obj.State = targetState;
          tf = true;
        end
      case {'demote'}
        if isempty(obj.State) || obj.State > targetState || obj.State.ID > targetState.ID
          obj.State = targetState;
          tf = true;
        end
      case {'set'}
        obj.State = targetState;
        tf = true;
      case {'check'}
        try tf  = obj.State >= targetState; end
      case {'start test'}
        tf = testState(obj);
      case {'stop test'}
        tf = testState(obj, true);
    end
  catch err
    debugStamp(err,1, obj);
  end
  
  if ~tf && exist('abortOnFail', 'var') && isequal(abortOnFail, true)
    evalin('caller', 'return;'); return;
  end
  
end

function tf = testState(obj, terminate)
  tf = true;
  
  if isempty(obj.TestTimer) || ~isscalar(obj.TestTimer) || ~isa(obj.TestTimer, 'timer') || ~isvalid(obj.TestTimer)
    obj.TestTimer = timer('Tag',['TestStatusDelayTimer'], ...
      'ExecutionMode', 'fixedSpacing', 'TasksToExecute', 5, ...
      'BusyMode',   'drop', 'StartDelay', 0.1, 'Period', 1, ...
      'ObjectVisibility',  'on', ...  %'StartFcn',   @displayStart, ... % eval('disp(''StartFcn'');  disp(s);  disp(e);  disp(e.Data);'), 'StopFcn',    @(s, e) delete(s), ...
      'TimerFcn',   @(s, e)disp(obj.State) ...           %'ErrorFcn',   @displayError ...
      );
  end
  
  if exist('terminate', 'var') && isequal(terminate, true)
    try stop(obj.TestTimer); end
  else
    try start(obj.TestTimer); end
  end
end


