classdef PlotFigure < Grasppe.Graphics.Figure
  %PLOTFIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    PlotFigureProperties = {
      'BaseTitle',    'Plot Title',       'Labels',     'string',   '';   ...
      };
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Title, BaseTitle, SampleTitle, Status
    TitleText, PlotAxes, OverlayAxes, ColorBar
    StatusText;
    
  end
  
  properties (Dependent, Hidden)
    TitleTextHandle, PlotAxesHandle, OverlayAxesHandle, ColorBarHandle
    StatusTextHandle
  end
  
  
  methods
    
    function obj = PlotFigure(varargin)
      obj = obj@Grasppe.Graphics.Figure(varargin{:});
    end
    
    
    %% Title
    function set.Title(obj, value)
      % obj.Title = strtrim(value);
      % if isValidHandle('obj.TitleTextHandle')
      %   set(obj.TitleTextHandle, 'String', value);
      % end
      % try obj.TitleText.updateTitle; end
      % try value = strtrim(value); end
      try obj.Title = value; end
      try obj.TitleText.Text = [obj.Title '   ']; end % '               ']; end
    end
    
    
    %% BaseTitle
    function set.BaseTitle(obj, value)
      obj.BaseTitle = changeSet(obj.BaseTitle, value);
      obj.updatePlotTitle;
    end
    
    %% SampleTitle
    function set.SampleTitle(obj, value)
      obj.SampleTitle = changeSet(obj.SampleTitle, value);
      obj.updatePlotTitle;
    end
    
    %% Title Text
    function handle = get.TitleTextHandle(obj)
      handle = []; try handle = obj.TitleText.Handle; end
    end
    
    function handle = get.StatusTextHandle(obj)
      handle = []; try handle = obj.StatusText.Handle; end
    end
    
    %% Plot Axes
    function set.PlotAxes(obj, plotAxes)
      obj.PlotAxes = plotAxes;
    end
    
    function handle = get.PlotAxesHandle(obj)
      handle = []; try handle = obj.PlotAxes.Handle; end
    end
    
    %% Overlay Axes
    function handle = get.OverlayAxesHandle(obj)
      handle = []; try handle = obj.OverlayAxes.Handle; end
    end
    
    %% ColorBar
    function handle = get.ColorBarHandle(obj)
      handle = []; try handle = obj.ColorBar.Handle; end
    end
    
  end
  
  
  methods (Access=protected, Hidden)
    function createComponent(obj)
      obj.createComponent@Grasppe.Graphics.Figure();
      obj.preparePlotAxes;
      obj.OverlayAxes = Grasppe.Graphics.OverlayAxes('ParentFigure', obj);  %OverlayAxesObject.Create(obj);
      % obj.StatusText  = OverlayTextObject.Create(obj.OverlayAxes);
      obj.TitleText   = Grasppe.Graphics.TextObject(obj.OverlayAxes);
      
      obj.TitleText.handleSet('Tag', [obj.TitleText.handleGet('Tag') '@Screen']);
      % obj.TitleText.updateTitle;
      
    end
    
    function preparePlotAxes(obj)
      obj.PlotAxes    = Grasppe.Graphics.PlotAxes('ParentFigure', obj);
    end
        
    function updatePlotTitle(obj)
      if isempty(obj.SampleTitle)
        obj.Title = [obj.BaseTitle]; % ' (' obj.SampleTitle ')'];
      else
        obj.Title = [obj.BaseTitle ' (' obj.SampleTitle ')'];
      end
      try statusbar(obj.Handle, ''); end
      try refresh(obj.Handle); end
    end
    
    
    
  end
  
  methods (Hidden)
       
    function OnMousePan(obj, source, event)
      try
        try
          if isa(source, 'Grasppe.Graphics.PlotAxes')
            plotAxes = source;
          else
            plotAxes = source.ParentAxes;
          end
        end
        obj.panAxes(plotAxes, event.Data.Panning.Current, event.Data.Panning.Length);
      catch err
        % try dispf('Failed to pan %s: %s', source.ID, err.message); end
      end
    end
    
  end
  
  methods
    
    function OnKeyPress(obj, source, event)
      shiftKey = stropt('shift', event.Data.Modifier);
      commandKey = stropt('command', event.Data.Modifier) || stropt('control', event.Data.Modifier);
      
      % 
      
      if ~event.Consumed
      
        if commandKey
          switch event.Data.Key
            case 'w'
              obj.OnClose(source, event);
              event.Consumed = true;
              return;
            case 'm'
              if shiftKey
                if strcmp(obj.WindowStyle, 'docked')
                  obj.WindowStyle = 'normal';
                end
                try obj.JavaObject.setMaximized(true); end
              else
                try obj.JavaObject.setMinimized(true); end
              end
              event.Consumed = true;
            case 'd'
              try
                if strcmp(obj.WindowStyle, 'docked')
                  obj.WindowStyle = 'normal';
                else
                  obj.WindowStyle = 'docked';
                end
              end
              event.Consumed = true;
          end
        end
        
      end
      
      if ~event.Consumed, obj.OnKeyPress@Figure(source, event); end
      
    end
    
    function panAxes(obj, plotAxes, panXY, panLength) % (obj, source, event)
      persistent lastPanXY
      
      if isequal(plotAxes.ViewLock, true), return; end
      
      panStickyThreshold  = 3.45;
      panStickyAngle      = 45/2;
      panWidthReference   = 600;
      
      %       lastPanToc  = 0;
      %       try lastPanToc = toc(lastPanTic); end
      
      if isempty(lastPanXY) || panLength==0;
        deltaPanXY  = [0 0];
      else
        deltaPanXY  = panXY - lastPanXY;
        position    = obj.handleGet('Position');
        panFactor   = position([3 4])./panWidthReference;
        deltaPanXY  = round(deltaPanXY ./ (panFactor));
      end
      
      try
        newView = plotAxes.View - deltaPanXY;
        
        if newView(2) < 0
          newView(2) = 0;
        elseif newView(2) > 90
          newView(2) = 90;
        end
        
        if panStickyAngle-mod(newView(1), panStickyAngle)<panStickyThreshold || ...
            mod(newView(1), panStickyAngle)<panStickyThreshold
          newView(1) = round(newView(1)/panStickyAngle)*panStickyAngle;
        end
        if panStickyAngle-mod(newView(2), panStickyAngle)<panStickyThreshold || ...
            mod(newView(2), panStickyAngle)<panStickyThreshold
          newView(2) = round(newView(2)/panStickyAngle)*panStickyAngle; % - mod(newView(2), 90)
        end
        
        plotAxes.View = newView;
        
      catch err
        warning('Grasppe:MouseEvents:PanningFailed', err.message);
      end
      
      lastPanXY   = panXY;
      lastPanTic  = tic;
      
      %consumed = obj.mousePan@GraphicsObject(source, event);
    end
    
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      WindowTitle     = 'Printing Uniformity Plot'; ...
        BaseTitle     = 'Printing Uniformity'; ...
        Color         = 'white'; ... %Toolbar       = 'none';  ...%Menubar       = 'none'; ...
        WindowStyle   = 'normal'; ...
        Renderer      = 'opengl'; ...
        %#ok<NASGU>
      
      
      Grasppe.Utilities.DeclareOptions;

      %options = WorkspaceVariables(true);
    end
  end
  
  
end

