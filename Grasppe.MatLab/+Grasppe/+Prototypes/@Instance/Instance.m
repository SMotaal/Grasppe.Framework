classdef (ConstructOnLoad) Instance < Grasppe.Prototypes.HandleClass
  %INSTANCE Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetAccess=immutable, Transient)
    ID
  end
  
  properties(SetAccess=private, GetAccess=protected, Transient, Hidden) %, GetAccess=protected)
    isAlive = true;
  end
  
  properties(SetAccess=private, GetAccess=private)
    id_base
    instance_options
  end
    
  properties(SetAccess=private, GetAccess=private, Transient)    
    id_index
  end
  
  
  methods
    function obj = Instance(varargin)
      instanceID              = [];
      instanceOptions         = varargin;
      try
        idIndex               = find(strcmp(instanceOptions, 'ID'),1,'last');
        if isscalar(idIndex)
          instanceID          = instanceOptions{idIndex+1};
          instanceOptions     = [instanceOptions(1:idIndex-1) instanceOptions(idIndex+2:end)];
        end
      end
      
      obj                     = obj@Grasppe.Prototypes.HandleClass(instanceOptions{:});
      obj.isAlive             = true;
      
      [id base idx]           = Grasppe.Prototypes.InstanceTable.RegisterInstance(instanceID, obj);
      
      obj.ID                  = id;
      obj.id_base             = base;
      obj.id_index            = idx;
      obj.instance_options    = varargin;
    end
        
    function delete(obj)
      if ~isequal(obj.isAlive,true), return; end  % obj.isAlive = false;  debugStamp(['Deleting ' class(obj)], 5);
      
      if isvalid(obj)
        obj.isAlive           = false;
        debugStamp(['Deleting@' obj.ClassName], 5, obj);
        try Grasppe.Prototypes.InstanceTable.UnregisterInstance(obj.ID); end
      end
    end
    

  end  
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.HandleClass;
    end
  end
end

