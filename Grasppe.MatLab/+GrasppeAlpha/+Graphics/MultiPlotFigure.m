classdef MultiPlotFigure < GrasppeAlpha.Graphics.PlotFigure
  %MULTIPLOTFIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    PlotAxesTargets = []; % = struct('id', [], 'idx', [], 'object', []);
    PlotAxesStack   = [];
    PlotAxesLength  = 1;
    
    PlotRows;
    PlotColumns;
    PlotWidth;
    PlotHeight;
    PlotArea;
    HiddenFigure    = figure('Visible', 'off');
    OutputFigure    = [];
    
  end
  
  properties (Dependent)
    ActivePlotAxes
  end
  
  methods
    
    function obj = MultiPlotFigure(varargin)
      obj = obj@GrasppeAlpha.Graphics.PlotFigure(varargin{:});
    end
    
    function OnResize(obj, varargin)
      obj.bless;
      
      obj.OnResize@GrasppeAlpha.Graphics.PlotFigure(varargin{:});
      obj.layoutPlotAxes;
      obj.layoutOverlay;
      
    end
    
    function activePlotAxes = get.ActivePlotAxes(obj)
      activePlotAxes      = [];
      try activePlotAxes = getappdata(obj.CurrentAxes, 'PrototypeHandle'); end
    end
    
    function set.ActivePlotAxes(obj, activePlotAxes)
      activePlotAxesComponent   = [];
      
      if isscalar(activePlotAxes) && ishghandle(activePlotAxes)
        activePlotAxesComponent = getappdata(activePlotAxes, 'PrototypeHandle');
      elseif isscalar(activePlotAxes) && isobject(activePlotAxes)
        activePlotAxesComponent = activePlotAxes;
      end
      
      if isa(activePlotAxesComponent, 'GrasppeAlpha.Graphics.PlotAxes') && ...
          isvalid(activePlotAxesComponent)
        try axes(activePlotAxesComponent.Handle); end
        try activePlotAxesComponent.updatePlotTitle; end
      end
      
    end
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.createComponent@GrasppeAlpha.Graphics.PlotFigure();
      
      obj.ColorBar = GrasppeAlpha.Graphics.ColorBar('Axes', obj.OverlayAxes, 'Size', 10);
      obj.OverlayAxes.registerHandle(obj.ColorBar);
      obj.registerHandle(obj.ColorBar);
      
      %obj.ColorBar.createPatches; obj.ColorBar.createLabels;
    end
    
    function plotAxes = newPlotAxes(obj)
      obj.bless;
      
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      
      nPlots                  = max([0 obj.PlotAxesLength]) + 1;
      obj.PlotAxesStack       = 1:nPlots;
      if ~isstruct(obj.PlotAxesTargets)
        obj.PlotAxesTargets   = struct('id', [], 'object', []);
      else
        obj.PlotAxesTargets(end+1) = struct('id', [], 'object', []);
      end
      if ~iscell(obj.PlotAxes)
        obj.PlotAxes          = cell(size(obj.PlotAxesTargets));
      else
        obj.PlotAxes{nPlots}  = [];
      end
      
      obj.PlotAxesLength      = nPlots;
      
      plotAxes                = obj.createPlotAxes([], []);
      %obj.PlotAxes{nPlots}    = plotAxes;
    end
    
    
    function preparePlotAxes(obj)
      obj.bless;
      
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      nPlots      = obj.PlotAxesLength;
      plotStack   = obj.PlotAxesStack;
      plotTargets = obj.PlotAxesTargets;
      
      if ~iscell(obj.PlotAxes) || ~isstruct(obj.PlotAxesTargets) || ~isnumeric(obj.PlotAxesStack) %|| any(cellfun('isempty',obj.PlotAxes))
        obj.PlotAxesStack   = 1:nPlots;
        obj.PlotAxesTargets = repmat(struct('id', [], 'object', []),1, nPlots);
        obj.PlotAxes        = cell(size(obj.PlotAxesTargets));
        
        for i = 1:nPlots
          obj.createPlotAxes([], []);
        end
      else
        disp('Flagged code in MutliPlotFigure is being used!');
        if ~isnumeric(plotStack) || length(plotStack)~=nPlots
          plotStack   = 1:nPlots;
          try
            newStacks = setdiff(plotStack, obj.PlotAxesStack);
            plotStack = [newStacks, obj.PlotAxesStack];
          end
        end
        
        if ~isstruct(plotTargets) || length(plotTargets)~=nPlots
          plotTargets(1:nPlots) = struct('id', [], 'object', []);
          try
            currentLength = length(obj.PlotAxesTargets);
            plotTargets(1:currentLength) = obj.PlotAxesTargets(:);
          end
        end
        
        obj.PlotAxesTargets = plotTargets;
        obj.PlotAxesStack   = plotStack;
        obj.PlotAxes        = plotTargets.object;
        
      end
      
      
    end
    
    function [plotAxes idx id] = createPlotAxes(obj, idx, id)
      
      obj.bless; %if isOn(obj.IsDestructing), return; end
      
      if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
      nextIdx = idx;  nextID  = id;
      
      nAxes = length(obj.PlotAxes);
      
      emptyIdx  = cellfun('isempty', {obj.PlotAxesTargets.object});
      
      if ~isempty(nextID) && ischar(nextID)
        targetIdx = strcmpi(nextID, {obj.PlotAxesTargets.id});
        if any(targetIdx)
          nextIdx = find(targetIdx,1,'first');
        else
          nextIdx = [];
        end
      end
      
      if isempty(nextIdx) || ~isnumeric(nextIdx) || nextIdx > nAxes || nextIdx < 1
        if any(emptyIdx);
          nextIdx   = find(emptyIdx,1,'first');
        else
          obj.PlotAxesStack = obj.PlotAxesStack([2:end 1]);
          nextIdx   = obj.PlotAxesStack(end);
        end
      end
      
      if isempty(nextID) || ~ischar(nextID)
        nextID = '';
      end
      
      plotAxesStruct = obj.PlotAxesTargets(nextIdx);
      
      plotAxesStruct.id = nextID;
      
      try
        plotAxesStruct.object.clearAxes()
        if ~plotAxesStruct.object.isvalid
          plotAxesStruct.object = PlotAxesObject.Create(obj);
        end
      catch
        plotAxesStruct.object = GrasppeAlpha.Graphics.PlotAxes('ParentFigure', obj);
      end
      
      try
        obj.formatPlotAxes(plotAxesStruct.object);
      end
      
      obj.PlotAxesTargets(nextIdx)  = plotAxesStruct;
      obj.PlotAxes(nextIdx)         = {plotAxesStruct.object};
      
      plotAxes  = plotAxesStruct.object;
      idx       = nextIdx;
      id        = nextID;
      
      try
        obj.ColorBar.createPatches; obj.ColorBar.createLabels;
      end
      
      obj.layoutPlotAxes();
    end
    
    function layoutOverlay(obj)
      obj.bless;
      
      plotArea      = obj.PlotArea;
      if ~isnumeric(plotArea) || numel(plotArea)~=4, return; end
      
      plotInset     = [5 5 5 5];
      try plotInset = obj.PlotAxes{1}.handleGet('LooseInset') + 5; end
      
      try
        set(obj.TitleText.Handle, 'Units', 'pixels');
        
        titlePosition = get(obj.TitleText.Handle, 'Position');
        titleExtent   = get(obj.TitleText.Handle, 'Extent');
        
        % titlePosition = [plotArea(1) + plotArea(3)/2 ... %-titleExtent(3))/2  ...
        %   plotArea(2)+plotArea(4)-(1*titleExtent(4))  ...
        %   titlePosition(3)]; %+plotArea(4)
        %
        % titlePosition = titlePosition - [0 plotInset(2)+plotInset(4) 0];
        
        titlePosition = [plotArea(1) plotArea(2)+plotArea(4) titlePosition(3)];
        
        titlePosition = titlePosition + [0 plotInset(2)+plotInset(4) 0];
      catch err
        debugStamp(err, 1, obj);
      end
      
      try
        set(obj.TitleText.Handle, 'Position', titlePosition, ...
          'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
        % obj.TitleText.handleSet('Position', titlePosition);
        % obj.TitleText.handleSet('HorizontalAlignment', 'left');
        % obj.TitleText.handleSet('VerticalAlignment', 'bottom');
      catch err
        debugStamp(err, 1, obj);
      end
      
      try
        colorBar = obj.ColorBar;
        set(colorBar.Handle, 'Units', 'pixels');
        colorBarPosition  = colorBar.handleGet('Position');
        colorBarWidth     = 350;
        colorBarHeight    = 35;
        colorBarOffset    = -5; % (titleExtent(4) - colorBarHeight)/2; %(20-colorBarHeight)
        colorBarPosition = [...
          plotArea(1)+plotArea(3)-colorBarWidth ...
          plotArea(2)+plotArea(4)-colorBarOffset ...
          colorBarWidth colorBarHeight];
        colorBarPosition = colorBarPosition + [+plotInset(1) +plotInset(2) 0 0];
      catch err
        debugStamp(err, 1, obj);
      end
      
      try set(obj.ColorBar.Handle, 'Position', colorBarPosition); end
      
      try
        % obj.ColorBar.updateLimits;
        % obj.ColorBar.createLabels;
        % obj.ColorBar.createPatches;
      end
      
    end
  end
  
  methods
    function formatPlotAxes(obj, axes)
      
      obj.bless;
      
      if nargin==2
        plotAxes  = {axes};
      else
        plotAxes  = obj.PlotAxes;
      end
            
      try
        hAxes       = cellfun(@(c)c.Handle, plotAxes);
        set(hAxes, 'FontSize', 6, 'LooseInset', [0,0,0,0]);
      catch err
        debugStamp(err, 1, obj);
      end
      
      % for m = 1:numel(plotAxes)
        % plotAxes{m}.FontSize = 6;
        % plotAxes{m}.handleSet('LooseInset', [0,0,0,0]);
        % set(plotAxes{m}.Handle, 'FontSize', 6, 'LooseInset', [0,0,0,0]);
      % end
      
    end
    
    
    function layoutPlotAxes(obj)
      obj.bless;
      
      allAxes           = obj.PlotAxes;
      
      if ~iscell(allAxes) || isempty(allAxes), return; end
      
      visibleAxesFilter = cellfun(...
        @(c) isscalar(c) && isobject(c) && isvalid(c)  && ...
        isa(c, 'GrasppeAlpha.Graphics.PlotAxes') && isequal(c.IsHidden, false), ...
        allAxes);
      
      if all(~visibleAxesFilter), return; end
      
      hiddenAxes        = allAxes(~visibleAxesFilter);
      visibleAxes       = allAxes(visibleAxesFilter);
      
      % visibleAxesIndex  = find(visibleAxesFilter);
      
      try
        for m = 1:numel(hiddenAxes)
          try hiddenAxes{m}.handleSet('Parent', obj.HiddenFigure); end
        end
        for m = 1:numel(visibleAxes)
          try visibleAxes{m}.handleSet('Parent', obj.Handle); end
        end
      end
      
      try
        cells           = sum(visibleAxesFilter); %sum(~cellfun(@isempty,obj.PlotAxes));
        parentPosition  = HG.pixelPosition(obj.Handle);
        margins         = [20 20 20 20]; [20 20 20 20]; % L/B/R/T
        spacing         = 0; % 60; %-50;
        padding         = [0 0 0 60]; [30 30 30 10];
        minimumSize     = [150 125]; %W/H
        sizingRatio     = 1;
        
        plottingWidth   = parentPosition(3) - margins(1) - margins(3);
        plottingHeight  = parentPosition(4) - margins(2) - margins(4);
        % fittingWidth    = plottingWidth;
        % fittingHeight   = plottingHeight;
        
        minCellWidth    = minimumSize(1);
        minCellHeight   = minimumSize(2);
        cellWidthRatio  = minCellWidth / minCellHeight;
        
        % Determine maximum columns fit along width
        maxColumns    = floor(plottingWidth/minCellWidth);
        % minRows       = ceil(cells/maxColumns);
        
        % Detemine maximum rows fit along height
        maxRows       = floor(plottingHeight/minCellHeight);
        minColumns    = ceil(cells/maxRows);
        
        % Determine maximum area fit by rows & columns
        columns = 0; rows = 0; maxU = 0;
        
        for w = minCellWidth:plottingWidth
          h           = w/cellWidthRatio;
          u           = (w*h*cells)/(plottingWidth*plottingHeight);
          for c = minColumns:maxColumns
            r         = ceil(cells/c);
            wT        = c*w;
            hT        = r*h;
            %u = (w*h*cells)/(plottingWidth*plottingHeight);
            if (u>maxU) && (u<=1) && wT<=plottingWidth && hT<=plottingHeight
              columns     = c;
              rows        = r;
              cellWidth   = floor(w);
              cellHeight  = floor(h);
              maxU        = u;
            end
          end
        end
        
        if maxU==0
          try
            cellWidth   = obj.PlotWidth;
            cellHeight  = obj.PlotHeight;
            columns     = obj.PlotColumns;
            rows        = obj.PlotRows;
          catch
            cellWidth   = minCellWidth;
            cellHeight  = minCellHeight;
            columns     = round(cells/2);
            rows        = ceil(cells / columns);
          end
        end
        
        obj.PlotWidth   = cellWidth;
        obj.PlotHeight  = cellHeight;
        obj.PlotColumns = columns;
        obj.PlotRows    = rows;
        
        fittingWidth    = cellWidth*columns;
        fittingHeight   = cellHeight*rows;
        
        fittingLeft     = margins(1) + (plottingWidth-fittingWidth) / 2;
        fittingBottom   = max(0, margins(2) + (plottingHeight-fittingHeight));
        
        plotWidth       = cellWidth   - spacing;
        plotHeight      = cellHeight  - spacing;
        
        if plotWidth>plotHeight*sizingRatio
          plotWidth = plotHeight*sizingRatio;
        elseif plotHeight>plotWidth/sizingRatio;
          plotHeight = plotWidth/sizingRatio;
        end
        
        cellWidth       = max(cellWidth, plotWidth);
        cellHeight      = max(cellHeight, plotHeight);
        
        lastOffset      = cellWidth/2*(columns - (cells - ((rows-1)*columns)));
        
        plotSize        = [plotWidth-padding(1)-padding(3) plotHeight-padding(2)-padding(4)];
        
        cellLeft        = (cellWidth - plotWidth) / 2;
        cellBottom      = (cellHeight - plotHeight) / 2;
        
        plotPosition    = zeros(cells, 4);
        
        for m = 1:cells
          [column row]  = ind2sub([columns rows], m);
          if (row == rows)
            plotLeft      = fittingLeft   + lastOffset + cellLeft   + padding(1) + (cellWidth  * (column - 1));
            plotBottom    = fittingBottom + cellBottom + padding(2) + (cellHeight * (rows-row));
          else
            plotLeft      = fittingLeft   + cellLeft   + padding(1) + (cellWidth  * (column - 1));
            plotBottom    = fittingBottom + cellBottom + padding(2) + (cellHeight * (rows-row));
          end
          
          plotPosition(m, :) = round([plotLeft plotBottom plotSize]);
          
          thisAxes        = visibleAxes{m};
          
          try
            if plotBottom < (plottingHeight)
              set(thisAxes.Handle, 'Parent', obj.Handle); %obj.PlotAxes{m}.
              if ~isempty(thisAxes) && ishandle(thisAxes.Handle)
                set(thisAxes.Handle, 'ActivePositionProperty', 'OuterPosition', ...
                  'Units', 'pixels', 'Position', plotPosition(m, :));
                %thisAxes.handleSet('ActivePositionProperty', 'OuterPosition');
                %thisAxes.handleSet('Units', 'pixels');
                %thisAxes.handleSet('Position', plotPosition(m, :));
              end
            else
              set(thisAxes.Handle, 'Parent', obj.HiddenFigure);
              %thisAxes.handleSet('Parent', obj.HiddenFigure);
            end
          catch err
            if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
            dispf('Layout FAILED for %s', thisAxes.ID);
          end
        end
        
        % areaMin = min(plotPosition, [], 1);
        % areaMax = max(plotPosition, [], 1);
        % areaPosition = [areaMin(1:2)  areaMin(1:2)-areaMax(1:2)+areaMax(3:4)];
        
        plotAreas       = plotPosition;
        plotAreas(:,3)  = plotAreas(:,3)+plotAreas(:,1);
        plotAreas(:,4)  = plotAreas(:,4)+plotAreas(:,2);
        
        if size(plotAreas,1) > 1
          plotBottomLeft  = min(plotAreas(:,1:2));
          plotTopRight    = max(plotAreas(:,3:4));
        else
          plotBottomLeft  = plotAreas(1:2);
          plotTopRight    = plotAreas(3:4);
        end
        
        plotArea        = [ plotBottomLeft    plotTopRight-plotBottomLeft ];
        
        obj.PlotArea    = plotArea;
        
      catch err
        if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
        %disp(err);
      end
    end
    
    
    
  end
  
end

