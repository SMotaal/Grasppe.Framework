classdef Application < Grasppe.Prototypes.Module
  %APPLICATION Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
   
  properties(SetAccess=private, GetAccess=public)
    LaunchPath
  end
  
  properties(Dependent, SetAccess=private, GetAccess=public)
    ApplicationPath
  end
  
  properties(SetAccess=private, GetAccess=private)
    arguments
    result
  end
  
  
  events
    Launching             % Execute after Application has Initialized
    Running               % Execute after Application has Launched
    Idle                  % Execute when Application is Paused
    Terminating           % Execute when Application is Quitting
  end
  
  methods
    function obj = Application(name, varargin)
      global debugConstructing;
      
      obj                 = obj@Grasppe.Prototypes.Module(name, [], varargin{:});
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 1, obj); end
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
    function handlePropertyEvent(obj, src, evt)
      switch lower(src.Name)
        case 'status'
          obj.displayStatus();
        otherwise
          obj.handlePropertyEvent@Grasppe.Prototypes.Module(src, evt);
      end
    end
    
    function onInitialized(obj, src, evt)
      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
      
      % obj.result = obj.main(obj.arguments);
    end    
    
    onLaunching(obj, src, evt);
    onRunning(obj, src, evt);
    onIdle(obj, src, evt);
    onTerminating(obj, src, evt);
    
    %     function modulePath = get.ComponentPath(obj)
    %       modulePath    = fullfile(obj.Path, 'Components');
    %     end
    
    function applicationPath = get.ApplicationPath(obj)
      applicationPath = obj.Path;
    end
    
    function delete(obj)
      obj.State = 'Terminating';
      obj.notify('Terminating');
      obj.State = 'Terminated';
    end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.Module;
      % try obj.Model.Application = obj; end
      obj.LaunchPath      = pwd;
    end
    
    function privateSet(obj, propertyName, value)
      try
        if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
      catch err
        obj.privateSet@Grasppe.Prototypes.Instance(propertyName, value);
      end
    end
    
  end
  
  methods (Static, Abstract)
    result = main(obj, varargin);
  end
  
  
end
