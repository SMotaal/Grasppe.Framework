classdef matlabException < MException
  %MATLABEXCEPTION Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj = matlabException(internalID, customID, varargin)
      err                   = [];
      try error(message(internalID, varargin{:})); catch err; end

      if ~exist('customID', 'var') || isempty(customID) || ~ischar(customID)
        customID = regexprep(internalID, '^\w*', 'Grasppe');
      end
      
      obj = obj@MException(customID, err.message);
    end
    
  end
  
  methods (Static)
    function obj = WithCause(internalID, customID, cause, varargin)
      obj = feval(mfilename('class'), internalID, customID, varargin{:});
      
      try obj = addCause(obj, cause); end
    end
  end
  
end

