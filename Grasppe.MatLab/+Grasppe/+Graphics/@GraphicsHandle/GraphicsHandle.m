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
    DefaultState            = {};
  end
  
  properties (SetAccess=protected, GetAccess=protected)
    parentComponent
    childComponents         = Grasppe.Graphics.GraphicsHandle.empty();
    uddIsBeingDestroyed     = false;
  end
  
  properties(Dependent, Hidden)
    Handle                    % Handle Object
    Object
    GraphicsHandleObject
    GraphicsHandleDelegator
    HandleClass
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
          delegate            = Grasppe.Graphics.GraphicsHandle.CreateHandleGraphicsObject(delegate, 'Visible', 'off');
        end
        
        %% Customize InstanceID
        id                    = 'GraphicsHandle';
        
        if isa(delegate, thisClass)
          try id              = [delegate.InstanceID '-Handle']; end
        else
          try id              = regexprep(class(delegate), '.*?\.?([^\.]+$)', '$1'); end
          id                  = [upper(id(1)) id(2:end)];
        end
        
      catch err
        debugStamp(err, 1);
        rethrow(err);
      end
      
      obj                     = obj@Grasppe.Prototypes.Instance('InstanceID', id);
      obj                     = obj@Grasppe.Prototypes.DynamicDelegator(delegate);
      
      try        
        %% Set Primitive Prototype to Object
        if ishghandle(delegate), setappdata(delegate, 'Prototype', obj); end
        
        %% Set Options
        if (numel(varargin) > 0), obj.setOptions('Visible', 'on', varargin{:}); end
        
        obj.attachHandleEvents();        
        obj.attachUDDEvents();        
        
        obj.initialize();
        
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        rethrow(err);
      end
      
      %% Make final intializations
      if isempty(obj.childComponents), childComponents = Grasppe.Graphics.GraphicsHandle.empty(); end
    end
  end
  
  methods (Access=protected)
    
    function attachHandleEvents(obj)
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
      %% Attach Primitive Events
      delegateSchema        = classhandle(handle(obj.Object));
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
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
      delegateSchema        = classhandle(handle(obj.Object));
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
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
      try if isequal(DebugUDDEvents, true), structDisplay(evt.SourceData); end; end

      try if isequal(DebugUDDEvents, true), Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt); end; end
      
      try 
        childComponent        = getappdata(evt.SourceData.Child, 'Prototype');
        
        if ~isscalar(childComponent) || ~isvalid(childComponent)
          childComponent      = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(evt.SourceData.Child, evt.SourceData.Source); 
        end
        
        componentIndex        = find(childComponent==obj.childComponents);
        
        if ~any(componentIndex),  obj.childComponents(end+1) = childComponent; end
        
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
      end
    end
    
    function onUDDObjectChildRemoved(obj, src, evt)
      global DebugUDDEvents;
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
      try if isequal(DebugUDDEvents, true), structDisplay(evt.SourceData); end; end
      
      try if isequal(DebugUDDEvents, true), Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt); end; end
      
      try
        childComponent        = getappdata(evt.SourceData.Child, 'Prototype');
        obj.childComponents   = obj.childComponents(childComponent~=obj.childComponents);
        
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
      end
    end
    
    function onUDDObjectParentChanged(obj, src, evt)
      global DebugUDDEvents;
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
      try if isequal(DebugUDDEvents, true), structDisplay(evt.SourceData); end; end
      
      try if isequal(DebugUDDEvents, true), Grasppe.Prototypes.Utilities.StampEvent(obj, src, evt); end; end
      
      try
        parentComponent       = getappdata(evt.SourceData.NewParent, 'Prototype');
        if ~isscalar(parentComponent) || ~isvalid(parentComponent)
          parentComponent     = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(evt.SourceData.NewParent, evt.SourceData.Source);
        end
        
        obj.parentComponent   = parentComponent;
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
      end
    end
    
    function onUDDObjectBeingDestroyed(obj, src, evt)
      if ~all(isvalid(obj)), return; end
      if ~isequal(obj.uddIsBeingDestroyed, true)
        obj.uddIsBeingDestroyed = true;
        try delete(obj.Object.Children); end
        try delete(obj); end
      end
    end

    
    function handleHandleEvent(obj, src, evt, eventData)
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
           
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
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end

      if isempty(obj.parentComponent)
        try obj.parentComponent   = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(obj.Object.Parent); end
      end
      parentComponent       = obj.parentComponent;      
    end
    
    function childComponents = get.ChildComponents(obj)
      childComponents       = [];
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end

      if isempty(obj.childComponents)
        try obj.childComponents   = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(obj.Object.Children); end
      end
      
      childComponents       = obj.childComponents;
    end
    
    function handleClass = get.HandleClass(obj)
      handleClass           = [];
      try handleClass       = classhandle(obj.Object); end
      try if isempty(handleClass), handleClass = metaclass(obj.Object); end; end
    end
  end
  
  %% Overload Behaviour
  
  methods
    
%     function varargout = subsref(obj, subs)
%       global DebugSubsOverloads;
%       if isequal(DebugSubsOverloads, true), debugStamp('SUBSREF', 1); end
%       
% %       if nargout>0
% %         varargout = cell(1,nargout);
% %       end
%       
% %       %% Failsafe
% %       try
% %         assert(all(isvalid(obj)));
% %       catch err
% %         if nargout>0
% %           [varargout{:}]      = builtin('subsref', obj, subs);
% %         else
% %           %[varargout{1}]      = 
% %           varargout           = builtin('subsref', obj, subs);
% %           if exist('ans', 'var'), assignin('caller', 'ans', ans); end
% %         end
% %         return;
% %       end
% %       
% %       %      allGraphicsHandles = 
% %       
% %       if nargout>0, varargout = cell(1,nargout); end
% %       
% %       if isa(obj(1).Delegate, 'Grasppe.Graphics.GraphicsHandle')
% %         if nargout>0
% %           [varargout{:}]      = obj(:).Delegate.subsref(subs);
% %         else
% %           %[varargout{1}]      = 
% %           obj.Delegate.subsref(subs);
% %           if exist('ans', 'var'), assignin('caller', 'ans', ans); end
% %         end
% %       else
% %         if nargout>0
% %           [varargout{:}]      = obj(:).subsref@Grasppe.Prototypes.DynamicDelegator(subs);
% %         else
% %           %[varargout{1}]      = 
% %           varargout{1}        = obj.subsref@Grasppe.Prototypes.DynamicDelegator(subs);
% %           if exist('ans', 'var'), assignin('caller', 'ans', ans); end
% %         end
% %       end
%     end
    
%     function obj = subsasgn(obj, subs, value)
%       global DebugSubsOverloads;
%       if isequal(DebugSubsOverloads, true), debugStamp('SUBSASGN', 1); end
%       
%       try
%         
%         %% Failsafe
%         try
%           assert(all(isvalid(obj)));
%         catch err
%           obj        = builtin('assign', obj, subs, value);
%           return;
%         end
%         
%         if isa(obj(1).Delegate, 'Grasppe.Graphics.GraphicsHandle')
%           obj         = obj.Delegate.subsasgn(subs, value);
%         else
%           %disp(value)
%           obj         = obj.subsasgn@Grasppe.Prototypes.DynamicDelegator(subs, value);
%         end
%         
%       catch err
%         Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
%         rethrow(err);
%       end
%     end
    
    function obj = notify(obj, eventName, varargin)
      global DebugHandleOverloads DebugUDDEvents;
      if isequal(DebugHandleOverloads, true), debugStamp('NOTIFY', 1); end  
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
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
      
      lh                      = [];
      
      if ~all(isvalid(obj)), return; end
      if isequal(obj.uddIsBeingDestroyed, true), return; end
      
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
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
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
      
      try if all(~isvalid(obj)), return; end; end
      
      validObject             = obj(isvalid(obj));
      
      for m = 1:numel(validObject)
        try
          thisObject          = validObject(m);
          
          if ~isvalid(thisObject), continue; end
          
          if ~isequal(thisObject.uddIsBeingDestroyed, true) && ...
              ~isequal(class(thisObject.Object), 'root')
            try delete(thisObject.Object); end
          end
          
          handleFunctions     = struct2cell(thisObject.HandleFunctions);
          
          for n = 1:numel(handleFunctions)
            try delete(handleFunctions{n}.Listener); end
          end
          
          thisObject.deleteRecursively(thisObject.ChildComponents);
        catch err
          Grasppe.Kit.Utilities.DisplayError(thisObject, 1, err);
        end
      end
    end
    
  end
  
  
  methods (Access=protected)
    function privateSet(obj, propertyName, value)
      if ~isequal(obj.Delegate.(propertyName), value), obj.Delegate.(propertyName) = value; end
    end
    
    function inspectHandle(obj)
      if ishandle(obj(1).Handle)
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

