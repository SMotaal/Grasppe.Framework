classdef Module < Grasppe.Prototypes.Controller & Grasppe.Prototypes.Process
  %APPLICATION Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(SetAccess=immutable, Transient, GetAccess=public)
    Name
    Path
  end
  
  properties(SetAccess=protected, GetAccess=protected) %, GetAccess=protected)
    ModelClass
    ViewClass
    ControllerClass
    ParentController
  end
  
  properties(SetAccess=private, GetAccess=public)
    JavaClassPath
    JavaPaths       = {};
    ResourcePath
    ComponentPath
    Modules
  end
  
  properties
    Application    
  end
  
  methods
    function obj = Module(name, path, varargin)
      obj           = obj@Grasppe.Prototypes.Controller(varargin{:});
      
      % debugStamp('Constructing', 1, obj);
      
      %% Set the Name and Path
      % Assuming path to Parent Folder, @Class or @Class/...
      obj.Name      = regexprep(class(obj), '\w+\.','');
      if ~exist('path', 'var') || ~ischar(path) || isempty(path), path = obj.ClassPath; end
      obj.Path      = regexprep(path, '([\//:]$|[\//:]?@.*$)', '');
      
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
    function handlePropertyEvent(obj, src, evt)
      
      switch lower(src.Name)
        case 'status'
          obj.displayStatus();
        otherwise
          obj.handlePropertyEvent@Grasppe.Prototypes.Controller(src, evt);
      end
    end
    
  end
  
  
  methods(Access=protected)
    function privateSet(obj, propertyName, value)
      try
        if ~isequal(obj.(propertyName), value), obj.(propertyName) = value; end
      catch err
        obj.privateSet@Grasppe.Prototypes.Controller(propertyName, value);
      end
    end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      
      obj.initializePaths();
      
      obj.initialize@Grasppe.Prototypes.Controller;
      
      obj.initializeComponents();
      
      obj.createModules();
      
    end
    
    function module = createModule(obj, moduleName, moduleClass, varargin)
      if isfield(obj.Modules, moduleName)
        try delete(obj.Modules.(moduleName)); end
      end
      
      try
        module                    = feval(moduleClass, varargin{:});
        obj.Modules.(moduleName)  = module;
        obj.Modules.(moduleName).ParentController = obj;
      catch err
        try delete(module); end
        rethrow(err);
      end
    end
    
  end
  
  methods(Access=private)
    
    function initializePaths(obj)
      import(obj.Imports{:});
      
      obj.ResourcePath      =  Utilities.FindFolder(obj.Path, 'Resources');   %fullfile(obj.Path, 'Resources');
      obj.ComponentPath     =  Utilities.FindFolder(obj.Path, 'Components');  %fullfile(obj.Path, 'Components');
      obj.JavaClassPath     =  Utilities.FindFolder(obj.ComponentPath, 'Java');  %fullfile(obj.Path, 'Components');
      
      
      s = warning('off', 'MATLAB:Java:DuplicateClass');
      try
        %% ADDPATHS to MatLab Search Path
        addpath(obj.ResourcePath);  %fullfile(obj.Path, 'Resources'));
        addpath(obj.ComponentPath); %fullfile(obj.Path, 'Modules'));
        
        %% JAVAADDPATH to MatLab Search Path
        
        % javaaddpath(obj.JavaClassPath);
        
        jarPaths            = dir(fullfile(obj.JavaClassPath, '*.jar'));
        jarPaths            = strcat(obj.JavaClassPath, filesep, {jarPaths(:).name});
        javaPaths           = [{obj.JavaClassPath}, jarPaths];
        
        javaaddpath(javaPaths);
        
        obj.JavaPaths       = javaPaths;
      end
      warning(s);
      
    end
    
    function initializeComponents(obj)
      import(obj.Imports{:});
      
      %% Populate Component Classes
      for m = {'Model', 'View', 'Controller'}
        try
          if isempty(obj.([char(m) 'Class'])) || ~ischar(obj.([char(m) 'Class']))
            obj.([char(m) 'Class']) = [obj.ClassName char(m)];
          end
        catch err
          Grasppe.Prototypes.Utilities.StampError(err, 1, obj);
        end
      end      
      
      
      try
        % if isfield(obj, 'Controller')
        if exist(obj.ControllerClass, 'class')
          controller  = obj.initializeComponent('Controller', 'Module', obj);
        elseif isa(obj, 'Grasppe.Prototypes.Controller')
          controller  = obj;
        end
        %         if ~exist(obj.ControllerClass, 'class') && isa(obj, 'Grasppe.Prototypes.Controller')
        %           controller      = obj;
        %           obj.Controller  = controller;
        %         else
        %           controller = obj.initializeComponent('Controller', 'Module', obj);
        %         end
        % if isfield(obj, 'Model')
        
        if isa(controller, 'Grasppe.Prototypes.Controller') && isvalid(controller)
          obj.Controller.setModel(obj.initializeComponent('Model', 'Module', obj, 'Controller', controller));
          obj.Controller.setView(obj.initializeComponent('View',  'Module', obj, 'Controller', controller));
        end
        
      catch err
        Grasppe.Prototypes.Utilities.StampError(err, 1, obj);
        rethrow(err);
      end
      %obj.Controller.setView  = obj.initializeComponent('View',   'Controller', obj.Controller); %,   'Model', obj.Model);
      
      
    end
    
    function createModules(obj)
      controller            = obj.Controller;
      
      if ~isa(controller, 'Grasppe.Prototypes.Controller') || ~isvalid(controller), return; end
      
      modelProperties       = {controller.MetaClass.PropertyList(:).Name}; %properties(model);
           
      moduleClasses         = modelProperties(~cellfun(@isempty, regexp(modelProperties,'^.*ModuleClass$')));
      
      %% Populate Component Classes
      for m = 1:numel(moduleClasses) % {'Model', 'View', 'Controller'}
        try
          mClassProperty    = char(moduleClasses{m});
          mClass            = controller.(mClassProperty); % obj.Model.(mClassProperty);
          mProperty         = regexprep(mClassProperty, 'Class$', '');
          mName             = mProperty;
          
          try delete(controller.(mProperty)); end
          
          if ischar(mClass) && exist(mClass, 'class')>0
            mModule                 = obj.createModule(mName, mClass);
            controller.(mProperty)  = mModule;
          end
          
          % if isempty(obj.(mName)) || ~isobject(obj.(mName)) || ~isvalid(obj.(mName))
          %   feval(obj.(mProperty));
          % end
        catch err
          Grasppe.Prototypes.Utilities.StampError(err, 1, obj);
        end
      end      
    end
    
    function component = initializeComponent(obj, componentName, varargin)
      component               = [];
      try
        componentClass        = obj.([componentName 'Class']);
        if isempty(obj.(componentName)) || isequal(obj, obj.(componentName)) || ~isa(obj.(componentName), componentClass) || ~isvalid(obj.(componentName))
          if exist(componentClass, 'class')>0
            component           = feval(componentClass, varargin{:});
          end
          obj.(componentName) = component;
        end
        %component             = obj.(componentName);
      catch err
        Grasppe.Prototypes.Utilities.StampError(obj, 1, err);
      end
      
    end
    
    function getComponentPath(componentName)
      
    end
    
    
  end
  
end
