function defineModelSchema( obj )
  %DEFINEMODEL Summary of this function goes here
  %   Detailed explanation goes here
  
  %% Get Model Parameters
  packageName                 = obj.packageName;
  className                   = obj.className;
  userTypes                   = obj.userTypeTable;
  enumTypes                   = obj.enumTypeTable;
  modelPoperties              = obj.propertyTable;
  modelDefaults               = obj.defaultsTable;
  modelAttributes             = obj.propertyAttributes;
  
  %% Append Base Properties
  modelPoperties(end+1, :)    = {'Prototype', 'MATLAB array',   'Handle of the defining Prototype-based Model'};
  modelDefaults(end+1, :)     = {'Prototype', handle(obj)};
  modelAttributes(end+1, :)   = {'Prototype',        {'Visible', 'off'}};
  
  %% Define Enumeration and User Types
  obj.enumTypeSchema        = defineEnumTypes(enumTypes);
  obj.userTypeSchema        = defineUserTypes(userTypes);
  
  %% Define Model Package and Class
  packageSchema               = getPackageSchema(packageName);
  classSchema                 = getClassSchema(className, packageSchema);
  
  obj.packageSchema          = packageSchema;
  obj.classSchema            = classSchema;
  
  %% Define Model Properties
  obj.propertySchema         = defineProperties(obj, classSchema, modelPoperties, modelAttributes, modelDefaults);
  
end

function packageSchema = getPackageSchema(packageName)
  try
    packageSchema               = findpackage(packageName);
    if isempty(packageSchema)
      packageSchema             = schema.package(packageName);
    end
  catch err
    rethrow(err);
  end
end

function classSchema = getClassSchema(className, packageSchema)
  if ischar(packageSchema), packageSchema = getPackageSchema(packageName); end
  classSchema                 = findclass(packageSchema, className);
  if isempty(classSchema)
    classSchema               = schema.class(packageSchema, className);
  end
end

function propertySchema = defineProperties(obj, classSchema, modelPoperties, modelAttributes, modelDefaults)
  if isempty(modelPoperties)
    propertySchema                  = [];
  else
    for m = 1:size(modelPoperties,1)
      defaultsIndex                 = strmatch(modelPoperties{m,1}, modelDefaults(:,1));
      attributesIndex               = strmatch(modelPoperties{m,1}, modelAttributes(:,1));
      
      attribtures                   = [];
      if any(attributesIndex),  attribtures   = modelAttributes{attributesIndex,2}; end
      
      defaultValue                  = [];
      if any(defaultsIndex),    defaultValue  = modelDefaults{defaultsIndex, 2};    end
      
      propertySchema(m)             = defineProperty(classSchema, modelPoperties{m, :}, attribtures, defaultValue);
      
      isUDDModel                    = false;
      try isUDDModel                = isequal(propertySchema(m).DataType, 'com.mathworks.jmi.bean.UDDObject'); end
      
      try
        propertyName                = modelPoperties{m,1};
        dynamicProperty             = obj.addprop(propertyName);
        
        if ~isUDDModel
          dynamicProperty.GetMethod = @(obj)        get(obj.ModelData, propertyName);
          dynamicProperty.SetMethod = @(obj, value) set(obj.ModelData, propertyName, value);
        else
          dynamicProperty.GetMethod = @(obj)        getUDDObject(obj, propertyName); % 
          dynamicProperty.SetMethod = @(obj, value) setUDDObject(obj, propertyName, value); %set(obj.ModelData, propertyName, java(value));          
        end

        dynamicProperty.Description = modelPoperties{m,3};
      end
    end
  end
end

function setUDDObject(obj, propertyName, value)
  if isa(value, 'GrasppeAlpha.Data.Models.UDDModel')
    value                           = value.ModelData;
  end
  
  set(obj.ModelData, propertyName, java(value));
end

function value = getUDDObject(obj, propertyName)
  modelData                         = handle(get(obj.ModelData, propertyName));
  value                             = modelData.Prototype;
end

function propertySchema = defineProperty(classSchema, name, type, description, attributes, defaultValue)
  
  isClassType                       = isequal(type(1), '@');
  typeExists                        = isClassType && exist(type(2:end), 'class')==8;
  
  propertySchema                    = findprop(classSchema, name);
  
  % try
  % if ~isempty(propertySchema) %typeExists &&
  %   delete(propertySchema)
  % end
  % end
  
  if numel(propertySchema)>1
    beep;
  end
  
  try
    if isempty(propertySchema) %|| ~isa(propertySchema, 'schema.prop')   %|| ~isvalid(propertySchema)
      
      if typeExists
        prototype                     = type(2:end);
        type                          = 'com.mathworks.jmi.bean.UDDObject';
        defaultValue                  = []; %Grasppe.Prototypes.Models.UDDModel.NewUDDModel(prototype);
      end
      
      propertySchema                  = schema.prop(classSchema, name, type);
      propertySchema.Description      = description;
      if exist('defaultValue', 'var') && ~isempty(defaultValue)
        propertySchema.FactoryValue   = defaultValue; % modelDefaults{defaultValueIndex, 2};
      end
      
      if exist('attributes', 'var') && ~isempty(attributes) && iscell(attributes)
        for m = 1:2:numel(attributes)
          %attribute                   = attributes{m};
          %if iscell(attribute)
          try propertySchema.(attributes{m})  = attributes{m+1}; end
            %   elseif ischar(attribute)
            %     try propertySchema.(attribute{m}) = 'on',         end
          %end
        end
      end
    end
  catch err
    debugStamp(err, 1, obj);
    beep;
  end
end

function enumSchema = defineEnumTypes(enumTypes)
  if isempty(enumTypes),
    enumSchema                = [];
  else
    for m = 1:size(enumTypes,1)
      enumSchema(m)           = defineEnumType(enumTypes{m, :});
    end
  end
end

function enumSchema = defineEnumType(name, values)
  enumSchema                  = findtype(name);
  if isempty(enumSchema)
    enumSchema                = schema.EnumType(name, values);
  end
end

function userSchema = defineUserTypes(userTypes)
  if isempty(userTypes),
    userSchema                = [];
  else
    for m = 1:size(userTypes,1)
      userSchema(m)           = defineUserType(userTypes{m, :});
    end
  end
end

function userSchema = defineUserType(name, baseType, checkFunction)
  userSchema                  = findtype(name);
  if isempty(userSchema)
    userSchema                = schema.UserType(name, baseType, checkFunction);
  end
end

