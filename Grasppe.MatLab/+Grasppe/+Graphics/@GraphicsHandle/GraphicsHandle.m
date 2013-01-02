classdef GraphicsHandle < Grasppe.Prototypes.Instance & ...
    Grasppe.Prototypes.DynamicDelegator % & hgsetget  % & matlab.mixin.Heterogeneous % & dynamicprops
  %GRAPHICSHANDLE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(SetAccess=immutable, Hidden) %, GetAccess=protected)
    UDDEvents             = { ...
      'ObjectBeingDestroyed', 'ObjectParentChanged', 'ObjectChildAdded', 'ObjectChildRemoved', ...
      % 'ClassInstanceCreated',  'PropertyPreGet', 'PropertyPostGet', 'PropertyPreSet', 'PropertyPostSet' ...
      };
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
  
  events(Hidden) % UDD Events
    UDDClassInstanceCreated
    UDDObjectBeingDestroyed
    UDDObjectChildAdded
    UDDObjectChildRemoved
    UDDObjectParentChanged
    UDDPropertyPreGet
    UDDPropertyPostGet
    UDDPropertyPreSet
    UDDPropertyPostSet    
  end
  
  properties (SetAccess=protected)
    ParentComponent           % HandleGraphicsClass Object
    ChildComponents
    HandleFunctions
    
  end
  
  properties(Dependent, Hidden)
    Handle                    % Handle Object
    Object
    GraphicsHandleObject
    GraphicsHandleDelegator
  end
  
  methods (Access=protected)
    function obj = GraphicsHandle(delegate, varargin)
      
      thisClass               = mfilename('class');
      
      try
        %% Eliminate Delegator Redudancy
        while isa(delegate, thisClass) && ...
            isequal(class(delegate), thisClass) && ...
            ~isequal(class(delegate.Delegate), thisClass)
          delegate            = delegate.Delegate;
        end
        
        %% Create Primitive On-Demand
        if ischar(delegate)
          delegate            = Grasppe.Graphics.GraphicsHandle.CreateHandleGraphicsObject(delegate, 'Visible', 'off', varargin{:});
        end
        
        %% Customize InstanceID
        id                    = 'GraphicsHandle';
        
        if isa(delegate, thisClass)
          try id              = [delegate.InstanceID '-Handle']; end
        else
          try id                = regexprep(class(delegate), '.*?\.?([^\.]+$)', '$1'); end
          id                    = [upper(id(1)) id(2:end)];
        end
        
      catch err
        debugStamp(err, 1); rethrow(err);
      end
      
      obj                     = obj@Grasppe.Prototypes.Instance('InstanceID', id);
      obj                     = obj@Grasppe.Prototypes.DynamicDelegator(delegate);
      
      try
        %% Set Options
        if (numel(varargin) > 0), obj.setOptions(varargin{:}); end
        
        %% Set Primitive Prototype to Object
        if ishghandle(delegate), setappdata(delegate, 'Prototype',obj); end
        
        obj.attachUDDEvents();
        obj.attachHandleEvents();
        obj.initialize();
        
      catch err
        debugStamp(err, 1, obj); rethrow(err);
      end
    end
  end
  
  methods (Access=protected)
    
    function attachHandleEvents(obj)
      %% Attach Primitive Events
      delegateSchema        = classhandle(obj.Object);
      delegateProperties    = delegateSchema.Properties;
      %delegateEvents        = delegateSchema.Events;
      
      for m = 1:numel(delegateProperties)
        try
          if isscalar(regexp(delegateSchema.Properties(m).Name, 'Fcn$'))
            obj.createCallbackFunction(delegateSchema.Properties(m));
          end
        end
      end
    end
    
    function attachUDDEvents(obj)
      delegateSchema        = classhandle(obj.Object);
      delegateProperties    = delegateSchema.Properties;

      uddEvents             = obj.UDDEvents;
      
      for m = 1:numel(uddEvents)
        try
          obj.createCallbackFunction(struct('Name',uddEvents{m}), ['UDD' uddEvents{m}]);
        end
      end
    end
  end
  
  %% Event Handling
  
  methods
    
    function onDelegateEvent(obj, src, evt)      
      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
      disp(evt);      
    end
    
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
    
    function onUDDObjectChildAdded(obj, src, evt)
      global DebugUDDEvents;
      
      
      try if isequal(DebugUDDEvents, true), structDisplay(evt.SourceData); end; end

      Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt);
      
      try 
        Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(evt.SourceData.Child, evt.SourceData.Source);
      catch err
        debugStamp(err, 1, obj);
      end
    end
    
    function handleHandleEvent(obj, src, evt, eventData)
      
      if ~all(isvalid(obj)), return; end
           
      try
        try
          %           try, if isequal(evt.EventName, 'CloseRequest')
          %               beep;
          %             end; end
          eventType     = [];
          try eventType = evt.EventName; end
          
          notifyData = Grasppe.Graphics.Events.Data(obj,eventType, eventData);
          obj.notify(evt.EventName, notifyData);
        catch err1
          obj.notify(evt.EventName);
        end
        return;
      catch err
        dbTag                       = ['Error:Unknown:HandleEvent'];
        try dbTag                   = ['Error:' err.identifier ':HandleEvent']; end
        try dbTag                   = [obj.InstanceID ':Handle' evt.EventName]; end
        try dbTag                   = [dbTag ':' evt.AffectedObject.InstanceID]; end
        try dbTag                   = [dbTag ':' src.InstanceID]; end
        debugStamp( dbTag, 1, obj );
      end
    end
  end
  
  %% Getters & Setters
  
  methods
    
    function h = get.Handle(obj)
      h                     = findobj(obj.Object, 'flat');
      if numel(h) > 1, h    = h(1); end
    end
    
    function newObj = get.GraphicsHandleObject(obj)
      newObj                = obj;
      if ~isequal(class(newObj, 'Grasppe.Graphics.GraphicsHandle'))
        newObj              = Grasppe.Graphics.GraphicsHandle(newObj);
      end
    end
    
    function delegator = get.GraphicsHandleDelegator(obj)
      delegator             = obj;
      while isa(delegator.Delegate, 'Grasppe.Graphics.GraphicsHandle')
        delegator           = delegator.Delegate;
      end
      
    end
    
    function primitive = get.Object(obj)
      delegate              = obj.Delegate;
      
      while isa(delegate, mfilename('class')) %'Grasppe.Prototypes.DynamicDelegate')
        delegate            = delegate.Delegate;
      end
      
      primitive             = delegate;
    end
    
    function parentComponent = get.ParentComponent(obj)
      parentComponent       = [];
      try parentComponent   = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(obj.Object.Parent); end
    end
    
    function childComponents = get.ChildComponents(obj)
      childComponents       = [];
      try childComponents   = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(obj.Object.Children); end
    end
  end
  
  %% Overload Behaviour
  
  methods
    
    function varargout = subsref(obj, subs)
      global DebugSubsOverloads;
      if isequal(DebugSubsOverloads, true), debugStamp('SUBSREF', 1); end
      
      %% Failsafe
      try
        assert(all(isvalid(obj)));
      catch err
        if nargout>0, [varargout{:}]  = builtin('subsref', obj, subs);
        else builtin('subsref', obj, subs); end
        return;
      end
      
      
      if nargout>0, varargout = cell(1,nargout); end
      if isa(obj.Delegate, 'Grasppe.Graphics.GraphicsHandle')
        if nargout>0, [varargout{:}]  = obj.Delegate.subsref(subs);
        else obj.Delegate.subsref(subs); end
      else
        if nargout>0, [varargout{:}]  = obj.subsref@Grasppe.Prototypes.DynamicDelegator(subs);
        else obj.subsref@Grasppe.Prototypes.DynamicDelegator(subs); end
      end
    end
    
    function obj = subsasgn(obj, subs, value)
      global DebugSubsOverloads;
      if isequal(DebugSubsOverloads, true), debugStamp('SUBSASGN', 1); end
      
      %% Failsafe
      try
        assert(all(isvalid(obj)));
      catch err
        obj        = builtin('assign', obj, subs, value);
        return;
      end
      
      if isa(obj.Delegate, 'Grasppe.Graphics.GraphicsHandle')
        obj         = obj.Delegate.subsasgn(subs, value);
      else
        %disp(value)
        obj         = obj.subsasgn@Grasppe.Prototypes.DynamicDelegator(subs, value);
      end
    end
    
    function obj = notify(obj, eventName, varargin)
      global DebugHandleOverloads DebugUDDEvents;
      if isequal(DebugHandleOverloads, true), debugStamp('NOTIFY', 1); end    
      
      uddEvents             	= obj.UDDEvents;
      
      uddNotify               = any(strcmp(eventName, uddEvents));
      
      if uddNotify
        if isequal(DebugUDDEvents, true)
          Grasppe.Prototypes.Utilities.StampEvent(obj, obj, struct('EventName', eventName));
          for m = 1:numel(varargin), disp(varargin{m}); end
        end
        obj.notify@handle(['UDD' eventName], varargin{:});
      else
        obj.notify@Grasppe.Prototypes.DynamicDelegator(eventName, varargin{:});
      end
    end    
    
    function lh = addlistener(obj, varargin)
      global DebugHandleOverloads;
      if isequal(DebugHandleOverloads, true), debugStamp('ADDLISTENER', 1); end
      
      try
        lh                    = obj.addlistener@handle(varargin{:});
        
        % TODO: Tie to Grasppe.Prototypes.Handle
        
        % TODO: Implement UDD/OBJ handle.listener callbacks
        %       try
        %         uddHandle   = classhandle(obj.Self.Object);
        %
        %         uddEvents   = get(get(classhandle(h), 'Events'), 'Name');
        %
        %       end
        
        
      catch err
        debugStamp(err, 1, obj);
      end
    end
    
    
    function inspect(obj)
      global DebugHandleOverloads;
      if isequal(DebugHandleOverloads, true), debugStamp('INSPECT', 1); end
      
      obj.inspectHandle();
    end
    
    function newObj = horzcat(varargin)
      global DebugCatOverloads;
      if isequal(DebugCatOverloads, true), debugStamp('HORZCAT', 1); end
      
      newObj                = horzcat(cellfun(@(obj) obj.GraphicsHandleObject, varargin));
    end
    
    function newObj = vertcat(varargin)
      global DebugCatOverloads;
      if isequal(DebugCatOverloads, true), debugStamp('VERTCAT', 1); end
      
      newObj                = vertcat(cellfun(@(obj) obj.GraphicsHandleObject, varargin));
    end
    
    function newObj = cat(varargin)
      global DebugCatOverloads;
      if isequal(DebugCatOverloads, true), debugStamp('CAT', 1); end
      
      newObj                = cat(cellfun(@(obj) obj.GraphicsHandleObject, varargin));
    end
    
    function delete(obj)
      global DebugDeleteOverloads;
      if isequal(DebugDeleteOverloads, true), debugStamp('DELETE', 1); end
      
      isInstance;
      if all(~isvalid(obj)), return; end
      if ~isequal(class(obj.Delegate), 'root');
        try
          obj.deleteRecursively(obj.ChildComponents);
        catch err
          debugStamp(err, 1);
        end
      else
        debugStamp('NotDeletingRoot', 1, obj);
      end
    end
    
  end
  
  
  methods (Access=protected)
    function privateSet(obj, propertyName, value)
      if ~isequal(obj.Delegate.(propertyName), value), obj.Delegate.(propertyName) = value; end
    end
    
    function inspectHandle(obj)
      if ishandle(obj.Handle)
        inspect(obj.Handle);
      end
    end
    
  end
  
  methods (Static)
    obj   = CreateGraphicsPrototype(varargin)
    obj   = CreateHandleGraphicsObject(varargin)
    
    function obj = Create(varargin)
      obj           = feval(mfilename('class'), varargin{:});
    end
    
  end
end

