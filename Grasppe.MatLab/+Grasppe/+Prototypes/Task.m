classdef Task < Grasppe.Prototypes.Instance & matlab.mixin.Heterogeneous
  %TASK Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(SetObservable, GetAccess=protected, SetAccess=protected)
    State     = Grasppe.Prototypes.Enumerations.TaskStates.Initializing;
  end
  
  properties(Dependent, SetObservable, Hidden)
    Load      = 1;
    Step
    Steps
  end
  
  properties(Dependent, SetObservable)
    Status    = [];
    Progress
  end
  
  properties(SetAccess=private, GetAccess=private)
    current_progress
  end
  
  events
    StatusChange
    ProgressChange
  end
  
  properties
    ProgressData  = Grasppe.Prototypes.Models.ProgressModel;
  end
  
  methods
    function obj=Task(varargin)
      obj@Grasppe.Prototypes.Instance(varargin{:});

    end    
    
    function set.State(obj, state)
      if isa(state, 'Grasppe.Prototypes.Enumerations.TaskStates')
        obj.State     = state;
      elseif ischar(state)
        obj.State     = Grasppe.Prototypes.Enumerations.TaskStates.(state);
      end
    end
    
    function progress = get.Progress(obj)
      progress        = obj.getProgress;
    end
    
    % function set.Progress(obj, progress)
    %   obj.Progress      = progress;
    % end
    
    
    function progress = getProgress(obj)
      progress          = [];
      try progress      = obj.getStep/obj.getSteps; end
    end
    
    
    function mark(obj, step)
      if nargin==1, step = 1; end
      
      obj.setStep(obj.getStep + step);
      obj.setSteps(max(obj.getSteps, obj.getStep));
    end
    
    function reset(obj)
      obj.ProgressData  = Grasppe.Prototypes.Models.ProgressModel;
    end
    
    
    %% Process Data Getters
    function status = getStatus(obj)
      status          = obj.ProgressData.Status;
      if isempty(status), status = char(obj.State); end
    end    
    
    function step = getStep(obj)
      step            = obj.ProgressData.Step;
    end
    
    function steps = getSteps(obj)
      steps           = obj.ProgressData.Steps;
    end
    
    function load = getLoad(obj)
      load            = obj.ProgressData.Load;
    end    
    
    function status = get.Status(obj),  status  = obj.getStatus;  end
    function step = get.Step(obj),      step    = obj.getStep;    end
    function steps = get.Steps(obj),    steps   = obj.getSteps;   end
    function load = get.Load(obj),      load    = obj.getLoad;    end
    
    
    %% Process Data Setters
    function setStatus(obj, status)
      if ~isequal(status, obj.ProgressData.Status)
        obj.ProgressData.Status = status;
        obj.updateProgress();
      end
    end
    
    function setStep(obj, step)
      if ~isequal(step, obj.ProgressData.Step)
        obj.ProgressData.Step   = step;
        obj.updateProgress();
      end
    end
    
    function setSteps(obj, steps)
      if ~isequal(steps, obj.ProgressData.Steps)
        obj.ProgressData.Steps   = steps;
        obj.updateProgress();
      end
    end
    
    function setLoad(obj, load)
      if ~isequal(load, obj.ProgressData.Load)
        obj.ProgressData.Load   = load;
        obj.updateProgress();
      end
    end
    
    function updateProgress(obj)
      currentProgress   = obj.current_progress;
      progress          = obj.getProgress;
      if ~isequal(currentProgress, progress)
        obj.current_progress = progress;
        obj.notify('ProgressChange', Grasppe.Prototypes.Events.Data(obj, ... 
          struct('LastValue', currentProgress, 'NewValue', progress)));
      end
    end
    
    function set.Status(obj, status), obj.setStatus(status);  end
    function set.Step(obj, step),     obj.setStep(step);      end
    function set.Steps(obj, steps),   obj.setSteps(steps);    end
    function set.Load(obj, load),     obj.setLoad(load);      end
    
  end 
  
end

