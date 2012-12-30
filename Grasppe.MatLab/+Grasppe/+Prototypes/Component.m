classdef Component < Grasppe.Prototypes.Instance
  %COMPONENT Instance Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(SetAccess=public, GetAccess=public, Transient) %, GetAccess=protected)
    Model
    View
    Controller
    Module
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
      if isa(obj, 'Grasppe.Prototypes.Model')
        % if isa(obj, 'Grasppe.Prototypes.UDDModel'), model = obj.ModelData; end
        model = obj;
      else
        model         = obj.Model;
        try model     = obj.Controller.Model; end
      end
    end
    
    function view = get.View(obj)
      if isa(obj, 'Grasppe.Prototypes.View')
        view = obj;
      else
        view          = obj.View;
        try view      = obj.Controller.View; end
      end
    end
    
    function controller = get.Controller(obj)
      if ~isa(obj.Controller, 'Grasppe.Prototypes.Controller') && ...
          isa(obj, 'Grasppe.Prototypes.Controller')
        controller = obj;
      else
        controller = obj.Controller;
      end
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
    
    function set.Module(obj, module)
      obj.Module      = module;
      
      if isa(module, 'Grasppe.Prototypes.Module')
        moduleProperties = {'ResourcePath', 'ComponentPath', 'Modules'};
        for m = 1:numel(moduleProperties)
          try
            p           = addprop(obj, moduleProperties{m});
            p.GetMethod = @(obj)obj.Module.(moduleProperties{m});
          catch err
            debugStamp(err, 1, obj);
          end
        end
      end
    end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      
      obj.initialize@Grasppe.Prototypes.Instance;
      
    end
    
%     function privateSet(obj, propertyName, value)
%       try
%         if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
%       catch err
%         obj.privateSet@Grasppe.Prototypes.Instance(propertyName, value);
%       end
%     end
    
    function initializeModel(obj)
    end
    
    function initializeView(obj)
    end    
    
    function initializeController(obj)
    end    
    
  end
  
end

