classdef Process < GrasppeAlpha.Occam.ProcessData & GrasppeAlpha.Core.Prototype % handle & matlab.mixin.Heterogeneous
  %GENERATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (AbortSet)
    Input
    Output
    Status
    Results
    Processes = {};%GrasppeAlpha.Occam.Process.empty; %eval([CLASS '.empty()']);
    Window = [];
    ProgressBars      = GrasppeAlpha.Occam.ProgressBar.empty();    
  end
  
  properties %(Transient, SetAccess=)
    ProcessProgress   = GrasppeAlpha.Occam.ProcessProgress.empty();
  end
  
  properties (Hidden)
    status
    permanent
    processListeners
  end
  
  properties (Hidden)
    COMPLETE_STATUS = 'Finished';
    EXECUTING_STATUS = 'Executing';
    TERMINATING_STATUS = 'Terminating';
    READY_STATUS = 'Ready';
    FAILED_STATUS = 'Failed';
    NO_ERRORS = 'No Errors';
    BYPASSED_STATUS = 'Bypassed';
  end
  
  events
    ExecutionComplete
    ExecutionFailed
    ExecutionStarted
    StatusChanged
    ProcessParametersChanged
    ProgrssChanged
  end
  
  %   methods (Abstract)
  %     %output = Run(obj);
  %   end
  
  methods
    
    function obj = Process()
      obj = obj@GrasppeAlpha.Occam.ProcessData();
      obj = obj@GrasppeAlpha.Core.Prototype();
      
      obj.ProcessProgress = GrasppeAlpha.Occam.ProcessProgress();
      
      obj.Type = class(obj);
      try
        typeName  = char(regexp(obj.Type, '(?=.)\w*$', 'match'));
      end

      instanceNumber = 1;
      try instanceNumber = GrasppeAlpha.Occam.Singleton.Get.Names.(typeName) + 1; end
      try GrasppeAlpha.Occam.Singleton.Get.Names.(typeName) = instanceNumber + 1; end
      
      obj.Name = [typeName int2str(instanceNumber)];
    end
    
    function set.Status(obj, value)
      obj.Status = value;
      % dispf('%s: %s', class(obj), toString(value));
      notify(obj, 'StatusChanged');
    end
    
    function output = Execute(obj, parameters, input)
      
      try obj.ProcessParameters = parameters; end; %if nargin > 1, try obj.Parameters = parameters; end; end
      
      if ~exist('input', 'var')
        if (isempty(obj.Input))
          try obj.Input = evalin('caller', 'output'); end
        end
        
        input     = obj.Input;
      end
      input     = obj.InitializeProcess(input);
      obj.Input = input;
      
      output = obj.Run;
      
      output = obj.TerminateProcess(output);
      obj.Output = output;
      
      if nargout < 1
        try assignin('caller', 'output', output); end
        clear output;
      end
      
      obj.Input = [];
    end
    
    function output = Run(obj)
      output = obj.Output;
    end
    
    function input = InitializeProcess(obj, input)
      % intput        = input;
      
      notify(obj, 'ExecutionStarted');
      
      try obj.Variables = input.Variables; end
            
      obj.Results = obj.NO_ERRORS;
      obj.Status  = obj.EXECUTING_STATUS;
    end
    
    function output = TerminateProcess(obj, output)
      output.Variables = obj.Variables;
      
      output      = output;
      obj.Status  = obj.TERMINATING_STATUS;
      switch obj.Results
        case obj.NO_ERRORS
          notify(obj, 'ExecutionComplete');
          obj.Status = obj.COMPLETE_STATUS;
        otherwise
          notify(obj, 'ExecutionFailed');
          obj.Status = obj.FAILED_STATUS;
      end
      
      h = obj.Window;
      if isempty(h), h = 0; end
      
      %try UI.setStatus('', h); end
    end
    
    function parameters = getProcessParameters(obj)
      parameters = obj.ProcessParameters;
    end
    
    function addProcess(obj, process)
      if (~isa(process, eval(NS.CLASS)))
        processorString = 'none';
        try processorString = toString(process); end
        error('Failed to add processor: %s', processorString);
      end
      
      callback = @(source, data) obj.processUpdate(source, data);
      
      try
        processListener = addlistener(obj, 'ExecutionComplete', callback);
        processListener = addlistener(obj, 'ExecutionFailed',   callback);
        processListener = addlistener(obj, 'ExecutionStarted',  callback);
        processListener = addlistener(obj, 'StatusChanged',     callback);
        processListener = addlistener(obj, 'ProcessParametersChanged', callback);
        processListener = addlistener(obj, 'ProgressChanged',   callback);
        
        obj.Processes{end+1} = processListener;
      catch err
        debugStamp(err,1);
      end
    end
    
    function processUpdate(obj, source, data)
      %switch data.EventName
      try
        
        h = obj.Window;
        if isempty(h), h = 0; end
        
        switch data.EventName
          case 'ExecutionComplete'
            string='';
            try
              if isequal(source.permanent, true)
                return;
              end
            end
          otherwise
            string = sprintf('%s: %s@%s', class(obj), data.EventName, class(source));
        end
        
        %UI.setStatus(string, h);
        
      end
    end
    
    function h = get.Window(obj)
      h = obj.Window;
      if isempty(h)
        h = get(0,'CurrentFigure');
      end
    end
    
  end
  
  
  %% Process Progress
  methods
    function UpdateProgressComponents(obj)
      if isempty(obj.ProcessProgress) || ~isa(obj.ProcessProgress, 'GrasppeAlpha.Occam.ProcessProgress') %isempty(obj.ProcessProgress)
        obj.ProcessProgress   = GrasppeAlpha.Occam.ProcessProgress;
      end
      
      if ~isempty(obj.View) && isa(obj.View, 'GrasppeAlpha.Occam.Process')
        
        if isempty(obj.View.ProgressBars) || ~isa(obj.View.ProgressBars, 'GrasppeAlpha.Occam.ProgressBar') %isempty(obj.ProcessProgress)
          obj.View.ProgressBars = GrasppeAlpha.Occam.ProgressBar;
        end
        
        progressBars = obj.View.ProgressBars;
        
        for m = 1:numel(progressBars)
          progressBar = progressBars(m);
          
          if isempty(progressBar.Parent) || ~ishandle(progressBar.Parent)
            progressBar.Parent  = obj.View.Window;
          end
          
          obj.ProcessProgress.addProgressListener(progressBar);          
          
          % callback = @(source, data) progressBar.progressUpdate(source, data);
          
          % progressListener    = addlistener(obj.ProcessProgress, 'ProgressChanged', callback);
        end
        
      end
    end
  end
  
end

