classdef Model < GrasppeAlpha.Core.Prototype & matlab.mixin.Copyable
  %MODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Models
    Creator
  end
  
  properties (Dependent)
    CreatorID
  end
  
  methods
    
    function obj = Model(varargin)
      obj = obj@GrasppeAlpha.Core.Prototype;
      
      obj.initializeModel;
      
      % disp(class(obj));
      GrasppeAlpha.Core.Model.ModelRecord(obj);
      
      if (nargin > 0), obj.setOptions(varargin{:}); end
    end
    
    function initializeModel(obj)
      
    end
    
    function id = get.CreatorID(obj)
      id = [];
      try
        if isa(obj.Creator, 'GrasppeAlpha.Core.Model')
          id = obj.Creator.CreatorID;
        else
          id = obj.Creator.ID;
        end
      end
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
        debugStamp(err, 1, obj);
      end
      
    end    
    
    
    function tf = eq(a,b)
      tf = false;
      
      if ~isequal(size(a), size(b)),        return; end
      if ~isequal(class(a), class(b)),      return; end
      
      fields = fieldnames(a);
      
      for m = 1:numel(fields)
        field = fields{m};
        if ~isequal(a.(field), b.(field)),  return; end
      end
      
      tf = true;
    end
    
    %function tf = ne(a,b)
    %  tf = ~(a==b);
    %end    
    
    function tf = Compare(a, b, field)
      tf      = false;
      
      if nargin>2
        try tf  = isequal(a.(field), b.(field)); end
      else
        tf = a==b;
      end
    end
    
  end
  
  methods (Access = protected)
    % Override copyElement method:
    function cpObj = copyElement(obj)
      % Make a shallow copy of all shallow properties
      cpObj = copyElement@matlab.mixin.Copyable(obj);
      
      % Make a deep copy of the deep object
      % cpObj.DeepObj = copy(obj.DeepObj);
    end
    
    function [names values] = setOptions(obj, varargin)
      
      [names values paired pairs] = obj.parseOptions(varargin{:});
      
      if (paired)
        for i=1:numel(names)
          try
            if ~isequal(obj.(names{i}), values{i})
              obj.(names{i}) = values{i};
            end
          catch err
            if ~strcontains(err.identifier, 'noSetMethod')
              try debugStamp(obj.ID, 5); end
              % disp(['Could not set ' names{i} ' for ' class(obj) '. ' err.message]);
            end
          end
        end
      end
      
    end
    
    function [names values paired pairs] = parseOptions(obj, varargin)
      
      names        = varargin;
      extraArgs   = {};
      
      %% Parse Lead Structures
      while (~isempty(names) && isstruct(names{1}))
        stArgs    = structArgs(names{1});
        extraArgs = [extraArgs stArgs]; %#ok<*AGROW>
        
        if length(names)>1
          names = names(2:end);
        else
          names = {};
        end
        
      end
      
      names = [extraArgs, names];
      
      [pairs paired names values ] = pairedArgs(names{:});
      
    end
    
  end
  
  methods(Hidden, Static)
    function models = ModelRecord(model)
      models = [];
      
      persistent instances
      if nargin==1
        if isnumeric(model)
          try models = instances(model); end
        elseif isa(model, 'GrasppeAlpha.Core.Model')
          record = struct('Model', model);
          if isempty(instances)
            instances = record;
          else
            instances(end+1) = record;
          end
        end
      else
        if nargout==1
          models = instances;
        end
      end
      
      
    end
  end
  
end

