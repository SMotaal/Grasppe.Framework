classdef Instance < Grasppe.Prototypes.Handle % (ConstructOnLoad)
  %INSTANCE Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetAccess=immutable, Transient)
    InstanceID
  end
  
  properties(SetAccess=private, GetAccess=protected, Transient, Hidden) %, GetAccess=protected)
    isAlive = true;
    isRegistered = false;
  end
  
  properties(SetAccess=private, GetAccess=private)
    idBase
    instanceOptions
  end
    
  properties(SetAccess=private, GetAccess=private, Transient)    
    idIndex
  end
  
  
  methods
    function obj = Instance(varargin)
      instanceID              = [];
      instanceOptions         = varargin;
           
      try
        idIndex               = find(strcmp(instanceOptions, 'InstanceID'),1,'last');
        if isscalar(idIndex)
          instanceID          = instanceOptions{idIndex+1};
          instanceOptions     = [instanceOptions(1:idIndex-1) instanceOptions(idIndex+2:end)];
        end
      end
      
      obj                     = obj@Grasppe.Prototypes.Handle(instanceOptions{:});
      obj.isAlive             = true;
      
      
      if ~obj.isRegistered
        try
          [id base idx]         = Grasppe.Prototypes.Utilities.InstanceTable.RegisterInstance(instanceID, obj, obj.idBase, obj.idIndex);
          
          obj.InstanceID        = id;
          obj.idBase            = base;
          obj.idIndex          = idx;
          
          obj.isRegistered      = true;
        end
      end
      
        obj.instanceOptions  = varargin;
    end
        
    function delete(obj)
      if ~isequal(obj.isAlive,true), return; end  % obj.isAlive = false;  debugStamp(['Deleting ' class(obj)], 5);
      
      if isvalid(obj)
        obj.isAlive           = false;
        debugStamp(['Deleting@' obj.ClassName], 5, obj);
        try Grasppe.Prototypes.Utilities.InstanceTable.UnregisterInstance(obj.InstanceID); end
      end
    end
    

  end  
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.Handle;
    end
  end
end

