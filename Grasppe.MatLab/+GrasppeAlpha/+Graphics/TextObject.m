classdef TextObject < GrasppeAlpha.Graphics.AnnotationComponent
  %TEXT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'text';
    
    TextObjectHandleProperties = { ...
      {'Text', 'String'}, 'Color', 'Clipping', 'Margin', 'Rotation', 'Interpreter'};
    
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Text, Color, Clipping='off', Margin=5, Rotation, Interpreter='tex';
  end
  
  methods
    function obj = TextObject(parentAxes, varargin)
      obj = obj@GrasppeAlpha.Graphics.AnnotationComponent(parentAxes, varargin{:});
    end
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.createComponent@GrasppeAlpha.Graphics.InAxesComponent;
      
      %@(s,e)OnResize(obj, s, e));
    end
    
    function createHandleObject(obj)
      string = obj.Text;
      if ~ischar(string), string = ''; end
      obj.Handle = text(0.5, 0.5, 0, string, 'Parent', obj.ParentAxes.Handle);
    end
    
    function decorateComponent(obj)
      GrasppeAlpha.Graphics.Decorators.FontDecorator(obj);
    end
    
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      IsClickable   = false;
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  
end

