classdef ProcessProgress < GrasppeAlpha.Core.Prototype
  %PROCESSPROGRESS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Tasks       = GrasppeAlpha.Occam.ProcessTask.empty();
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
    started           = [];
    estimated         = [];
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
      obj.started     = tic;      
      obj.ActiveTask  = task;
      
      % try %if isempty(task)
      %   dispf('Active Task: %s', task.Title);
      % catch err
      %   dispf('Active Task: %s', '[None]');
      % end
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

        obj.Tasks = GrasppeAlpha.Occam.ProcessTask.empty();
        obj.updateProgress;
      catch err
      end
      obj.resetting = [];
      obj.started   = [];
    end
    
    function task = addTask(obj, title, load, varargin)
      %obj.UpdateProgressComponents;
      task = GrasppeAlpha.Occam.ProcessTask(obj, title, load, varargin{:});
      
      obj.Tasks(end+1) = task;
    end
    
    function task = addAllocatedTask(obj, title, quota, load, varargin)
      task        = obj.addTask(title, load, varargin{:});
      task.Quota  = quota;
    end
  end
  
  methods (Hidden)
    function updateProgress(obj)
      
      if isQuitting, pause(1); end
      
      if obj.isResetting;
        try
          statusbar(0, '');
          %UI.setStatus('', h, []);
        catch err
          %UI.setStatus();
        end
        return;
      end
        
      tasks         = obj.Tasks;
      ntasks        = numel(tasks);
      active        = obj.ActiveTask;
      
      subload       = 0;
      subprogress   = 0;
      subquota      = 100;
      
      progress      = 0;
      quotas        = 0;
      
      for m = 1:ntasks
        task        = tasks(m);
        
        if ~task.isvalid() || task.isTerminated(), continue; end
        
        taskquota     = task.Quota;
        taskfactor    = abs(task.Factor);
        taskload      = abs(task.Load     * taskfactor);
        taskprogress  = abs(task.Progress * taskfactor);
        
        if isnumeric(taskquota) && isscalar(taskquota)
          quotas      = quotas   + taskquota;
          progress    = progress + max(0, taskprogress*taskquota/taskload); % could be NaN
        else % isempty(taskquota)
          subload     = subload + taskload;
          if task.isCompleted()
            subprogress  = subprogress  + taskload;
          else
            subprogress  = subprogress  + taskprogress;
          end
        end
      end
      
      subquota        = subquota  - quotas;
      progress        = progress  + max(0, subprogress*subquota/subload); % could be NaN
      load            = 100;
      
      change          = ~isequal(obj.progress, progress) || ~isequal(obj.load, load);
      
      if change
        
        obj.load      = load; %min(0, load);
        obj.progress  = progress; %min(0, progress);
        
        overall       = obj.OverallProgress*100;
        
        if load==0 || round(progress)==round(load) || isnan(progress) || isnan(load)
          s = '';
          overall = [];
        else
          
          s = sprintf('Processing - %d of %d', round([progress, load]));
          try
            s = sprintf('%s - %d tasks remaining', active.Title, round([active.Load - active.Progress]));
          end
          
          %% Time Estimation
          try
            if isempty(obj.started), obj.started = tic; end
            
            duration    = toc(obj.started);
            estimated   = obj.estimated;
            remaining   = [];
            
            if isempty(active)
              eprogress   = progress;
              eload       = load;
            else
              eprogress   = active.Progress;
              eload       = active.Load;
            end
            
            epercent      = eprogress*100/eload;
            
            if eprogress>0
              estimated   = duration / eprogress * (eload-eprogress);
              estimating  = isscalar(obj.estimated) && epercent > 10 && duration > 3;
              decreasing  = estimating && estimated < obj.estimated*0.95;
              increasing  = estimating && estimated > obj.estimated*1.2;
              
              if decreasing || increasing
                remaining = estimated;
                obj.estimated = estimated;
              elseif estimating %&& ~(increasing || decreasing)
                remaining = obj.estimated;
              else
                remaining = [];
              end
              
              if isempty(obj.estimated), obj.estimated = estimated; end
            else
              estimated     = [];
              obj.estimated = estimated;
            end
            
            if isscalar(remaining) && isnumeric(remaining)
              remaining = max(0, (remaining *1.45) - 1);              
              if remaining>60 && remaining < 2*60
                remaining = 2*60; %remaining *1.45;
                % remaining = remaining * 1.25;
                %s = sprintf('%s - %d:%02.0f minutes', s, floor(remaining/60), rem(remaining, 60));
                s = sprintf('%s - less than %d minutes', s, ceil(remaining/60));
              elseif remaining>2*60
                %remaining = remaining * 1.45;
                % if remaining>4*60, remaining = remaining * 1.5; end
                % remaining = max(2*60, remaining);
                s = sprintf('%s - more than %d minutes', s, round((remaining+15)/60)); %, rem(remaining, 60));
              else
                %if remaining>2 && remaining < 39, remaining = remaining * 1.5; end
                % remaining = min(remaining, 60);
                s = sprintf('%s - around %1.0f seconds', s, remaining);
              end
            end          
            
          catch err
            try debugStamp(err, 1, obj); catch, debugStamp(); end;
          end
          
          try if overall>=0 && overall<=100, s = sprintf('%s (%d%% complete)', s, round(overall)); end; end
        end
        
        obj.notify('ProgressChange');
        
        h=obj.Window;
        if ~isscalar(h) || ~ishandle(h) || ~strcmpi(get(h,'Visible'), 'on'), h = 0; end
        
        try s = regexprep(s, '%*', '%%'); end % '(?=[^%])%(?=>[^%])', '%%');
                

        
          

        sb                = [];
        
        if isequal(h, 0) || isequal(obj.Window, 0)
          statusbar(0, s);
          return;
        else
          sb = statusbar(h, s);
        end
        
        if isempty(s)
          try sb          = statusbar(obj.Window, s); end
          try set(sb.ProgressBar, 'Visible','off', 'Minimum',0, 'Maximum',100, 'Value',overall); end
        else
          if ~isequal(h, 0)
            try set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',100, 'Value',overall); end
          end
        end
        %try UI.setStatus(s, h, overall);
        %catch err, UI.setStatus(s, 0); end

      end
      
    end
  end
  
end

