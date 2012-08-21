classdef ProcessProgress < Grasppe.Core.Prototype
  %PROCESSPROGRESS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Tasks       = Grasppe.Occam.ProcessTask.empty();
    Maximum     = [];
    Window      = [];
    ActiveTask  = [];
  end
  
  properties (Dependent)
    OverallProgress
  end
  
  properties (Hidden)
    load              = [];
    progress          = [];
    progressListeners = {};
    resetting         = false;
    completed         = false;
  end
  
  events
    ProgressChange
    ProcessCompleted
    ProcessCancelled
  end
  
  methods
    function progress = get.OverallProgress(obj)
      load      = obj.load;
      progress  = obj.progress;
      
      if isempty(load) || isempty(progress) || load==0 % || progress==0
        progress = [];
        return;
      end
      
      progress  = progress / load;
      
      if isscalar(obj.Maximum) && isnumeric(obj.Maximum)
        progress = progress * obj.Maximum/100;
      end
    end
    
    function addProgressListener(obj, listener)
      
      callback = @(source, data) listener.progressUpdate(source, data);
      
      progressListeners = obj.progressListeners;
      
      if ~any(cellfun(@(x)isequal(x, listener), progressListeners))

        for evt = {'ProgressChange', 'ProcessCancelled', 'ProcessCompleted'} % 'TaskCancelled', 'TaskCompleted'}
          hListener  = addlistener(obj, char(evt), callback);
        end
        
        progressListeners{end+1}  = listener;
        
        obj.progressListeners     = progressListeners;
      end
    end
    
    function activateTask(obj, task)
      obj.ActiveTask = task;
    end
    
    function state = isResetting(obj)
      state = isequal(obj.resetting, true);
    end
    
    function state = isCompleted(obj)
      state = isequal(obj.completed, true);
    end
    
    
    function resetTasks(obj)
      
      if obj.isResetting, return; end
      obj.resetting = true;
      obj.updateProgress;
      
      try
        tasks     = obj.Tasks;
        ntasks    = numel(tasks);   
        
        for m = 1:ntasks
          try CANCEL(tasks(m),'Process interrupted'); end
        end

        for m = 1:ntasks
          try delete(tasks(m)); end
        end

        obj.Tasks = Grasppe.Occam.ProcessTask.empty();
        obj.updateProgress;
      catch err
      end
      obj.resetting = [];
      
    end
    
    function task = addTask(obj, title, load, varargin)
      %obj.UpdateProgressComponents;
      task = Grasppe.Occam.ProcessTask(obj, title, load, varargin{:});
      
      obj.Tasks(end+1) = task;
    end
  end
  
  methods (Hidden)
    function updateProgress(obj)
      
      if obj.isResetting;
        try
          UI.setStatus('', h, []);
        catch err
          UI.setStatus();
        end
        return;
      end
        
      tasks     = obj.Tasks;
      ntasks    = numel(tasks);
      active    = obj.ActiveTask;
      
      load      = 0;
      progress  = 0;
      
      for m = 1:ntasks
        task        = tasks(m);
        
        if ~task.isvalid() || task.isTerminated()
          continue; 
        end
               
        factor      = abs(task.Factor);
        taskload    = abs(task.Load     * factor);
        
        load        = load + taskload;
        
        if task.isCompleted()
          progress  = progress  + taskload;
        else
          progress  = progress  + abs(task.Progress * factor);
        end
        
      end
      
      progressChange  = ~isequal(obj.load, load) || ~isequal(obj.progress, progress);
      
      obj.load      = load;
      obj.progress  = progress;
      
      overall = obj.OverallProgress*100;
      
      if progressChange
        
        %dsc = 'Running';
        
        %cnt = sprintf('%0.0f', ;
        
        if load==0
          s = '';
          overall = [];
        elseif round(progress)==round(load)
          s = '';
          overall = [];
        else          
          s = sprintf('Processing: %d of %d', round([progress, load])); %overall*100
          
          try
            s = sprintf('%s: %d of %d', active.Title, round([active.Progress, active.Load])); %overall*100
            % disp(s);
%           catch err
%             %disp(err);
%             x=1;
          end
        end
        
        
        
        h=obj.Window;
        if ~isscalar(h) || ~ishandle(h)
          h = 0;
        end
          
        try
          UI.setStatus(s, h, overall); %status('', 0, []);
        catch err
          UI.setStatus(s, 0);
        end
          %dispf('Progress: %0.0f (%0.0f / %0.0f)', obj.OverallProgress*100, progress, load);
      end
    end
  end
  
end

