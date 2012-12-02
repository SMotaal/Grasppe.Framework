classdef Instance < Grasppe.Prototypes.HandleClass
  %INSTANCE Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetAccess=immutable, Transient)
    ID
  end
  
  properties(SetAccess=private, GetAccess=protected) %, GetAccess=protected)
    isAlive = true;
  end
  
  
  methods
    function obj = Instance(varargin)
      obj     = obj@Grasppe.Prototypes.HandleClass(varargin{:});
      % debugStamp('Constructing', 1, obj);

      obj.ID  = Grasppe.Prototypes.InstanceTable.RegisterInstance([], obj);
      
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end      
    end
    
    function delete(obj)
      obj.isAlive = false;
      debugStamp(['Deleting@' obj.ClassName], 1, obj);
      try Grasppe.Prototypes.InstanceTable.UnregisterInstance(obj.ID); end
    end

  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.HandleClass;
    end
  end
end

