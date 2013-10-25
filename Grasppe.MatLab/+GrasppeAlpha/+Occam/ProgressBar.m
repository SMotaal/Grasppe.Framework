classdef ProgressBar < GrasppeAlpha.Core.Prototype
  %PROGRESSBAR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    jProgressBar, hContainer, jhProgressBar;
  end
  
  properties (Dependent)
    Position
    Parent
    Progress
    Process
  end
  
  properties (Hidden)
    jComponents   = {}    
    progress      = [];
    position      = [20 20 200 18];
    parent        = [];
    process       = [];
  end
  
  methods 
  
  end
  
  %% FUNCTIONAL METHODS
  methods
    function progress = get.Progress(obj)
      progress = obj.progress;
    end
    
    function set.Progress(obj, progress)
      if ~isequal(obj.progress, progress)
        obj.progress = progress;
        obj.UpdateProgress;
      end
    end
    
    function UpdateProgress(obj)
      progress = obj.progress;
      
      if ~ishandle(obj.jProgressBar) || ~isa(obj.jProgressBar, 'javax.swing.JProgressBar');
        obj.UpdateComponent;
      end
      
      if isnumeric(progress) && isscalar(progress)
        jProgressBar.setValue(progress);
        jProgressBar.setIndeterminate(false);
      else %if isempty(progress) || ~isnumeric(progress) || ~isscalar(progress)
        jProgressBar.setIndeterminate(true);
      end
    end
    
    function set.Process(obj, process)
      if ~isequal(obj.process, process)
        obj.process = process;
        obj.UpdateProgress;
      end
    end
    
    function process = get.Process(obj)
      process = obj.process;
    end
    
    function progressUpdate(obj, src, evt)
      process = [];
      
      try
      if isempty(process) && ...
          (isa(obj.Process, 'GrasppeAlpha.Occam.Process') || isa(obj.Process, 'GrasppeAlpha.Occam.ProcessProgress'))
        process = obj.Process;
      end
      
      end
      
      try
      if isempty(process) && ...
          (isa(src, 'GrasppeAlpha.Occam.Process') || isa(src, 'GrasppeAlpha.Occam.ProcessProgress'))
        process = src;
      end
      end
      
      try
      if isempty(process)
        obj.Progress = [];
        return;
      end      
      end
      
      try
      if isa(process, 'GrasppeAlpha.Occam.Process')
        process = src.ProcessProgress;
      end
      end
      
      try
      if isa(process, 'GrasppeAlpha.Occam.ProcessProgress')
        obj.Progress = obj.process.OverallProgress;
      end
      end
    end
  end
  
  %% JAVA COMPONENT METHODS
  methods
    
    function position = get.Position(obj)
     position = obj.position;
     
     if ishandle(obj.hContainer)
       position = get(obj.hContainer, 'Position');
       obj.position = position;
     end
    end
    
    function set.Position(obj, position)
     if ishandle(obj.hContainer)
       set(obj.hContainer, 'Position', position);
       position = get(obj.hContainer, 'Position');
     end
     
     obj.position = position;
    end
    
    function parent = get.Parent(obj)
     parent = obj.parent;
     
     if ishandle(obj.hContainer)
       parent = get(obj.hContainer, 'Parent');
       obj.parent = parent;
     end
    end
    
    function set.Parent(obj, parent)
     if ishandle(obj.hContainer)
       set(obj.hContainer, 'Parent', parent);
       parent = get(obj.hContainer, 'Parent');
     end
     
     updateParent = ~isequal(obj.parent, parent);
        
     obj.parent = parent;
     
     if updateParent
       obj.UpdateComponent;
     end     
    end
    
    function UpdateComponent(obj)
      
      if isempty(obj.jProgressBar)
        jProgressBar        = javax.swing.JProgressBar;
        obj.jProgressBar    = jProgressBar;        
        jProgressBar.setIndeterminate(true);
        
        obj.jComponents{end+1}  = jProgressBar;
      end
      
      if isempty(obj.jhProgressBar) || isempty(obj.hContainer)
        options  = {jProgressBar};
        
        if ~isempty(obj.Parent) && ishandle(obj.Parent)
          options = {jProgressBar, obj.Position, obj.Parent};
        end
        
        [jhProgressBar, hContainer] = javacomponent(options{:});
        
        obj.jhProgressBar   = jhProgressBar;
        obj.hContainer      = hContainer;
      end
    end
    
    function delete(obj)
      
      jComponents = obj.jComponents;
      
      for j = 1:numel(jComponents)
        jObject = jComponents{j};
        try delete(jObject); end
      end
      
      obj.jComponents = {};
      
    end
    
  end
  
end

