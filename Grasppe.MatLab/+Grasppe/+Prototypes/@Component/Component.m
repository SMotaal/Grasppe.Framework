classdef Component < Grasppe.Prototypes.Instance
  %COMPONENT Instance Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(SetAccess=protected, GetAccess=public) %, GetAccess=protected)
    Model
    View
    Controller
  end
  
  events
    Initializing
    Initialized
    Finalizing
  end
  
  
  methods
    
    function obj = Component(varargin)
      obj     = obj@Grasppe.Prototypes.Instance(varargin{:});
      
      obj.notify('Initializing');
      % debugStamp('Constructing', 1, obj);
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
    function model = get.Model(obj)
      model         = obj.Model;
      try model     = obj.Controller.Model; end
    end
    
    function view = get.View(obj)
      view          = obj.View;
      try view      = obj.Controller.View; end
    end
    
    function controller = get.Controller(obj)
      controller    = obj.Controller;
    end
    
    function set.Model(obj, model)
      obj.Model       = model;
      obj.initializeModel;
    end
    
    function set.View(obj, view)
      obj.View        = view;
      obj.initializeView;
    end
    
    function set.Controller(obj, controller)
      obj.Controller  = controller;
      obj.initializeController;
    end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      
      obj.initialize@Grasppe.Prototypes.Instance;
      
    end
    
    function privateSet(obj, propertyName, value)
      try
        if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
      catch err
        obj.privateSet@Grasppe.Prototypes.Instance(propertyName, value);
      end
    end
    
    function initializeModel(obj)
    end
    
    function initializeView(obj)
    end    
    
    function initializeController(obj)
    end    
    
  end
  
end

