classdef HandleGraphicsComponent < Grasppe.Prototypes.Instance & dynamicprops & matlab.mixin.Heterogeneous
  %HANDLEGRAPHICSCOMPONENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(SetAccess=immutable, Hidden) %, GetAccess=protected)
    ObjectType
  end
  
  events
    Help
    KeyPress
    KeyRelease
    Resize
    ButtonDown
    
    Delete
    
    Scroll
    Swipe
    Zoom
    Rotate
    
    Click
    AlternateClick
    ExtendedClick
    DoubleClick
  end
  
  properties
  end
  
  properties (SetAccess=protected)
    DefaultOptions
    Object                    % Schema.Class Object
    ParentComponent           % HandleGraphicsComponent Object
    ChildComponents
    HandlePropertyListeners
    HandleFunctions
    HandleProperties  = []
  end
  
  properties(Dependent)
    Handle                    % Handle Object
  end
  
  
  methods(Access=protected)
    function obj = HandleGraphicsComponent(objectType, object, parent, varargin)
      
      if ~exist('objectType', 'var'), objectType  = []; end
      try  if isempty(objectType),    objectType  = get(object, 'Type'); end; end
      
      instanceOptions = {};
      
      if ischar(objectType)
        instanceOptions   = {'ID', [upper(objectType(1)) objectType(2:end) 'Component']};
      end
      
      obj = obj@Grasppe.Prototypes.Instance(instanceOptions{:});
      
      debugStamp('Constructing', 5, obj);
      
      if isequal(mfilename('class'),  obj.ClassName), obj.initialize();   end
      if (nargin > 0),                obj.setOptions(varargin{:});        end
      if exist('objectType', 'var'),  obj.ObjectType      = objectType;   end
      
      if exist('parent', 'var'),  obj.ParentComponent = parent; end
      
      if exist('object', 'var') && any(ishandle(object))
        obj.ObjectType              = get(object, 'Type');
        handleOptions               = obj.getDefaultHandleOptions(varargin{:});
        
        set(object, handleOptions{:});
        
        obj.Object                  = handle(object);
      else
        obj.createHandleObject(varargin{:});
      end
      
    end
  end
  
  methods
    
    function delete(obj)
      if ~isequal(obj.ObjectType, 'root');
        try
          obj.deleteRecursively(obj.ChildComponents);
        catch err
          debugStamp(err, 1);
        end
      else
        debugStamp('NotDeletingRoot', 1, obj);
      end
    end
    
    function h = get.Handle(obj)
      h = [];
      try h = findobj(obj.Object); end
    end
    
  end
  
  methods (Access=protected)
    [names values]    = setOptions(obj, varargin);
  end
  
  %% Populate Handle Properties and Functions
  methods %(Access=private)
    
    function set.Object(obj, object)
      
      if ~isempty(obj.Object), return; end
      
      obj.Object                    = handle(object);
      
      obj.attachHandleObject();
    end
    
    function createHandleObject(obj, varargin)
      if isempty(obj.Object) || ~ishandle(obj.Object) || ~isequal(obj.ObjectType, obj.Object.Type)
        try delete(obj.Object); end
        
        handleOptions               = obj.getDefaultHandleOptions(varargin{:});
        obj.Object                  = feval(obj.ObjectType, handleOptions{:});
        
      end
      obj.attachHandleObject();
    end
    
    function handleOptions = getDefaultHandleOptions(obj, varargin)
      options                       = varargin;
      
      if rem(numel(varargin),2)==1
        optiovararginns                     = varargin(1:end-1);
      end
      
      if isstruct(obj.DefaultOptions)
        options                     = [{obj.DefaultOptions}, varargin];
      end
      
      [names values paired pairs]   = Grasppe.Prototypes.Utilities.ParseOptions(options{:});
      handleOptions                 = cell(1, numel(names)*2);
      handleOptions(1:2:end)        = names;
      handleOptions(2:2:end)        = values;
    end
    
    function attachHandleObject(obj)
      if ~ishandle(obj.Object), return; end
      
      setappdata(obj.Object, 'HandleComponent', obj)
      obj.createDynamicProperties;
    end
    
    function component = get.ParentComponent(obj)
      if ~isobject(obj.Object), component = obj.ParentComponent;
      else component                     = getParentComponent(obj);
      end
    end
    
    function components = get.ChildComponents(obj)
      components                    =  obj.getChildComponents();
    end
    
    function handleHandlePropertyEvent(obj, src, evt)
      propertyEvent                 = struct(evt);
      propertyEvent.EventName       = regexprep(evt.Type, '^Property', '');
      propertyEvent.PrimitiveObject = evt.AffectedObject;
      propertyEvent.AffectedObject  = obj;
      obj.handlePropertyEvent(src, propertyEvent);
    end
    
    function inspect(obj)
      obj.inspectHandle();
    end
    
    function handleHandleEvent(obj, src, evt, eventData)
      try
        try
          %           try, if isequal(evt.EventName, 'CloseRequest')
          %               beep;
          %             end; end
          eventType     = [];
          try eventType = evt.EventName; end
          
          notifyData = Grasppe.Graphics.EventData(obj,eventType, eventData);
          obj.notify(evt.EventName, notifyData);
        catch err1
          obj.notify(evt.EventName);
        end
        return;
      catch err
        dbTag                       = ['Error:Unknown:HandleEvent'];
        try dbTag                   = ['Error:' err.identifier ':HandleEvent']; end
        try dbTag                   = [obj.ID ':Handle' evt.EventName]; end
        try dbTag                   = [dbTag ':' evt.AffectedObject.ID]; end
        try dbTag                   = [dbTag ':' src.ID]; end
        debugStamp( dbTag, 1, obj );
      end
    end
    
    metaProperty                    = createDynamicProperty(obj, schemaProperty);
    callbackFunction                = createCallbackFunction( obj, schemaProperty );
    components                      = getChildComponents(obj);
    component                       = getParentComponent(obj);
    
    createDynamicProperties(obj);
    
    function onScroll(obj, src, evt)
      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
    end
    
    function onSwipe(obj, src, evt)
      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
    end
    
    function onClick(obj, src, evt)
      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
    end
    
    function onDoubleClick(obj, src, evt)
      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
    end
    
    
    function component = getComponentFromHandle(obj, h)
        object                      = handle(h);
        component                   = getappdata(object, 'HandleComponent');
        
        if isempty(component) || ~isa(component, 'Grasppe.Prototypes.HandleGraphicsComponent')
          objectType                = get(object, 'Type');
          component                 = Grasppe.Prototypes.HandleGraphicsComponent.CreateComponentFromObject(object, obj);
        end
      
    end
    
    
  end
  
  methods(Static)
    component                       = ComponentFactory(objectType, object, parent, varargin);
  end
  
  methods(Static, Hidden)
    obj                             = testHandleGraphicsComponent(hObject);
    
    function component = CreateComponent(objectType, object, parent, varargin)
      component = feval(mfilename('class'), objectType, object, parent, varargin{:});
    end
    
    function component = CreateNewComponent(objectType, parent, varargin)
      component = feval(mfilename('class'), objectType, [], parent, varargin{:});
    end
    
    function component = CreateComponentFromObject(object, parent, varargin)
      component = feval(mfilename('class'), [], object, parent, varargin{:});
    end
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Prototypes.Instance;
    end
    
    function inspectHandle(obj)
      if ishandle(obj.Handle)
        inspect(obj.Handle);
      end
    end
  end
end

