classdef ProcessState
  %PROCESSSTATE Summary of this function goes here
  %   Detailed explanation goes here
  
  enumeration
    Inactive      ('NotActive', 'NotInitialized', 'NotRunning', 'NotReady', 'NotTerminated'); % Not Running, Not Ready, Not Initializing
    Initializing  ('Active', 'NotInitialized', 'NotRunning', 'NotReady', 'NotTerminated');  % Not ready
    Pending       % Ready but never started
    Starting      % Preparing to run
    Started       % Executing
    Paused        % Ready and was running
    Finishing     % No longer running but still processing
    Completed     % Finished running and ready for deletion
    Terminating   % Aborted or failed but still processing
    Terminated    % Aborted or failed and ready for deletion    
  end
  
  properties
    IsInactive
    IsInitialized
    IsReady
    IsRunning
    IsTerminated
  end
  
  methods
    function enum = ProcessState(varargin)
      
    end
  end
  
end

