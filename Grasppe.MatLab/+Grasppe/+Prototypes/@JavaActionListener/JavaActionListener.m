classdef JavaActionListener < Grasppe.Prototypes.Instance
  %JAVAACTIONLISTENER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden)
    JavaAction
    ActionListener
  end
  
  events
    JavaEvent
  end
  
  methods % (Access=private)
    function obj=JavaActionListener(action)
      if ~exist('action', 'var') || ~isjava(action)
        error('Grasppe:JavaActionListener:NotJavaObject', ...
          'A java object must be supplied to the action')
      end
      obj                       = obj@Grasppe.Prototypes.Instance();
      % obj.attachCallbackEvent(action);
      obj.JavaAction            = action;
    end
  end
  
  methods
    function set.JavaAction(obj, action)
      if isempty(obj.JavaAction)
        obj.attachCallbackEvent(action);
        obj.JavaAction          = handle(action,'callbackproperties');
      end
    end
    
    function attachCallbackEvent(obj, jAction)
      if ~exist('jAction', 'var') || isempty(jAction)
        detatchCallbackEvent;
        return;
      end
      
      hAction                   = handle(jAction,'callbackproperties');
      
      hasCallbacks              = ...
        ~isempty(findprop(hAction, 'PropertyChangeCallback')) && ...
        ~isempty(findprop(hAction, 'PropertyChangeCallbackData')) && ...
        ~isempty(findprop(hAction, 'PropertyChangeListeners'));
      
      hListener                 = handle.listener(hAction, 'PropertyChange', @obj.fireCallbackEvent);
      
      obj.ActionListener        = hListener;
    end
    
    function detatchCallbackEvent(obj)
      try delete(obj.ActionListener); end
      try obj.ActionListener    = []; end
      try obj.JavaAction        = []; end
    end
    
    function fireCallbackEvent(obj, source, event)
      try
        callback.Object.ID    = obj.ID;
      end
      
      callback.Object.Class   = class(obj);
      %callback.Classes.Source   = class(source);
      %callback.Classes.Event    = class(event);
      %callback.Object         	= struct(obj);
      try
        callback.Source         = struct(get(source));
      catch err
        try
          callback.Source       = get(source.java);
        end
      end
      callback.Event            = struct(event);
      %       try
      %         callback.JavaEvent      = struct(event.JavaEvent);
      %       end
      
      %       try
      callback.Data.Name      = source.PropertyChangeCallbackData.getPropertyName;
      %       end
      
      %       try
      callback.Data.Data      = source.PropertyChangeCallbackData.getOldValue;
      %       end
      
      %       try
      callback.Data.Metadata  = source.PropertyChangeCallbackData.getNewValue;
      %       end
      
      % structTree(callback)
      
      obj.notify('JavaEvent', Grasppe.Prototypes.EventData(source, char(callback.Data.Name), callback));
    end
    
    function fireAction(obj, actionName, data, matadata)
      
      if ~exist('actionName', 'var') || isempty(actionName) || ~ischar(actionName)
        try
          actionName = obj.ID; % regexprep(, '\w+\.','');
        catch err
          actionName = regexprep(class(obj), '\w+\.','');
        end
      end
      
      switch(nargin)
        case {1, 2}
          obj.JavaAction.java.fireAction(actionName);
        case 3
          obj.JavaAction.java.fireAction(actionName, data);
        case 4
          obj.JavaAction.java.fireAction(actionName, data, matadata);
      end
      
    end
    
    function delete(obj)
      obj.detatchCallbackEvent;
    end
  end
  
end

