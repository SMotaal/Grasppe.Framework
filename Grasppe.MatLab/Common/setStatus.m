function [ h ] = setStatus( status )
  %SETSTATUS Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent statustext statustimer
  
  default status false;
  
  if isempty(statustimer)
    
  end
      
  if ischar(status)
    if isempty(status)
      statustext = '';
%       stop(statustimer);
    else
      statustext = status;
      disp('starting');
      try
        start(statustimer);
      catch err
        statustimer = timer('Name','StatusTimer','ExecutionMode', 'fixedDelay', 'Period', 0.1, 'StartDelay', 1, 'TimerFcn', 'setStatus();');
        start(statustimer);
      end
    end
  end
    
  

  if isempty(statustext)
    h = statusbar(0);
    disp('stopping');
    stop(statustimer);
  else
%     disp('updating');
    h = statusbar(0, statustext);
  end
  
end
