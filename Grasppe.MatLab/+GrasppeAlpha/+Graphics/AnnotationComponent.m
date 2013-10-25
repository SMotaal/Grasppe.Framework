classdef AnnotationComponent < GrasppeAlpha.Graphics.InAxesComponent
  %ANNOTATIONCOMPONENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    
    AnnotationComponentHandleProperties = {'Position', 'Units'};
    
  end
  properties (SetObservable, GetObservable, AbortSet)
    Position
    Units
  end
  
  methods
    function obj = AnnotationComponent(parentAxes, varargin)
      obj = obj@GrasppeAlpha.Graphics.InAxesComponent(varargin{:},'ParentAxes', parentAxes);
    end
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.createComponent@GrasppeAlpha.Graphics.InAxesComponent;
      % addlistener(obj.ParentFigure, 'Resize', @obj.OnResize);
    end
    
    function createHandleObject(obj)
      % obj.Handle = text(0.5, 0.5, 0, obj.Text, 'Parent', obj.ParentAxes.Handle);
    end
    
    function decorateComponent(obj)
      % GrasppeAlpha.Graphics.Decorators.FontDecorator(obj);
    end
    
  end
  
  methods
    function OnResize(obj, source, event)
      % disp('resized');
    end
  end
  
end

