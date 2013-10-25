classdef TaskStates
  %TASKSTATES for Process and Task (Grasppe Core Prototypes 2)
  %   Detailed explanation goes here
  
  enumeration
    Initializing  % Not ready
    Ready         % Ready but never started
    Starting      % Preparing to run
    Running       % Executing
    Paused        % Ready and was running
    Finishing     % No longer running but still processing
    Completed     % Finished running and ready for deletion
    Terminating   % Aborted or failed but still processing
    Terminated    % Aborted or failed and ready for deletion
  end
  
  %   methods
  %     function enum = TaskStates()
  %       disp(enum);
  %     end
  %   end
  
end

