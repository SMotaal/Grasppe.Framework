classdef DataParameters < GrasppeAlpha.Core.Model
  %SAMPLEDATAPARAMETERS Case, Set, Sample, Variable Details
  %   Detailed explanation goes here
  
  properties (SetAccess=protected, GetAccess=protected)
    caseID
    setID
    variableID
    sampleID
  end
  
  methods
    function obj = DataParameters(varargin)
      obj = obj@GrasppeAlpha.Core.Model(varargin{:});
    end    
  end
  
end

