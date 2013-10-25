classdef Instance < GrasppeAlpha.Core.Prototypes.HandleClass
  %INSTANCE Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetAccess=immutable)
    ID
  end
  
  methods
    function obj = Instance(varargin)
      obj     = obj@GrasppeAlpha.Core.Prototypes.HandleClass(varargin{:});
       % debugStamp('Constructing', 1, obj);
     
      obj.ID  = GrasppeAlpha.Core.Prototypes.InstanceTable.RegisterInstance([], obj);
      
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
    end
    
%     function id = CreateInstanceRecord(obj)
%       id      = obj.ID;
%       if isempty(id)
%         id    = GrasppeAlpha.Core.Prototypes.InstanceTable.RegisterInstance([], obj);
%       end
%     end
    
%     function DeleteInstanceRecord(obj)
%       GrasppeAlpha.Core.Prototypes.InstanceTable.UnregisterInstance(obj.ID);
%     end
    
    function delete()
      try GrasppeAlpha.Core.Prototypes.InstanceTable.UnregisterInstance(obj.ID); end
    end
  end
  
end

