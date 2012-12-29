function component = ComponentFactory(objectType, object, parent, varargin)
  %COMPONENTFACTORY Summary of this function goes here
  %   Detailed explanation goes here
  
  component                     = [];
  
  Factory.root                  = 'Grasppe.Graphics.Root';
  Factory.figure                = 'Grasppe.Graphics.Figure';
  Factory.axes                  = 'Grasppe.Graphics.Axes';
  
  if ~exist('parent', 'var'),     parent   = []; end
  
  componentOptions              = varargin;
  componentOptions              = [{parent}, componentOptions];
  
  if exist('object', 'var') && any(ishandle(object))
    objectType                  = get(object, 'Type');
    factoryMethod               = 'createComponentFromObject';
    componentOptions            = [{object}, componentOptions];
  else
    object                      = [];
    factoryMethod               = 'createComponent';
  end
  
  if ~exist('objectType', 'var'), objectType   = []; end
  componentType    	            = lower(objectType);
  
  if isfield(Factory, componentType)
    componentClass              = Factory.(componentType);
  else
    componentClass              = eval(NS.CLASS);
    componentOptions            = [{objectType}, componentOptions];
  end
  
  component                     = feval(factoryMethod, componentClass, componentOptions{:});
  
  %         component                   = feval([ '.CreateComponent'], object, parent, varargin{:});
  %       else
  %         component                   = feval([eval(NS.CLASS) '.CreateComponent'], objectType, object, parent, varargin{:});
  %       end
  
  
end

function component = createComponent(componentClass, objectType, object, parent, varargin)
  component = feval(componentClass, objectType, object, parent, varargin{:});
end

function component = createNewComponent(componentClass,objectType, parent, varargin)
  component = feval(componentClass, objectType, [], parent, varargin{:});
end

function component = createComponentFromObject(componentClass, object, parent, varargin)
  component = feval(componentClass, [], object, parent, varargin{:});
end

