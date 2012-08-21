classdef EventHandler < Grasppe.Core.Prototype
  %GRASPPEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=true)
    EventFunctions = {};
  end
  
%   events %(Hidden, ListenAccess=private, NotifyAccess=public)
%     Test
%   end
  
  methods
    
    function obj = EventHandler()
      obj = obj@Grasppe.Core.Prototype();
      obj.attachEventFunctions;
    end
    
    function attachEventFunctions(obj)
      
      eventsMeta    = obj.MetaClass.EventList;
      %propertyNames = {obj.MetaClass.PropertyList.Name};
      
      for m = 1:numel(eventsMeta)
        eventMeta     = eventsMeta(m);
        
        % Ignore low-level "native" events
        definingClass = eventMeta.DefiningClass.Name;
        if ~any(strcmpi('Grasppe.Core.Prototype', superclasses(definingClass)))
          continue;
        end
        
        % Define aspect names
        eventName     = eventMeta.Name;
        eventFunction = [eventName 'Function'];
        eventCallback = {@Grasppe.Core.EventHandler.callbackEvent, obj, eventName};
        
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
    
    function registerEventHandler(obj, group, handler)
      handlers = obj.([group 'EventHandlers']);
      
      if ~iscell(handlers)
        handlers = {};
      end
      
      if ~any(handlers==handler)
        handlers{end+1} = handler;
        obj.([group 'EventHandlers']) = handlers;
      end
    end
    
    function consumed = callEventHandlers(obj, group, name, source, event)
      try
        consumed = false;
        try consumed = event.consumed; end
        
        handlers = obj.([group 'EventHandlers']);
        if iscell(handlers) && ~isempty(handlers)
          for i = 1:numel(handlers)
            try
              consumed = eval([ 'handlers{i}.On' name '(obj, event);']);
              event.consumed = event.consumed || consumed;
            end
          end
        end
        consumed = event.consumed;
      end
    end
    
    %     function callbackEvent(obj, source, event)
    %       disp(toString(event));
    %
    %       eventFunction = [event.EventName 'Function'];
    %
    %       try
    %         feval(str2func(['@' obj.(eventFunction)]), obj, event);
    %       catch err
    %         disp(['Function callback error ' err.identifier ': ' err.message]);
    %       end
    %     end
    
    function OnTest(obj, source, event)
      disp(event);
    end
  end
  
  methods (Static)
    function callbackEvent(source, event, obj, eventName, varargin)
      % try disp(WorkspaceVariables); end
      
      if nargin==2 && isa(source, 'Grasppe.Core.EventHandler')
        % disp(toString({source, event}));
        obj = source;
        eventName     = event.EventName;
        eventFunction = ['On' eventName];
      elseif nargin==4 && isa(obj, 'Grasppe.Core.EventHandler')
        % disp(toString({source, event, obj, eventName}));
        eventFunction = ['On' eventName];
      elseif nargin==6 && isa(varargin{1}, 'Grasppe.Core.EventHandler')
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
          event = Grasppe.Core.EventData(eventFunction, event);
      end
      
      try
        feval(str2func(eventFunction), obj, source, event);
        % return;
      catch err
        % disp(['Function callback error ' err.identifier ': ' err.message]);
      end
      
      %       if ~isempty(strfind(eventName, 'Click')) && ~isa(obj,'Grasppe.Graphics.Figure')
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
        eventData = Grasppe.Core.EventData;
        eventData.Name  = eventName;
        eventData.Data  = data;
      end
      
      
      try
        if ~isa(source, 'Grasppe.Core.Component') % isnumeric(source) isempty(event)
          notify(obj, eventName, eventData);
        end
      end
      
    end
    
  end
  
end

