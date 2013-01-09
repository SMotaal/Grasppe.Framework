classdef Model < Grasppe.Prototypes.Handle  & matlab.mixin.Copyable & hgsetget
  %MODEL Model Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj=Model(varargin)
      obj@Grasppe.Prototypes.Handle(varargin{:});
    end
    
    function st = asStruct(obj)
      thisClass               = mfilename('class');
      st                      = struct;
      
      S                       = warning('off', 'MATLAB:structOnObject');
      objSt                   = struct(obj);
      warning(S);
      
      
      fieldNames              = fieldnames(obj);
      
      try
        for m = 1:numel(fieldNames)
          fieldName           = fieldNames{m};
          fieldValue          = {};
          
          if isfield(objSt, fieldName)
            fieldValue        = {objSt(:).(fieldName)};
          else
            try fieldValue    = {obj.(fieldName)}; end
          end
          
          if numel(fieldValue) == 1
            st.(fieldName)    = fieldValue{1};
          else
            st(:).(fieldName) = fieldValue;
          end
        end
        
      catch err
        debugStamp(err, 1);
      end
      
    end
    
    
  end
  
end

