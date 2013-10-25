classdef (ConstructOnLoad) UDDModel < GrasppeAlpha.Core.Model
  %UDDMODEL Custom UDD-Based Model Data Objects
  %   Detailed explanation goes here
  
  properties (SetAccess='immutable', GetAccess='private')
    packageName            = [];
    className              = [];
    
    userTypeTable         = {
      %       'PositiveNumeral',      'double',           @(x)x(:); %assert(x>=0, error('Grasppe:PositiveNumeral', 'Value must be zero or a positive number'));
      }
    
    enumTypeTable         = {
      %       'one/two/three',        {'one', 'two', 'three'};
      };
    
    propertyTable          = {
      %       'Name',                 'string',           'Define the name of the model';
      };
    
    defaultsTable          = {
      %       'Index',                1;
      };
    
    propertyAttributes     = {
      %      'Prototype',        {'Hidden'}
      };    
  end
    
  properties (SetAccess=immutable, Transient)
    InstanceID
  end  
  
  properties (SetAccess='private', GetAccess='private', Transient)
    packageSchema
    classSchema
    propertySchema
    userTypeSchema
    enumTypeSchema
    uddPropertyListeners
    uddChildrenListeners
  end
  
  properties(GetAccess=public, SetAccess=public)
    ModelClass;
    ModelData;
  end
  
  events
    PropertyChanged
  end
  
  methods
    
    function obj = UDDModel(varargin)
      global debugConstructing;
      
      initializeSchema        = true;
      % sObj                    = [];
      
      loadingObject           = nargin>0 && isstruct(varargin{1}) && all(isfield(varargin{1}, {'ID', 'Class', 'Schema', 'Model'}));
      
      if loadingObject
        sObj                  = varargin{1};
        options               = [varargin, {'InstanceID'}, {sObj.InstanceID}];
      else
        options               = varargin; % {}; %varargin;
      end
      
      obj                     = obj@GrasppeAlpha.Core.Model(options{:});
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 1, obj); end
      
      if loadingObject %isstruct(sObj) % && isfield(sObj, {'ID', 'Class', 'Schema', 'Model'})
        try
          for m = 1:2:numel(sObj.Schema)
            obj.(sObj.Schema{m})      = sObj.Schema{m+1};
          end
          initializeSchema    = false;
        catch err
          debugStamp(err, obj);
          % Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        end
      end
      
      if initializeSchema
        obj.packageName      = obj.getUDDProperty('packageName');
        obj.className        = obj.getUDDProperty('className');
        obj.userTypeTable   = obj.getUDDProperty('userTypeTable');
        obj.enumTypeTable   = obj.getUDDProperty('enumTypeTable');
        obj.propertyTable    = obj.getUDDProperty('propertyTable');
        obj.defaultsTable    = obj.getUDDProperty('defaultsTable');
      end
      
      try
        obj.defineModelSchema();
        
        % if numel(
        
      catch err
        debugStamp(err, obj);
        % Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        beep;
      end
      
      
      modelData               = obj.ModelData;
      
      if isempty(modelData) || iscell(modelData)
        obj.ModelData         = feval(obj.ModelClass);
      end
      
      if iscell(modelData)
        for m = 1:2:numel(modelData)
          obj.ModelData.(modelData{m}) = modelData{m+1};
        end
      end
      
      for m = 1:numel(obj.propertyTable(:,1)) %fieldnames(obj.ModelData))
        try
          fieldName             = obj.propertyTable{m,1};
          fieldSchema           = obj.ModelData.findprop(fieldName);
          
          hl = handle.listener(obj.ModelData, fieldSchema, 'PropertyPostSet', @obj.notifyUDDPropertyChanged);
          if isempty(obj.uddPropertyListeners)
            obj.uddPropertyListeners = hl;
          else
            obj.uddPropertyListeners(end+1) = hl;
          end
          
          %           if isequal(fieldSchema.DataType, 'com.mathworks.jmi.bean.UDDObject')
          %             hl = obj.ModelData.(fieldName).Prototype.addlistener('PropertyChanged', @obj.notifyUDDPropertyChanged); %hl = handle.listener(obj.ModelData, fieldSchema, 'PropertyPostSet', @obj.notifyUDDPropertyChanged);
          %             if isempty(obj.uddChildrenListeners)
          %               obj.uddChildrenListeners = hl;
          %             else
          %               obj.uddChildrenListeners(end+1) = hl;
          %             end
          %           end
        catch err
          debugStamp(err, obj);
          % Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        end
      end
      
      %       if loadingObject % isstruct(sObj)
      %         try % for m = 1:2:numel(sObj.Model), field = sObj.Model{m}; value = sObj.Model{m+1}; obj.ModelData.(field) = value; end
      %           %disp(get(sObj.Model{end}))
      %
      %           for m = 1:2:numel(sObj.Model)
      %             obj.ModelData.(sObj.Model{m}) = sObj.Model{m+1};
      %           end
      %           %set(obj.ModelData, sObj.Model{:});
      %         catch err
      %           Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
      %         end
      %       else
      %       end
      
      obj.ModelData.Prototype = obj;
      
      % obj.initialize();
    end
    
    function notifyUDDPropertyChanged(obj, src, evt, varargin)
      evt = get(evt);
      %evt.AffectedObject = obj;
      obj.notify('PropertyChanged', evt); % Grasppe.Prototypes.Events.Data(obj, 'PropertyChanged', evt));
    end
    
    
    function inspect(obj)
      if isa(obj.ModelData, obj.ModelClass)
        inspect(obj.ModelData);
      else
        evalin('caller', ['openvar(''' inputname(1) ''')']); 	%openVariableEditor('obj');
      end
      
    end
    
    function modelClass = get.ModelClass(obj)
      modelClass = [obj.packageName '.' obj.className];
    end
    
    function delete(obj)
      try delete(obj.ModelData); end
    end
    
    function obj = saveobj(obj)
      try
        obj = GrasppeAlpha.Data.Models.UDDModel.UDDModel2Struct(obj);
      catch err
        debugStamp(err, obj);
        % Grasppe.Kit.Utilities.DisplayError(obj, 1, err);end
      end
      return;
      
    end
    
    
    function onPropertyChanged(obj, src, evt)
      disp(class(evt.AffectedObject));
      disp(evt);
      disp(evt.SourceData);
    end
  end
  
  methods(Static)
    function obj = loadobj(sObj)
      
      if isstruct(sObj)
        
        debugStamp(['Loading ' sObj.Class], 1);
        
        obj                   = GrasppeAlpha.Data.Models.UDDModel.Struct2UDDModel(sObj);
        
      end
    end
    
    function uddObj = NewUDDModel(className, varargin)
      obj                     = GrasppeAlpha.Data.Models.UDDModel.NewModel(className, varargin{:});
      uddObj                  = obj.ModelData;
    end
    
    function obj = NewModel(classname, varargin)
      try % if ~iscarh(classname) || isempty(classname), error('Grasppe:Prototype:GenericModelClass', 'No class specified for the model. Constructing a generic UDDModel object instead.'); end
        obj                   = feval(classname, varargin{:});
      catch err
        obj                   = feval(mfilename('class'), varargin{:});
      end
    end
    
    function st = UDDModel2Struct(obj)
      s                       = warning('off', 'MATLAB:structOnObject');
      sObj                    = struct(obj);
      warning(s);
      
      %% Identifier and MatLab Class
      
      st                      = struct;
      st.ID                   = sObj.idBase;
      st.Class                = class(obj);
      st.Format               = 'Grasppe:UDDModel:R1';
      
      debugStamp(['Serializing ' obj.InstanceID], 1);
      
      %% UDD Schema
      
      schemaFields            = {
        'packageName', 'className', ...
        'userTypeTable', 'enumTypeTable', 'propertyTable', 'defaultsTable'
        };
      
      schemaValues            = cell(1, numel(schemaFields));
      for m = 1:numel(schemaFields)
        schemaValues{m}       = obj.getUDDProperty(schemaFields{m});
      end
      
      st.Schema               = cell(1, numel(schemaFields)*2);
      st.Schema(1:2:end)      = schemaFields;
      st.Schema(2:2:end)      = schemaValues;
      
      %% ModelData
      
      modelFields             = sObj.propertyTable(:,1)';
      modelValues             = cell(1, numel(modelFields));
      
      try
        
        for m = 1:numel(modelFields)
          propertyName          = modelFields{m};
          propertySchema        = findprop(obj.ModelData, propertyName); %%'PressDetails');
          
          isUDDModel            = isequal(propertySchema.DataType, 'com.mathworks.jmi.bean.UDDObject');
          
          if isUDDModel
            uddModelObj         = obj.(propertyName).Prototype;
            modelValues{m}      = GrasppeAlpha.Data.Models.UDDModel.UDDModel2Struct(uddModelObj);
          else
            modelValues{m}      = obj.ModelData.(propertyName);
          end
        end
        
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        beep;
      end
      
      st.Model                = cell(1, numel(modelFields)*2);
      st.Model(1:2:end)       = modelFields;
      st.Model(2:2:end)       = modelValues;
      
    end
    
    function obj = Struct2UDDModel(st)
      if isfield(st, 'Format') && isequal(st.Format, 'Grasppe:UDDModel:R1')
        
        debugStamp(['Reconstructing ' st.ID], 1);
        
        modelFields           = st.Model(1:2:end);
        modelValues           = st.Model(2:2:end);
        
        for m = 1:numel(modelFields);
          fieldName           = modelFields{m};
          fieldValue          = modelValues{m};
          if isstruct(fieldValue) && isfield(fieldValue, 'Format') && isequal(fieldValue.Format, 'Grasppe:UDDModel:R1')
            uddModelObj       = Grasppe.Prototypes.Models.UDDModel.Struct2UDDModel(fieldValue);
            modelValues{m}    = uddModelObj.ModelData;
          end
        end
        
        newModel              = st.Model;
        newModel(2:2:end)     = modelValues;
        
        %% Initialize Prototype UDDModel
        obj                   = Grasppe.Prototypes.Models.UDDModel.NewModel(st.Class, 'InstanceID', st.ID, 'ModelData', newModel);
        modelData             = obj.ModelData;
        
        %         %% Populate Model Data
        %         for m = 1:numel(modelFields);
        %           fieldName           = modelFields{m};
        %           fieldValue          = modelValues{m};
        %           if isstruct(fieldValue) && isfield(fieldValue, 'Format') && isequal(fieldValue.Format, 'Grasppe:UDDModel:R1')
        %             uddModelObj       = Grasppe.Prototypes.Models.UDDModel.Struct2UDDModel(fieldValue);
        %             fieldValue        = uddModelObj.ModelData;
        %             modelData.(fieldName) = uddModelObj.ModelData;
        %           else
        %             obj.(fieldName)     = fieldValue;
        %           end
        %         end
        
      else
        obj                   = st;
      end
    end
  end
  
  methods (Access=protected)
    defineModelSchema(obj);
    
    function value = getUDDProperty(obj, name)
      value = [];
      try
        property        = findprop(obj, name);
        value           = property.DefaultValue;
      end
    end
  end
  
  
  methods (Access=protected, Sealed)
    function initialize(obj)
      obj.notify('Initializing');
      obj.initialize@Grasppe.Prototypes.Components.Model;
      obj.notify('Initialized');
    end
  end
  
end

