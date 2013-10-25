classdef InAxesComponent < GrasppeAlpha.Graphics.HandleGraphicsComponent ... % & GrasppeAlpha.Core.DecoratedComponent & GrasppeAlpha.Core.EventHandler
      & GrasppeAlpha.Core.MouseEventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)   
    InAxesComponentHandleProperties = {};
    
    InAxesComponentHandleFunctions = {{'MouseDownFunction', 'ButtonDownFcn'}};
    
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    ParentAxes
  end
  
  
  properties (Dependent)
    ParentFigure
  end
  
    
  methods
    function obj = InAxesComponent(varargin)
      obj = obj@GrasppeAlpha.Graphics.HandleGraphicsComponent(varargin{:});
    end
    
    
    function set.ParentAxes(obj, parentAxes)
      
      if isempty(parentAxes), return; end
      if ~GrasppeAlpha.Graphics.Axes.checkInheritence(parentAxes)
        %error('Grasppe:ParentAxes:NotAxes', 'Attempt to set parent axes to a non-axes object.');
        obj.ParentAxes = [];
        %obj.Parent = [];
        return;
      end
      try
        obj.ParentAxes = parentAxes;
        obj.Parent = parentAxes.Handle;
      catch err
        try debugStamp(err, 1, obj); catch, debugStamp(); end;
        obj.ParentAxes = [];
      end
      
    end
        
    function parentFigure = get.ParentFigure(obj)
      parentFigure = [];       
      %if ~obj.HasParentAxes return; end
      try parentFigure = obj.ParentAxes.ParentFigure; end
    end
    
  end
  
  methods % (Hidden)
    
    function OnMouseDoubleClick(obj, source, event)
      try obj.ParentAxes.OnMouseDoubleClick(source, event); end
    end
    
  end  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  %   methods(Abstract, Static, Hidden)
  %     options  = DefaultOptions()
  %     obj = Create()
  %   end
  
  
end

