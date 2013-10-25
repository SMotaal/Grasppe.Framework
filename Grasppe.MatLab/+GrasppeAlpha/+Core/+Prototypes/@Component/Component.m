classdef Component < GrasppeAlpha.Core.Prototypes.Instance
  %COMPONENT Instance Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    Model
    View
    Controller
    EventListeners          = struct();
    PropertyEventListeners  = struct();
  end
  
  methods
    
    function obj = Component(varargin)
      obj     = obj@GrasppeAlpha.Core.Prototypes.Instance(varargin{:});
      
      % debugStamp('Constructing', 1, obj);
      % if isequal(mfilename, obj.ClassName), obj.initialize(); end
      
    end
      
end

