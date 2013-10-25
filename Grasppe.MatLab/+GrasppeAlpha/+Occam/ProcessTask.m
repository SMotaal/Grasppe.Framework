classdef ProcessTask < GrasppeAlpha.Core.Prototype
  %PROCESSTASK Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Title     = '';
    Load      = 1;
    Progress  = 0;
    Factor    = 1;
    Quota     = [];    
    Process   = [];
    Cancelled = false;
    Completed = false;
  end
  
  properties
    progressListeners = {};
  end
  
  events
    ProgressChange
    TaskCompleted
    TaskCancelled
  end
  
  methods
    function obj = ProcessTask(process, varargin)     
      properties = {'Title', 'Load', 'Factor', 'Progress'};
      
      obj.Process = process;      
      
      for p = 1:min(nargin-1, numel(properties))
        obj.(properties{p})  = varargin{p};
      end
    end
    
    function state = isTerminated(obj)
      state = ~isequal(obj.Cancelled, false);  
    end
    
    function state = isCompleted(obj)
      state = isequal(obj.Completed, true);
    end
    
    function addProgressListener(obj, listener)
      
      callback = @(source, data) listener.progressUpdate(source, data);
      
      progressListeners = obj.progressListeners;
      
      if ~any(cellfun(@(x)isequal(x, listener), progressListeners))

        for evt = {'ProgressChange', 'TaskCancelled', 'TaskCompleted'}
          hListener  = addlistener(obj, char(evt), callback);
        end
        
        progressListeners{end+1}  = listener;
        
        obj.progressListeners     = progressListeners;
      end
    end
    
    
    function progressCheck(obj, varargin)
      
      try
      
      if ~obj.isvalid()
        error('Grasppe:Progress:TaskDeleted', 'Progress checked cannot be performed on this task since it has been deleted.');
      end
      
      if obj.isTerminated()
        error('Grasppe:Progress:TaskCancelled', 'Progress checked cannot be performed on this task since it has been cancelled.');
      end
      
      if obj.isCompleted()
        warning('Grasppe:Progress:TaskCompleted', 'Progress checked cannot be performed on this task since it has already been completed.');
      end

      check = 1;
      if nargin>=2, check = varargin{1}; end      
      
      if isempty(obj.Progress) || ~isnumeric(obj.Progress), obj.Progress = 0; end
      if isempty(obj.Load) || ~isnumeric(obj.Load), obj.Load = 0; end
      
      load      = obj.Load;
      progress  = obj.Progress + check;
      progress  = min(progress, load);
      
      if progress>=load, 
        obj.Completed = true; 
        try notify(obj.Process, 'TaskCompleted'); end
      end
      
      obj.Progress = progress;
      
      obj.Process.updateProgress; %try obj.Process.updateProgress; end
      
      try
        notify(obj.Process, 'ProgressChange');
      end
      
      catch err
        try debugStamp(err, 1, obj); catch, debugStamp(); end;
      end
    end
    
    function delete(obj)
      if obj.isvalid()
        while ~obj.isCompleted && ~obj.isTerminated
          obj.cancelTask('Task deleted');
        end
      end
    end
    
    function cancelTask(obj, reason)
      if ~obj.isvalid()
        error('Grasppe:Progress:TaskDeleted', 'Cancelling cannot be performed on this task since it has been deleted.');
      end      
      
      if obj.isTerminated()
        warning('Grasppe:Cancel:TaskCancelled', 'Cancelling cannot be performed on this task since it has already been cancelled.');
        return;
      end
      if obj.isCompleted()
        warning('Grasppe:Cancel:TaskCompleted', 'Cancelling cannot be performed on this task since it has been completed.');
        return;
      end
      
      obj.Cancelled = true;
      
      if nargin>1 && ischar(reason) && ~isempty(reason)
        obj.Cancelled = reason;
      end
      
      notify(obj.Process, 'TaskCancelled');
      notify(obj.Process, 'ProgressChange');
    end
    
    function CANCEL(obj, varargin)
      s = warning('off', 'all');
      obj.cancelTask(varargin{:});
      warning(s);
    end
    
    function CHECK(obj, varargin)
      %if ~obj.isvalid
      %s = warning('off', 'all');
      s = warning('off', 'all');
      try
        obj.progressCheck(varargin{:});
      catch err
        try evalin('caller','return'); end
      end
      warning(s);
    end
    
    function SEAL(obj)
      s = warning('off', 'all');
      try
        obj.progressCheck(obj.Load);
      catch err
        try evalin('caller','return'); end
      end
      warning(s);
    end
    
    function set.Factor(obj, factor)
      if ~isnumeric(factor) || ~isscalar(factor)
        error('Grasppe:Set:InvalidFactor', 'Process factor must be a numeric scalar.');
      end
      obj.Factor = factor;
    end
    
    function set.Load(obj, load)
      if ~isnumeric(load) || ~isscalar(load)
        error('Grasppe:Set:InvalidFactor', 'Process factor must be a numeric scalar.');
      end
      obj.Load = load;
    end

    function set.Progress(obj, progress)
      if ~isnumeric(progress) || ~isscalar(progress)
        error('Grasppe:Set:InvalidFactor', 'Process factor must be a numeric scalar.');
      end
      obj.Progress = progress;
    end    
  end
  
end

