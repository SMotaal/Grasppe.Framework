classdef TaskGroup < Grasppe.Prototypes.Task
  %TASKGROUP Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(GetAccess=protected, SetAccess=protected)
    Tasks       = Grasppe.Prototypes.Task.empty;
  end
  
  methods
    
    
  end
  
  methods
    function obj=TaskGroup(varargin)
      obj@Grasppe.Prototypes.Task(varargin{:});
    end   
    
    function step = getStep(obj)
      step            = 0;
      try
        for m = 1:numel(obj.Tasks)
          step        = step + obj.Tasks(m).getStep * obj.Tasks(m).getLoad;
        end
      catch err
      end
    end
    
    
    function steps = getSteps(obj)
      steps           = 0;
      try
        for m = 1:numel(obj.Tasks)
          steps       = steps + obj.Tasks(m).getSteps * obj.Tasks(m).getLoad;
        end
      catch err
      end
    end
    
    function addTask(obj, task)
      try
        if ~any(task==obj.Tasks), obj.Tasks(end+1) = task; end
        task.addEventListener('ProgressChange', obj);
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        return;
      end
    end
    
  end
  
end

