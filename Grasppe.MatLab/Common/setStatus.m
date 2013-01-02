function [ h ] = setStatus( status )
  %SETSTATUS Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent statusText statusTimer
  
  if ~exist('status', 'var') status = false; end
  
  %   try
  %     if isempty(statusTimer)
  %       statusTimer = timerfindall('Tag', 'statusTimer');
  %     end
  %   end
  
  try stop(statusTimer); end
  
  if ischar(status)
    if isempty(status)
      statusText = '';
      %       stop(statusTimer);
    else
      statusText = status;
      disp('starting');
      
      if isempty(statusTimer) || ~isscalar(statusTimer) || ~isa(statusTimer, 'timer') || ~isvalid(statusTimer)
        statusTimer = GrasppeKit.Utilities.DelayedCall(@(s, e) setStatus(), 0.1, 'hold');
      end
      try start(statusTimer); end
    end
  end
  
  
  
  if isempty(statusText)
    h = statusbar(0);
  else
    %     disp('updating');
    h = statusbar(0, statusText);
  end
  
end
