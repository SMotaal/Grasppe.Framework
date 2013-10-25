classdef ColorBar < GrasppeAlpha.Graphics.Axes
  %COLORBAR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %     ColorBarProperties = {
    %       %       'ALim',         'Alpha',            'Plot Limits',    'limits',   '';   ...
    %       %       'CLim',         'Color Map',        'Plot Limits',    'limits',   '';   ...
    %       %       'XLim',         'X',                'Plot Limits',    'limits',   '';   ...
    %       %       'YLim',         'Y',                'Plot Limits',    'limits',   '';   ...
    %       %       'ZLim',         'Z',                'Plot Limits',    'limits',   '';   ...
    %       %       ...
    %       %       'View',         'Viewpoint',        'Plot View',      'view',     '';   ...
    %       %       'Projection',   'Projection',       'Plot View',      'view',     '';   ...
    %       %       ...
    %       %       'Color',        'Axes Background',  'Plot Style',     'color',    '';   ...
    %       %       ...
    %       %       'XLable',       'X',                'Plot Labels',    'string',   '';   ...
    %       %       'YLable',       'Y',                'Plot Labels',    'string',   '';   ...
    %       %       'ZLable',       'Z',                'Plot Labels',    'string',   '';   ...
    %       'Location',     'Anchor'            'Color Bar',      'anchor',   ''; ...
    %       % 'Axes',         'Axes'              'Color Bar',      'handle',   ''; ...
    %
    %       };
    %
    %     ColorBarHandleProperties = { ...
    %       'Location' %, 'Axes'
    %       };
    
  end
  
  
  properties (SetObservable, GetObservable, AbortSet)
    Location
    ColorMap
    ColorLimits
  end
  
  properties
    Axes
    LabelObjects
    Size
    XData
    YData
    ZData
    LabelData
    AxesMap
    PatchSteps
    PatchHandle
  end
  
  properties (Dependent)
    AxesHandle
  end
  
  methods
    function obj = ColorBar(varargin)
      obj = obj@GrasppeAlpha.Graphics.Axes(varargin{:});
    end
    
    function h = get.AxesHandle(obj)
      h = [];
      try h = obj.Axes.Handle; end;
    end
    
    
  end
  
  methods
    
    function h = createPatches(obj)
      
      obj.bless;
      
      map     = colormap(obj.ParentFigure.Handle);
      
      steps   = max(min(15, size(map,1)), 3);
      % if isempty(obj.Size)
      %   obj.Size  = steps;
      % else
      %   steps     = obj.Size;
      % end
      
      %steps = steps + (rem(steps, 2)~=1);
      
      if rem(steps,2)==0
        steps = steps + 1;
      end
      
      obj.Size  = steps;
      
      patches = round(linspace(1, size(map,1), steps)); %round((1:steps/steps).*size(map,1));
      patchct = 1:numel(patches);
      xData   = [patchct; 0 patchct(1:end-1); 0 patchct(1:end-1); patchct; patchct];
      yData   = repmat([0 0 1 1 0]',1,size(xData,2));
      zData   = zeros(size(xData)); %repmat(patches,5,1);
      cData   = repmat(patches,5,1);
      
      obj.ColorMap  = map;
      
      obj.XData = xData;
      obj.YData = yData;
      obj.ZData = cData;
      %obj.CData = cData;
      
      obj.XTick = [];
      obj.YTick = [];
      obj.ZTick = [];
      % obj.Box   = false;
      obj.handleSet('Clipping', 'off');
      obj.handleSet('Box', 'off');
      obj.handleSet('Visible', 'off');
      % obj.handleSet('LineWidth', 1);
      
      obj.CLim  = [1 size(map,1)];
      obj.YLim  = [min(yData(:))-0.25 max(yData(:))+0.25];      
      obj.XLim  = [min(xData(:))-0.25 max(xData(:))+0.25];
      
      try delete(obj.PatchHandle); end
      
      obj.PatchHandle(1) = patch(xData, yData, zData, cData, 'Parent', obj.Handle, ...
        'EdgeColor', 'none', 'LineStyle', '-');
      
      obj.PatchHandle(2) = patch(...
        [0 1 1 0 0] * numel(patches), [0 0 1 1 0], [0 0 0 0 0], [NaN NaN NaN NaN NaN], 'Parent', obj.Handle, ...
        'EdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 0.5, 'LineSmoothing', 'on');
      
      obj.registerHandle(obj.PatchHandle(1));
      obj.registerHandle(obj.PatchHandle(2));
      
      
      return;
    end
    
    function updateLimits(obj)
      
      obj.bless;
      
      plotAxes  = obj.ParentFigure.PlotAxes;
      steps     = obj.Size;
      
      if isempty(plotAxes), return; end
      
      plotCount   = numel(plotAxes);
      limits      = nan(plotCount, 2);
      
      for m = 1:plotCount
        try limits(m,:) = plotAxes{m}.handleGet('clim'); end
      end
      
      nanLimits = max(isnan(limits),[],2)==1;
      limits(nanLimits,:) = nan;
      
      [limits, uniqueIdx, limitIdx] = unique(limits, 'rows');
      limitCount  = size(limits,1);
      
      labelData   = zeros(limitCount, steps);
      
      for m = 1:limitCount
        limit = limits(m,:);
        if any(isnan(limit)), continue; end
        
        labelData(m,:) = linspace(limit(1), limit(2), steps);
      end
      
      obj.AxesMap   = limitIdx;
      obj.LabelData = labelData;
    end
    
    function createLabels(obj)
      
      obj.bless;
      
      
      try obj.deleteLabels; end
      try
        obj.updateLimits();
        
        steps = obj.Size;

        for m = 1:2:steps %1+round([0 25 50 75 100]*(steps-1)/100)
          obj.createLabel(m);
        end
        
      catch err
        debugStamp(err, 1, obj);
      end
    end
    
    function createLabel(obj, index)
      
      obj.bless;
      
      label = [];
      
      if ~exist('index', 'var') || isempty(index)
        index = numel(obj.LabelObjects)+1;
      else
        try label = obj.LabelObjects{index}; end
      end
      
      
      if isempty(label) % Create Label
        try
          label = GrasppeAlpha.Graphics.TextObject(obj, 'Text', int2str(index), 'IsVisible', 'on'); ...
            obj.registerHandle(label);
        catch err
          warning('Plot must be attached before creating labels');
          return;
        end
        obj.registerHandle(label);
        obj.LabelObjects{index} = label;
      end
      
      obj.formatLabel(index);
      obj.positionLabel(index);
      obj.updateLabel(index);
    end
    
    function updateLabel(obj, index)
      
      obj.bless;
      
      try
        label   = obj.getLabel(index);
        
        values  = obj.LabelData(:,index);
        string  = '';
        
        for m = 1:numel(values)
          val = values(m);
          %[val ex] = sciparts(values(m));
%           if ex==0
            string = [string ' ' num2str(val,'%1.2f')];
%           elseif ex==1
%             string = [string ' ' num2str(val*10,'%1.0f')];
%           else
%             string = [string ' ' sprintf('%1.0fe%+d', val*10,ex-1)];
%           end
        end
        
        string  = strtrim(sprintf(regexprep(string,'\s+','\n')));
        
        label.Text = string;
      catch err
        debugStamp(err, 1, obj);
      end
      
    end
    
    function formatLabel(obj, index)
      
      obj.bless;
      
      try
        label = obj.getLabel(index);
        label.FontSize    = 6.5; %obj.FontSize;
        label.FontName    = 'Gill Sans MT';
        label.FontWeight    = 'Bold';
        %label.FontWeight = 'bold';
        label.HandleObject.HorizontalAlignment  = 'center';
        label.HandleObject.VerticalAlignment    = 'middle';
        label.IsClickable = false;
        
        stepColor = obj.ColorMap(index,:);
                
        if max(stepColor) < 0.75 && mean(stepColor)<0.75
          label.Color = 'w';
        else
          label.Color = 'k';
        end
        
      catch err
        debugStamp(err, 1, obj);
      end
      
    end
    
    function positionLabel(obj, index)
      
      obj.bless;
      
      try
        label = obj.getLabel(index);
        
        x = index - 0.5;
        y = 0.5;
        
        label.HandleObject.Position = [x y size(obj.ColorMap,1) + 10];
      end
    end
    
    function label = getLabel(obj, index)
      
      obj.bless;
      
      label = [];
      label = obj.LabelObjects{index};
      %if isempty(label), return; end
    end
    
    function deleteLabels(obj)
      try
        for m = 1:numel(obj.LabelObjects)
          try
            delete(obj.LabelObjects{m});
          catch err
            debugStamp(err, 1, obj);
          end
          obj.LabelObjects{m} = [];
        end
      catch err
        debugStamp(err, 1, obj);
      end
      
      obj.LabelObjects = {};
    end
    
  end
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.ParentFigure = obj.Axes.ParentFigure;
      obj.Axes.PropertyQueing = true;
      
      obj.createHandleObject@GrasppeAlpha.Graphics.Axes;
      obj.handleSet('Tag', '#ColorBarAxes');      
      obj.createPatches;
      
      obj.Axes.PropertyQueing = false;
      
      obj.updateLimits;
      obj.createLabels;
    end
    
  end
end

