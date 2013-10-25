classdef Task < handle
  %TASK Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
    State     = GrasppeAlpha.Core.Enumerations.TaskStates.Initializing;
    Name      = '';
    Progress  = [];
    Status    = 'Initializing';
  end
  
  properties (SetAccess=protected, GetAccess=protected)
    progress
    status
  end
  
  methods
    
    function set.State(obj, state)
      
      if isa(state, 'GrasppeAlpha.Core.Enumerations.TaskStates')
        obj.Status    = state;
      elseif ischar(state)
        obj.Status    = GrasppeAlpha.Core.Enumerations.TaskStates.(state);
      end
      
    end
    
  end
  
  methods (Access=protected)
    
    function initializeTask(obj)
      obj.State       = 'Initializing';
      
      obj.State       = 'Pending';
    end
    
    function startTask(obj)
      obj.State       = 'Starting';
      
      obj.State       = 'Started';
      
      
    end
    
    function resumeTask(obj)
      obj.State       = 'Started';
    end
    
    function pauseTask(obj)
      obj.State       = 'Paused';
    end
    
    function endTask(obj)
      obj.State       = 'Finishing';
      
      obj.State       = 'Finished';
    end    
    
    function abortTask(obj)
      obj.State       = 'Terminating';
      
      obj.State       = 'Terminated';
    end
    
  end
  
end

