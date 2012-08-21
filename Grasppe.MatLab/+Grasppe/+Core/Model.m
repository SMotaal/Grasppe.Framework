classdef Model < Grasppe.Core.Prototype & matlab.mixin.Copyable
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
      obj = obj@Grasppe.Core.Prototype;
      
      obj.initializeModel;
      
      % disp(class(obj));
      Grasppe.Core.Model.ModelRecord(obj);
      
      if (nargin > 0), obj.setOptions(varargin{:}); end
    end
    
    function initializeModel(obj)
      
    end
    
    function id = get.CreatorID(obj)
      id = [];
      if isa(obj.Creator, 'Grasppe.Core.Model')
        try id = obj.Creator.CreatorID; end
      else
        try id = obj.Creator.ID; end
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
              disp(['Could not set ' names{i} ' for ' class(obj) '. ' err.message]);
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
        elseif isa(model, 'Grasppe.Core.Model')
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

