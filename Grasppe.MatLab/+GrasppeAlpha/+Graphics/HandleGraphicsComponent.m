classdef HandleGraphicsComponent < GrasppeAlpha.Core.HandleComponent ...
    & GrasppeAlpha.Core.DecoratedComponent & GrasppeAlpha.Core.EventHandler
  %HANDLEGRAPHICSOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    HandleGraphicsComponentProperties = {
      'IsVisible',    'Is Visible',       'View',     'logical',   '';   ...
      };
    
    
    HandleGraphicsComponentHandleProperties = {'Parent', {'Children', 'Children', 'readonly'}, ...
      {'CallbackQueueMode', 'BusyAction'}, {'CallbackInterruption', 'Interruptible'}, ...      
      'HandleVisibility', {'IsDestructing','BeingDeleted', 'readonly'}, ...
      {'IsHighlightable', 'SelectionHighlight'}, {'ContextMenu', 'UIContextMenu'}, ...
      {'IsVisible', 'Visible'}, {'IsSelected', 'Selected'}, {'IsClickable', 'HitTest'}, ...
      };
    
    
    HandleGraphicsComponentHandleFunctions = { ... % {'CreateFunction', 'CreateFcn'}, 
      {'DeleteFunction', 'DeleteFcn'}}; %, {'ButtonDownFunction', 'ButtonDownFcn'}};
    
  end
  
  events
    Delete
    %ButtonDown % Create
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Parent
    Children    
    IsClickable           = true
    IsVisible             = [];
    IsSelected            = false
    HandleVisibility      = true
    IsDestructing         = false
    IsHighlightable       = true
    CallbackQueueMode
    CallbackInterruption
    ContextMenu
  end
  
  properties (SetObservable, GetObservable, AbortSet, Hidden)
  end
  
  methods
    function obj = HandleGraphicsComponent(varargin)
      obj = obj@GrasppeAlpha.Core.DecoratedComponent();      
      obj = obj@GrasppeAlpha.Core.EventHandler();
      obj = obj@GrasppeAlpha.Core.HandleComponent(varargin{:});
      
      try obj.OnResize; end
    end
    
    function delete(obj)
      debugStamp(obj, 5);
      try set(obj.Handle, 'Visible', 'off'); end
      try
        children = obj.handleGet('Children');
        for m = 1:numel(children)
          try
            child     = [];
            try child = getappdata(children(m), 'PrototypeHandle'); end
            %child = get(children(m), 'UserData');
            if isa(child, 'GrasppeAlpha.Graphics.HandleGraphicsComponent')
              try delete(child); end
            end
            child = [];
            try delete(children(m)); end;
          end
          children(m) = [];
        end
      end
      try delete(obj.Handle); end
    end
  end
    
  methods (Access=protected, Hidden=false)
    
  end
  
  methods % (Hidden)
    
    function OnCreate(obj, source, event)
      disp(['Creating handle for ' obj.ID]);
    end
        
    function OnDelete(obj, source, event)
      debugStamp(obj, 5);
      obj.IsDestructing = true;
    end
    
    function OnButtonDown(obj, source, event)
    end
  end
  
  methods(Hidden)
    function objectPostSet(obj, source, event)
      if isOn(obj.IsDestructing), return; end
      obj.objectPostSet@GrasppeAlpha.Core.HandleComponent(source, event);
    end
    
    
    function handlePostSet(obj, source, event)
      if isOn(obj.IsDestructing), return; end
      obj.handlePostSet@GrasppeAlpha.Core.HandleComponent(source, event);
    end
  end
  
  methods
    function handleSet(obj, name, value)
      if isOn(obj.IsDestructing), return; end
      
      switch lower(name)
        case 'position'
          try value(1:2)    = max(value(1:2),   0); end
          try value(3:end)  = max(value(3:end), 1); end
      end
      
      obj.handleSet@GrasppeAlpha.Core.HandleComponent(name, value);
    end
    
    function value = handleGet(obj, name)
      value = [];
      if isOn(obj.IsDestructing), return; end
      value = obj.handleGet@GrasppeAlpha.Core.HandleComponent(name);
    end 
    
    function bless(obj)
      isBlessed = isvalid(obj) && ~isequal(obj.IsDeleting, true) && ~isOn(obj.IsDestructing);
      
      if ~isBlessed
        debugStamp('Not Blessed', 5, obj);
        evalin('caller', 'return');
        return;
      end
      debugStamp('Blessed', 5, obj);
    end
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end
  
  
end

