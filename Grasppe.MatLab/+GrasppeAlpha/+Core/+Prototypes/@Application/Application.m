classdef Application < GrasppeAlpha.Core.Prototypes.Component
  %APPLICATION Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(SetAccess=immutable, Transient)
    Name
  end
  
  properties(SetObservable)
    Status          = '';
    Progress        = [];
  end
  
  events
    StatusChange
    ProgressChange
  end
  
  methods
    function obj = Application(name, varargin)
      obj           = obj@GrasppeAlpha.Core.Prototypes.Component(varargin{:});
      obj.Name      = regexprep(class(obj), '\w+\.','');
      
      % debugStamp('Constructing', 1, obj);
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
    function handlePropertyEvent(obj, src, evt)
      
      switch lower(src.Name)
        case 'status'
          obj.displayStatus();
        otherwise
          obj.handlePropertyEvent@GrasppeAlpha.Core.Prototypes.Component(src, evt);
      end
    end
    
    
  end
  
  methods(Access=private)
    function initialize(obj)
      debugStamp('Initializing', 1, obj);
    end
  end
  
end
