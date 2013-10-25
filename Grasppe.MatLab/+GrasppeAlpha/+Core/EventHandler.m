classdef EventHandler < GrasppeAlpha.Core.Prototype
  %GRASPPEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    EventFunctions              = {};
    SelfListeners               = {};
    EventHandlers               = struct;
  end
  
  %   events %(Hidden, ListenAccess=private, NotifyAccess=public)
  %     Test
  %   end
  
  events
  end
  
  methods
    
    function obj = EventHandler()
      obj                       = obj@GrasppeAlpha.Core.Prototype();
      obj.SelfListeners         = {};
      obj.EventHandlers         = struct;
      
      obj.attachEventFunctions;
    end
    
    function attachEventFunctions(obj)
      
      eventsMeta    = obj.MetaClass.EventList;
      %propertyNames = {obj.MetaClass.PropertyList.Name};
      
      for m = 1:numel(eventsMeta)
        eventMeta     = eventsMeta(m);
        
        % Ignore low-level "native" events
        definingClass = eventMeta.DefiningClass.Name;
        if ~any(strcmpi('GrasppeAlpha.Core.Prototype', superclasses(definingClass)))
          continue;
        end
        
        % Define aspect names
        eventName     = eventMeta.Name;
        eventFunction = [eventName 'Function'];
        eventCallback = {@GrasppeAlpha.Core.EventHandler.callbackEvent, obj, eventName};
        
        % propertyNames = {obj.MetaClass.PropertyList.Name}'
        
        if ~any(strcmpi(eventFunction, obj.EventFunctions)) %{obj.MetaClass.PropertyList.Name}))
          try
            addprop(obj, eventFunction);
            propertyMeta  = findprop(obj, eventFunction);
            
            obj.EventFunctions = [obj.EventFunctions, {eventFunction}];
            %obj.EventFunctions
            propertyMeta.Hidden         = true;
            propertyMeta.SetObservable  = true;
            propertyMeta.GetObservable  = true;
            propertyMeta.AbortSet       = true;
          catch err
            dispf('Failed to add the %s to %s - %s (%s)', eventFunction, obj.ID, err.message, err.identifier);
          end
        end
        
        obj.(eventFunction) = eventCallback; %str2func(['@obj.' eventCallback]);
        
        % obj.addlistener(eventName, @obj.callbackEvent);
        
      end
      
    end
    
    function attachSelfListener(obj, varargin) %eventName, eventCallback)
      obj.SelfListeners{end+1}  = obj.addlistener(varargin{:});
    end    
    
    function attachSelfEventListeners(obj, group, events)
      for m = 1:numel(events)
        try
          eventName             = [events{m}];
          methodName            = ['On' eventName];
          
          if ismethod(obj, methodName)
            eventCallback       = @(src, evt)feval(methodName, obj, src, evt);
          else
            eventCallback       = @(src, evt) obj.callEventHandlers(group, eventName, src, evt);
          end
          
          obj.attachSelfListener(eventName, eventCallback);
        catch err
          debugStamp(err, 1, obj);
        end
      end
    end
    
    function attachSelfPropertyListeners(obj, group, properties)
      for m = 1:numel(properties)
        try
          propertyName          = properties{m};
          eventName             = [propertyName 'Change'];
          methodName            = ['On' eventName];
          
          if ismethod(obj, methodName)
            eventCallback       = @(src,evt)feval(methodName, obj, src, evt);
          else
            eventCallback       = @(src, evt) obj.callEventHandlers(group, eventName, src, evt);            
          end
          
          obj.attachSelfListener(propertyName, 'PostSet',  eventCallback);
        catch err
          debugStamp(err, 1, obj);
        end
      end
      
    end
    
    function handlers = getEventsHandlers(obj, group)
      if ~isstruct(obj.EventHandlers), obj.EventHandlers = struct; end
      if ~isfield(obj.EventHandlers, group) || ~iscell(obj.EventHandlers.(group)), obj.EventHandlers.(group) = {}; end
      
      handlers                  = obj.EventHandlers.(group);
    end
    
    function setEventHandlers(obj, group, eventHandlers)
      if ~isstruct(obj.EventHandlers), obj.EventHandlers = struct; end

      obj.EventHandlers.(group) = eventHandlers;
    end
    
    function registerEventHandler(obj, group, handler)
      handlers                  = obj.getEventsHandlers(group);   %if ~iscell(obj.getEventsHandlers(group)), obj.setEventHandlers(group)  = {}; end
      try if cellfun(@(h)isequal(h,handler), handlers), return; end; end
      
      obj.setEventHandlers(group, [handlers {handler}]);
    end
    
    function unregisterEventHandler(obj, group, handler)
      handlers                  = obj.getEventsHandlers(group);
      obj.setEventHandlers(group, handlers{handlers~=handler});
    end
    
    function consumed = callEventHandlers(obj, group, name, source, event)
      try
        consumed                = false;
        try consumed            = event.Consumed; end
        
        handlers                = obj.getEventsHandlers(group); % obj.EventHandlers.(group);
        
        if iscell(handlers) && ~isempty(handlers)
          for i = 1:numel(handlers)
            try
              handler           = handlers{i};
              
              if ~isvalid(handler), obj.unregisterEventHandler(group, handler); continue; end;
              
              if ismethod(handler, ['On' name])                                   % elseif ismethod(handler, ['on' name])
                feval(['On' name], handler, obj, event);        % eval([ 'handler.On' name '(obj, event);']);
              end
              
              try event.Consumed    = event.Consumed || consumed; end
            end
          end
        end
        
        try consumed            = event.Consumed; end
      end
    end
        
    function OnTest(obj, source, event)
      disp(event);
    end
  end
  
  methods (Static)
    function callbackEvent(source, event, obj, eventName, varargin)
      % try disp(WorkspaceVariables); end
      
      
      if nargin==2 && isa(source, 'GrasppeAlpha.Core.EventHandler')
        % disp(toString({source, event}));
        obj = source;
        eventName     = event.EventName;
        eventFunction = ['On' eventName];
      elseif nargin==4 && isa(obj, 'GrasppeAlpha.Core.EventHandler')
        % disp(toString({source, event, obj, eventName}));
        eventFunction = ['On' eventName];
      elseif nargin==6 && isa(varargin{1}, 'GrasppeAlpha.Core.EventHandler')
        eventFunction = ['On' eventName];
        source = obj;
        obj    = varargin{1};
        event  = varargin{2};
      else
        return;
      end
      
      %       %try disp(eventName); end
      %
      % if strcmp(eventName, 'PreSet') || strcmp(eventName, 'PostSet')
      %   disp(event);
      % end
      
      switch eventFunction
        case {'OnKeyPress', 'OnKeyRelease'}
          event = GrasppeAlpha.Core.EventData(eventFunction, event);
      end
      
      if isequal(eventName, 'delete') && isa(obj, 'GrasppeAlpha.Core.Component')
        obj.bless;
      end      
      
      try
        feval(str2func(eventFunction), obj, source, event);
        % return;
      catch err
        % disp(['Function callback error ' err.identifier ': ' err.message]);
      end
      
      %       if ~isempty(strfind(eventName, 'Click')) && ~isa(obj,'GrasppeAlpha.Graphics.Figure')
      % %         try
      % %           notify(obj, eventName, event);
      %           disp(eventName);
      % %           return;
      % %         catch
      % %           disp(eventName);
      % %         end
      %       end
      %
      try
        data = event;
        eventData = GrasppeAlpha.Core.EventData(eventName, data);
        %eventData.Name  = eventName;
        %eventData.Data  = data;
      end
      
      
      try
        if ~isa(source, 'GrasppeAlpha.Core.Component') % isnumeric(source) isempty(event)
          notify(obj, eventName, eventData);
        end
      end
      
    end
    
  end
  
end

