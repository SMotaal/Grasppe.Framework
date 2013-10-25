classdef Model < Grasppe.Prototypes.Handle  & matlab.mixin.Copyable & hgsetget & dynamicprops
  %MODEL Model Superclass for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties(Hidden, SetAccess=immutable)
    dynamicSignature
  end
  
  properties(Hidden, Dependent)
    DynamicSignature
  end
  
  methods
    function obj=Model(varargin)
      obj@Grasppe.Prototypes.Handle(varargin{:});
      
      dynamicSignature        = getappdata(obj, 'DynamicSignature');
      
      staticArchtype          = ['$' class(obj)];
      
      newSignature            = struct('Archetype' , staticArchtype);
      
      if iscell(dynamicSignature)
        if mod(numel(dynamicSignature), 2)==1 && ischar(dynamicSignature{1})
          newSignature.Archetype  = regexprep(dynamicSignature{1}, '^[^(A-Za-z)]|[^\w\.]*|(\.)*$|(?<=\.)[^A-Za-z]*\.|(?<=\.)[^A-Za-z]+', '');
          dynamicSignature    = dynamicSignature(2:end);
        end
        
        newSignature.Properties   = dynamicSignature;
      end
      
      if isstruct(newSignature) && isfield(newSignature, 'Properties') && iscell(newSignature.Properties) %&& ~isempty(obj.dynamicSignature)
        dynamicProperties     = newSignature.Properties;
        newProperties         = struct;
        for i=1:2:length(newSignature)
          try
            propertyName        = newSignature{i};
            propertyHandle      = addprop(obj,propertyName);
            propertyValue       = newSignature{i+1};
            obj.(propertyName)  = propertyValue;
            newProperties.(propertyName)  = propertyHandle;
          end
        end
        newSignature.Properties = newProperties;
      else
        try
          newSignature          = rmfield(newSignature, 'Properties');
        end
      end
      
      obj.dynamicSignature      = newSignature;
      
      %if isempty(obj.dynamicSignature), obj.dynamicSignature = false; end
    end
    
    function set.DynamicSignature(obj, dynamicSignature)
      if isempty(obj.dynamicSignature), setappdata(obj, 'DynamicSignature', dynamicSignature); end
    end
    
    function dynamicSignature = get.DynamicSignature(obj)
      dynamicSignature        = obj.dynamicSignature;
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

