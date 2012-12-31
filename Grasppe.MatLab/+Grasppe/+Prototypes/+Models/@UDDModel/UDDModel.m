classdef (ConstructOnLoad) UDDModel < Grasppe.Prototypes.Components.Model
  %UDDMODEL Custom UDD-Based Model Data Objects
  %   Detailed explanation goes here
  
  properties (SetAccess='immutable', GetAccess='private')
    package_name            = [];
    class_name              = [];
    
    user_type_table         = {
      %       'PositiveNumeral',      'double',           @(x)x(:); %assert(x>=0, error('Grasppe:PositiveNumeral', 'Value must be zero or a positive number'));
      }
    
    enum_type_table         = {
      %       'one/two/three',        {'one', 'two', 'three'};
      };
    
    property_table          = {
      %       'Name',                 'string',           'Define the name of the model';
      };
    
    defaults_table          = {
      %       'Index',                1;
      };
    
    property_attributes     = {
      %      'Prototype',        {'Hidden'}
      };
    
  end
  
  properties (SetAccess='private', GetAccess='private', Transient)
    package_schema
    class_schema
    property_schema
    user_type_schema
    enum_type_schema
    udd_property_listeners
    udd_children_listeners
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
      initializeSchema        = true;
      % sObj                    = [];
      
      loadingObject           = nargin>0 && isstruct(varargin{1}) && all(isfield(varargin{1}, {'ID', 'Class', 'Schema', 'Model'}));
      
      if loadingObject
        sObj                  = varargin{1};
        options               = [varargin, {'InstanceID'}, {sObj.InstanceID}];
      else
        options               = varargin; % {}; %varargin;
      end
      
      obj                     = obj@Grasppe.Prototypes.Components.Model(options{:});
      
      debugStamp('Constructing', 1, obj);
      
      if loadingObject %isstruct(sObj) % && isfield(sObj, {'ID', 'Class', 'Schema', 'Model'})
        try
          for m = 1:2:numel(sObj.Schema)
            obj.(sObj.Schema{m})      = sObj.Schema{m+1};
          end
          initializeSchema    = false;
        catch err
          debugStamp(err, 1, obj);
        end
      end
      
      if initializeSchema
        obj.package_name      = obj.getUDDProperty('package_name');
        obj.class_name        = obj.getUDDProperty('class_name');
        obj.user_type_table   = obj.getUDDProperty('user_type_table');
        obj.enum_type_table   = obj.getUDDProperty('enum_type_table');
        obj.property_table    = obj.getUDDProperty('property_table');
        obj.defaults_table    = obj.getUDDProperty('defaults_table');
      end
      
      try
        obj.defineModelSchema();
        
        % if numel(
        
      catch err
        debugStamp(err, 1, obj);
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
      
      for m = 1:numel(obj.property_table(:,1)) %fieldnames(obj.ModelData))
        try
          fieldName             = obj.property_table{m,1};
          fieldSchema           = obj.ModelData.findprop(fieldName);
          
          hl = handle.listener(obj.ModelData, fieldSchema, 'PropertyPostSet', @obj.notifyUDDPropertyChanged);
          if isempty(obj.udd_property_listeners)
            obj.udd_property_listeners = hl;
          else
            obj.udd_property_listeners(end+1) = hl;
          end
          
          %           if isequal(fieldSchema.DataType, 'com.mathworks.jmi.bean.UDDObject')
          %             hl = obj.ModelData.(fieldName).Prototype.addlistener('PropertyChanged', @obj.notifyUDDPropertyChanged); %hl = handle.listener(obj.ModelData, fieldSchema, 'PropertyPostSet', @obj.notifyUDDPropertyChanged);
          %             if isempty(obj.udd_children_listeners)
          %               obj.udd_children_listeners = hl;
          %             else
          %               obj.udd_children_listeners(end+1) = hl;
          %             end
          %           end
        catch err
          debugStamp(err, 1, obj);
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
      %           debugStamp(err, 1, obj);
      %         end
      %       else
      %       end
      
      obj.ModelData.Prototype = obj;
      
      obj.initialize();
    end
    
    function notifyUDDPropertyChanged(obj, src, evt, varargin)
      evt = get(evt);
      %evt.AffectedObject = obj;
      obj.notify('PropertyChanged', Grasppe.Prototypes.Events.Data(obj, 'PropertyChanged', evt));
    end
    
    
    function inspect(obj)
      if isa(obj.ModelData, obj.ModelClass)
        inspect(obj.ModelData);
      else
        evalin('caller', ['openvar(''' inputname(1) ''')']); 	%openVariableEditor('obj');
      end
      
    end
    
    function modelClass = get.ModelClass(obj)
      modelClass = [obj.package_name '.' obj.class_name];
    end
    
    function delete(obj)
      try delete(obj.ModelData); end
    end
    
    function obj = saveobj(obj)
      try
        obj = Grasppe.Prototypes.Models.UDDModel.UDDModel2Struct(obj);
      catch err
        debugStamp(err, 1, obj)
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
        
        obj                   = Grasppe.Prototypes.Models.UDDModel.Struct2UDDModel(sObj);
        
        %         %modelProperties       = sObj.Schema.property_table(:,1)';
        %         %property_table        = sObj.Schema(strmatch('property_table', sObj.Schema(1:2:end))*2);
        %
        %         modelFields           = sObj.Model(1:2:end);
        %         modelValues           = sObj.Model(2:2:end);
        %
        %         % for m = 1:numel(modelFields)
        %         %   propertyName        = modelFields{m};
        %         %   propertyValue       = modelValues{m};
        %         %
        %         %   if isa(propertyValue, 'Grasppe.Prototypes.Models.UDDModel')
        %         %     propertyValue     =
        %         %   end
        %         % end
        %
        %         try
        %           obj                 = Grasppe.Prototypes.Models.UDDModel.NewModel(sObj.Class, sObj);%feval(sObj.Class, sObj);
        %         catch err
        %           obj                 = Grasppe.Prototypes.Models.UDDModel.NewModel('', sObj);
        %         end
        %
        %         if isfield(sObj, 'UDDModel')
        %           for m = 1:2:numel(sObj.UDDModel)
        %             uddField          = sObj.UDDModel{m};
        %             uddValue          = sObj.UDDModel{m+1};
        %             obj.(uddField)    = uddValue.ModelData;
        %           end
        %         end
      end
    end
    
    function uddObj = NewUDDModel(className, varargin)
      obj                     = Grasppe.Prototypes.Models.UDDModel.NewModel(className, varargin{:});
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
      st.ID                   = sObj.id_base;
      st.Class                = class(obj);
      st.Format               = 'Grasppe:UDDModel:R1';
      
      debugStamp(['Serializing ' obj.InstanceID], 1);
      
      %% UDD Schema
      
      schemaFields            = {
        'package_name', 'class_name', ...
        'user_type_table', 'enum_type_table', 'property_table', 'defaults_table'
        };
      
      schemaValues            = cell(1, numel(schemaFields));
      for m = 1:numel(schemaFields)
        schemaValues{m}       = obj.getUDDProperty(schemaFields{m});
      end
      
      st.Schema               = cell(1, numel(schemaFields)*2);
      st.Schema(1:2:end)      = schemaFields;
      st.Schema(2:2:end)      = schemaValues;
      
      %% ModelData
      
      modelFields             = sObj.property_table(:,1)';
      modelValues             = cell(1, numel(modelFields));
      
      try
        
        for m = 1:numel(modelFields)
          propertyName          = modelFields{m};
          propertySchema        = findprop(obj.ModelData, propertyName); %%'PressDetails');
          
          isUDDModel            = isequal(propertySchema.DataType, 'com.mathworks.jmi.bean.UDDObject');
          
          if isUDDModel
            uddModelObj         = obj.(propertyName).Prototype;
            modelValues{m}      = Grasppe.Prototypes.Models.UDDModel.UDDModel2Struct(uddModelObj);
          else
            modelValues{m}      = obj.ModelData.(propertyName);
          end
        end
        
      catch err
        debugStamp(err, 1, obj);
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

