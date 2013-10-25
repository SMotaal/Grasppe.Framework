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
      
      steps   = size(map,1);
      %       if isempty(obj.Size)
      %         obj.Size  = steps;
      %       else
      %         steps     = obj.Size;
      %       end
      
      % if rem(steps,2)==0
      %   steps = steps + 1;
      %   obj.Size  = steps;
      % end
      steps     = steps + rem(steps, 2); %min(17, max(7, steps + ~rem(steps, 2))); %max(14, 
      obj.Size  = steps;
      
      patches   = round(linspace(1, size(map,1), steps)); %round((1:steps/steps).*size(map,1));
      patchct   = 1:numel(patches);
      xData     = [patchct; 0 patchct(1:end-1); 0 patchct(1:end-1); patchct; patchct];
      yData     = repmat([0 0 1 1 0]',1,size(xData,2));
      zData     = repmat(patches,5,1);
      
      obj.ColorMap  = map;
      
      obj.XData = xData;
      obj.YData = yData;
      obj.ZData = zData;
      
      try delete(obj.PatchHandle); end
      
      obj.PatchHandle = patch(xData, yData, zData, 'Parent', obj.Handle, ...
        'EdgeColor', 'none', 'LineStyle', 'none');
      
      obj.registerHandle(obj.PatchHandle);
      
      obj.XTick = [];
      obj.YTick = [];
      obj.ZTick = [];
      obj.Box   = 'on';
      obj.handleSet('Clipping', 'on');
      obj.handleSet('LineWidth', 1);
      
      obj.CLim  = [1 size(map,1)];
      obj.YLim  = [min(yData(:)) max(yData(:))];      
      obj.XLim  = [min(xData(:)) max(xData(:))];
      
      return;
    end
    
    function updateLimits(obj)
      
      obj.bless;
      
      plotAxes  = obj.ParentFigure.PlotAxes;
      steps     = obj.Size + 1;
      
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
        
        steps     = obj.Size + 1;

        for m = 1:2:steps %1+round([0 25 50 75 100]*(steps-1)/100)2:
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
            string = [string ' ' num2str(val,'%1.1f')];
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
        label.FontSize = 5.5; %obj.FontSize;
        %label.FontWeight = 'bold';
        label.HandleObject.HorizontalAlignment  = 'center';
        label.HandleObject.VerticalAlignment    = 'middle';
        label.IsClickable = false;
        
%         try
%           stepColor = obj.ColorMap(index,:);
%         catch
%           stepColor = obj.ColorMap(index-1,:);
%         end
%         
%         stepLAB  = Color.sRGB2Lab(stepColor(:));
%         
%         %[index stepColor stepLAB']
%         
%         if stepLAB(1) < 0.65 %mean(stepGray<0.5)
%           label.Color = 'w';
%         else
          label.Color = 'k';
%         end
        
      catch err
        debugStamp(err, 1, obj);
      end
      
    end
    
    function positionLabel(obj, index)
      
      obj.bless;
      
      try
        label = obj.getLabel(index);
        
        x = index - 1;
        y = 1.25;
        
        label.HandleObject.Position = [x y 5];
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
      %obj.createLabels;
    end
    
  end
end

