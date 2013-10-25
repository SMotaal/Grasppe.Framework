classdef Reader < GrasppeAlpha.Core.Component
  %READER Data Reader (Eventless)
  %   Detailed explanation goes here
  
  properties (GetAccess=public, SetAccess=protected)
    Data
    Parameters
    % State
  end
      
  methods
    function obj = Reader(varargin)
      obj = obj@GrasppeAlpha.Core.Component(varargin{:});
      obj.State                     = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
    end
  end
   
  methods (Access=protected)
    tf          = UpdateState(obj, mode, targetState, abortOnFail);
  end
    
  methods
    function data = get.Data(obj)
      %data = [];
      try obj.Data.DataReader = obj;        end
      try data                = obj.Data;   end
    end
  end
  
  
  %% Grasppe Prototype Methods
  methods (Access=protected)
    function createComponent(obj)
      obj.PrepareDataModels;
      
      componentOptions  = obj.getComponentOptions;
      parameters        = obj.DataParameters();
      
      if ~isempty(componentOptions) && ~isempty(parameters)
        for m = 1:numel(parameters)
          property      = parameters{m};
          idx           = find( strcmpi(property, componentOptions), 1, 'last');
          if isscalar(idx)
            value       = componentOptions{ idx  + 1};
            try if ~isequal(obj.(property),             value), obj.(property)            = value; end; end
            try if ~isequal(obj.Parameters.(property),  value), obj.Parameters.(property) = value; end; end
          end
        end
      end
      
      obj.createComponent@GrasppeAlpha.Core.Component;
    end
  end
  
  methods (Access = protected)
    
    %% State Routines
    
    function state = GetNamedState(obj, state)
      if ~exist('state', 'var') || ~ischar(state), state = '.';
      else state = [' ' state]; end
      
      error('Grasppe:State:NamesNotDefined', 'Cannot get named state %s', state);
    end
    
    function tf = PromoteState(obj, varargin)
      tf = obj.UpdateState('Promote', varargin{:});
    end
    
    function tf = DemoteState(obj, varargin)
      tf = obj.UpdateState('Demote', varargin{:});
    end
    
    function tf = CheckState(obj, varargin)
      tf = obj.UpdateState('Check', varargin{:});
    end
    
    
    function parameters = DataParameters(obj, parameter)
      parameters            = feval([class(obj) '.GetDataParameters']);
      
      if nargin>1 && iscellstr(parameters) && ~isempty(parameters)
        try
          parameters        = parameters(find(strcmpi(parameter, parameters), 1));
        catch err
          parameters        = '';
        end
      end
    end
    
    
  end
  
  methods (Hidden)
    function tf = TestState(obj, terminate)
      if exist('terminate', 'var') && isequal(terminate, true)
        tf = obj.UpdateState('stop test');
      else
        tf = obj.UpdateState('start test');
      end
    end
  end
  
  %% Grasppe Model Methods
  methods (Access=protected)
    
    function CreateDataModel(obj, field, class, varargin)
      obj.DeleteDataModel(field);
      obj.PrepareDataModel(field, class, varargin{:});
    end
    
    function DeleteDataModel(obj, field, condition)
      if ~exist('condition', 'var') || condition
        if isobject(obj.(field)), delete(obj.(field)); end
        obj.(field) = [];
      end
    end
    
    function PrepareDataModel(obj, field, class, varargin)
      if ~isa(obj.(field), class) || isempty(obj.(field))
        obj.(field) = feval(class, varargin{:});
      end
    end
    
    function PrepareDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.PrepareDataModel(modelFields{m}, obj.DataModels.(modelFields{m}));
      end
    end
    
    function DeleteDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.DeleteDataModel(modelFields{m});
      end
    end
    
    function CreateDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.CreateDataModel(modelFields{m}, obj.DataModels.(modelFields{m}));
      end
    end
    
  end
  
  methods (Abstract, Static)
    parameters =  GetDataParameters();
  end
  
end
