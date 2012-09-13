classdef MultiPlotFigure < Grasppe.Graphics.PlotFigure
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
  
  methods
    
    function obj = MultiPlotFigure(varargin)
      obj = obj@Grasppe.Graphics.PlotFigure(varargin{:});
    end
    
%     function OnDelete(obj)
%       try delete(obj.ColorBar); end
%     end
    
    
    function OnResize(obj, source, event)
      obj.bless;
      
      obj.OnResize@Grasppe.Graphics.PlotFigure(source, event);
      obj.layoutPlotAxes;
      obj.layoutOverlay;
      
    end
    
  
%     function OnKeyPress(obj, source, event)
%       obj.bless;
%       
%       shiftKey = stropt('shift', event.Data.Modifier);
%       commandKey = stropt('command', event.Data.Modifier) || stropt('control', event.Data.Modifier);
%       
%       syncSheets = false;
%       
%       if ~event.Consumed
%       
%         if commandKey && shiftKey
%           switch event.Data.Key
%             case 'h'
%               try obj.DataSources{1}.setSheet('sum'); syncSheets = true; end
%               event.Consumed = true;
%             case 'uparrow'
%               try obj.DataSources{1}.setSheet('+1'); syncSheets = true; end
%               event.Consumed = true;
%             case 'downarrow'
%               try obj.DataSources{1}.setSheet('-1'); syncSheets = true; end
%               event.Consumed = true;
%             otherwise
%               %disp(toString(event.Data.Key));
%           end
%         end
%       end
%       
%       if syncSheets
%         %if numel(obj.DataSources)>1
%           for m = 2:numel(obj.DataSources)
%             notify(obj.DataSources{m}, 'SheetChange');
%             %try obj.DataSources{m}.SheetID = obj.DataSources{1}.SheetID; end
%           end
%         %end
%       end
%       
%       obj.OnKeyPress@Grasppe.Graphics.PlotFigure(source, event);
%     end
    
    function Export(obj)
      
      obj.bless;
      
      S = warning('off', 'all');
      
      %obj.ColorBar.createPatches; obj.ColorBar.createLabels;
      
      obj.layoutPlotAxes;
      
      try
        for m = 1:numel(obj.DataSources)
          try obj.DataSources{m}.PlotOverlay.updateSubPlots; end
        end
      end
      
      try
      
      %% Options
      pageScale   = 150;
      pageSize    = [11 8.5] .* 150;
      
      screenPPI   = get(0, 'ScreenPixelsPerInch');
      
      set(0, 'ScreenPixelsPerInch', 96);
      
      figureOptions = { ...
        'Visible', 'off', 'Renderer', 'painters', ...
        'Position', floor([0 0 pageSize]), ...
        'Color', 'none', ...
        'Toolbar', 'none', 'Menubar', 'none', ...
        'NumberTitle','off', 'Name', 'Grasppe Ouput', ...
        };
      
      %% Functions
      deleteHandle = @(x) delete(ishandle(x));
      
      %% Setup Output Figure
      try deleteHandle(obj.OutputFigure); end
      
      obj.OutputFigure = figure(figureOptions{:});
      
      %% Duplicate Figure
      hdFigure = obj.Handle;
      hdOutput = obj.OutputFigure;
      
      colormap(hdOutput, colormap(hdFigure));
      
      %% Switch Print/Screen
      set(findobj(hdFigure, '-regexp','Tag','@Screen'), 'Visible', 'off');
      set(findobj(hdFigure, '-regexp','Tag','@Print'), 'Visible', 'on');  
      
      %% Duplicate Children
      
      children  = allchild(hdFigure);
      nChildren = numel(children);
      
      hgObjects.Unsupported = cell(0,4);
      
      for m = 1:nChildren
        
        [hdObject, hgObject, clObject, hdInfo] = HG.handleObject(children(m));
        
        try clObject = hgObject.type; end
        
        properties = {};
        
        switch clObject
          case {'axes'}
            properties = {'XLim', 'YLim', 'ZLim', 'CLim'};
          otherwise
            %dispf('Not copying handle %d because %s objects are not supported.\t%s', floor(hdObject), clObject, hdInfo);
            hgObjects.Unsupported(end+1,:) = {clObject, hdObject, hgObject, hdInfo};
            continue;
        end
        
        %% Shallow Copying
        hdCopy  = copyobj(hdObject, hdOutput);
        hgCopy  = handle(hdCopy);
        
        %%% Deep Copying
        if ~isempty(properties)
          for n = 1:numel(properties)
            try
              set(hdCopy, properties{n}, get(hdObject, properties{n}));
            catch err
              try debugStamp(err, 1, obj); catch, debugStamp(); end;
            end
          end
        end
        
%         switch clObject
%           case {'axes'}
%             for n = 1:numel(properties)
%               set(hdCopy, properties{n}, get(hdObject(properties{n})));
%             end
%         end
        
        if isfield(hgObjects, clObject)
          hgObjects.(clObject)(end+1) = hgCopy;
        else
          hgObjects.(clObject)        = hgCopy;
        end
        
      end
      
      %% Restore Print/Non-Print
      set(findobj(hdFigure, '-regexp','Tag','@Screen'), 'Visible', 'on');
      set(findobj(hdFigure, '-regexp','Tag','@Print'), 'Visible', 'off');
      
      set(hdOutput, 'Units', 'pixels', 'Position', [0 0 100 100]);
      
      plotRect=[];
      
      %% Gather Decendents
      
      for ax = fliplr(hgObjects.('axes'))
        decendents  = allchild(ax);
        nDecendents = numel(decendents);
        
        
        % if isempty(strfind('ax.Tag', '#PlotAxes'))
        %   continue;
        % end
        
        ax.Units = 'pixels';
        
        tag = ax.Tag;
        
        isPlotAxes  = ~isempty(strfind(ax.Tag, 'PlotAxes'));
        isColorBar  = ~isempty(strfind(ax.Tag, 'ColorBar'));
        isOverlay  = ~isempty(strfind(ax.Tag, 'OverlayAxes'));
        
        if isPlotAxes %~isempty(strfind(ax.Tag, 'PlotAxes'))
          ax.XLim = ax.XLim + [-1 +1];
          ax.YLim = ax.YLim + [-1 +1];
          
          if all(mod(ax.View,90))==0
            %dispf('AX:\t[View: %d %d]', mod(ax.View,90));
            ax.Box  = 'on';
          end
          ax.OuterPosition = ax.OuterPosition + [15 15 30 30];
          
          clObject = 'PlotAxes';
          if isfield(hgObjects, clObject)
            hgObjects.(clObject)(end+1) = ax;
          else
            hgObjects.(clObject)        = ax;
          end
          
        elseif isColorBar %~isempty(strfind(ax.Tag, 'ColorBar'))
          %axOffset = 10; %ax.Position(3)/2;
          %ax.OuterPosition  = ax.OuterPosition + [-25 15 0 0];
          ax.Position       = [0 0 175 15]; %.* [1 1 0.75 0.75];
          %ax.Position       = ax.Position .* [0.75 0.75 0.75 0.75];
          ax.Visible  = 'off';
          %colorBars{end+1} = ax;
          clObject = 'ColorBarAxes';
          if isfield(hgObjects, clObject)
            hgObjects.(clObject)(end+1) = ax;
          else
            hgObjects.(clObject)        = ax;
          end
          
          if ax.LineWidth==1, ax.LineWidth = 0.5; end
          set(findobj(decendents, 'Type', 'text'), 'FontSize', 4, 'FontWeight', 'normal');
          
          continue;
        elseif isOverlay
          clObject = 'OverlayAxes';
          if isfield(hgObjects, clObject)
            hgObjects.(clObject)(end+1) = ax;
          else
            hgObjects.(clObject)        = ax;
          end
          continue;
        else
          %ax.OuterPosition = ax.OuterPosition + [15 15 0 0];
          %ax.LineWidth = ax.LineWidth/2;
        end
                
        if isequal(ax.Visible, 'on')
          parentPosition = HG.pixelPosition(hdOutput);
          
          % dispf(['AX:\t[Position: %d %d %d %d \t' ...
          %   'OuterPoisiton: %d %d %d %d\t' ...
          %   'TightInset: %d %d %d %d\t' ...
          %   'LooseInset: %d %d %d %d\t' ...
          %   'Figure: %d %d %d %d' ...
          %   ], ax.Position, ax.OuterPosition, ax.TightInset, ax.LooseInset, ...
          %   parentPosition);
          
          axPosition    = ax.Position;
          axRight       = axPosition(1) + axPosition(3);
          axTop         = axPosition(2) + axPosition(4);
          
          parentWidth   = parentPosition(3);
          parentHeight  = parentPosition(4);
          
          if isPlotAxes && axRight > parentWidth || axTop > parentHeight
            parentPosition  = [parentPosition(1:2) axRight+50 axTop+50];
            parentUnits     = get(hdOutput, 'Units');
            set(hdOutput, 'Units', 'pixels', 'Position', parentPosition);
            set(hdOutput, 'Units', parentUnits);
          end
        end
                
        for o = 1:nDecendents
          
          [hdObject, hgObject, clObject, hdInfo] = HG.handleObject(decendents(o));
          
          try clObject = hgObject.type; end
          
          switch clObject
            case {'text', 'surface', 'line', 'patch'}
              
            otherwise
              %dispf('Not formatting handle %d because %s objects are not supported.\t%s', floor(hdObject), clObject, hdInfo);
              hgObjects.Unsupported(end+1,:) = {clObject, hdObject, hgObject, hdInfo};
              continue;
          end
          
          if isfield(hgObjects, clObject)
            hgObjects.(clObject)(end+1) = hgObject;
          else
            hgObjects.(clObject)        = hgObject;
          end
          
        end
        
        if isequal(ax.Visible, 'on') && all(mod(ax.View,90))==0 && isPlotAxes
          tick2text(ax);
          hx = getappdata(ax, 'XTickText');
          hy = getappdata(ax, 'YTickText');
          hz = getappdata(ax, 'ZTickText');
          hxyz = [hx; hy; hz];
          
          set(hxyz, 'Units', 'data');
          hxPos = get(hx, 'Position');
          hyPos = get(hy, 'Position');
          hzPos = get(hz, 'Position');
          
          set(hx, 'VerticalAlignment', 'Cap', 'HorizontalAlignment', 'Center'); %, 'Units', 'Pixels');
          
          set(hy, 'VerticalAlignment', 'Middle', 'HorizontalAlignment', 'Right'); % ', 'Units', 'Pixels');
          
          %
          %           for n = 1:numel(hx)
          %             hn = handle(hx(n));
          %             hn.Position = (hn.Position .* [1 0 1]) - [-hn.Position(3) 5 0]; %+ [0 hn.Extent(4)-5 0];
          %           end
          %
          %           for n = 1:numel(hy)
          %             hn = handle(hy(n));
          %             hn.Position = (hn.Position .* [0 1 1]) - [5 0 0]; %[hn.Position(3)+5 0 0];
          %           end
          
          set(hxyz, 'Margin', 2, ... %'BackgroundColor', 'g', ...
            'FontUnits', ax.FontUnits, 'FontSize', ax.FontSize);
          
          set(hxyz, 'Units', 'data');
          
          for n = 1:numel(hx)
            hn = handle(hx(n));
            hn.Position = [hxPos{n}(1) min(ax.YLim)-0.5 hxPos{n}(3)];
          end
          
          for n = 1:numel(hy)
            hn = handle(hy(n));
            hn.Position = [min(ax.XLim)-0.5 hyPos{n}(2) hyPos{n}(3)];
          end
          
          for n = 1:numel(hz)
            hn = handle(hz(n));
            hn.Position = hzPos{n};
          end          
          %hpos2 = get(hxyz, 'Position');

        end
        
      end
           
%       %set(hdText, 'Margin' , cell2mat(get(hdText, 'Margin')) +1)
%       for m = 1:numel(hdTexts)
%         hgText = handle(hdTexts(m));
%         hgText.Margin = hgText.Margin + 2;
%         %hgText.BackgroundColor = 'g';
%       end
      
      %% Fix Surfs
      for hgSurf = hgObjects.('surface')
        if isa(hgSurf.Userdata, 'Grasppe.PrintUniformity.Graphics.UniformityPlotComponent')
          objSurf   = hgSurf.Userdata(1);
          
          hdAx      = hgSurf.Parent;
          
          %           hdTitle   = title(hdAx, obj.Title, 'FontSize', 6, 'FontWeight', 'normal', ...
          %             'Units', 'normalized', 'Position', [0 1], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle'); % 'HorizontalAlignment', 'left');
          %
          %           set(hdTitle,'Units', 'pixels', 'Position', HG.pixelPosition(hdTitle) + [0 15 0]);
          
          try
            dataSource  = objSurf.DataSource;
            
            switch class(dataSource)
              case {'Grasppe.PrintUniformity.Data.RegionStatsDataSource', 'Grasppe.PrintUniformity.Data.RegionPlotDataSource'}
                
                regionMasks = dataSource.PlotRegions;
                regionData  = dataSource.PlotValues;
                regionRects = zeros(size(regionMasks,1), 4);
                
                regionPatch = [];
                regionLine  = [];
                
                regionMean  = nanmean(regionData(:));
                
                for r = 1:size(regionMasks,1)
                  region = squeeze(eval(['regionMasks(r' repmat(',:',1,ndims(regionMasks)-1)  ')']));
                  
                  y       = nanmax(region, [], 2);
                  y1      = find(y>0, 1, 'first')-1;
                  y2      = find(y>0, 1, 'last');
                  
                  x       = nanmax(region, [], 1);
                  x1      = find(x>0, 1, 'first')-1;
                  x2      = find(x>0, 1, 'last');
                  
                  region  = [x1 y1 x2-x1 y2-y1];
                  
                  regionRects(r, :) = region;
                  
                  xl      = [x1 x2];
                  yl      = [y1 y2];
                  
                  zv      = regionData(r);
                  
                  xd      = xl([1 2 2 1 1])';
                  yd      = yl([1 1 2 2 1])';
                  zd      = regionMean([1 1 1 1 1]);
                  cd      = zv([1 1 1 1 1]);
                  
                  %'ZData',
                  regionPatch(end+1)  = patch(xd, yd, zd, cd, 'Parent', hgSurf.Parent, 'FaceColor', 'flat', 'EdgeColor', 'k' , 'LineWidth', 0.125 ); %'EdgeColor', [0.5 0.15 0.15]
                  regionLine(end+1)   = line(xd, yd, 210*[1 1 1 1 1], 'Parent', hgSurf.Parent, 'Color', 'k' , 'LineWidth', 0.125 ); %'EdgeColor', [0.5 0.15 0.15]
                  %, 'ZData', 210*[1 1 1 1 1], 
                end
                
                hgSurf.Visible = 'off';
            end
            
          catch err
            try debugStamp(err, 1, obj); catch, debugStamp(); end;
          end
        end
      end
      
      %% Remove @Screen Objects
      set(findobj(hdOutput, '-regexp','Tag','@Screen'), 'Visible', 'off');
      set(findobj(hdOutput, '-regexp','Tag','@Print'), 'Visible', 'on');      
      
      
      %% Determine Active PlotArea
      plotRect      = [];
      outerRect     = [];
      axesMaxArea   = [0 0];
      
      for ax = hgObjects.('PlotAxes')
        set(ax, 'Units', 'pixels');
        
        %% Plot Rect
        axPosition    = HG.pixelPosition(ax);
        
        %ht          = text(max(ax.XLim), max(ax.YLim), 'test', 'Parent', ax); % max(ax.ZLim));
        ht            = text('Units', 'normalized', 'Parent', ax, 'String', '.', 'Position', [1 1]);
        htMax         = HG.pixelPosition(ht);
        set(ht, 'Units', 'normalized', 'Position', [0 0]);
        htMin         = HG.pixelPosition(ht);
        try delete(ht); end
        
        htBottomLeft  = axPosition(1:2) + min([htMax(:,1:2); htMin(:,1:2)]);
        htTopRight    = axPosition(1:2) + max([htMax(:,1:2); htMin(:,1:2)]);
        
        axBottomLeft  = htBottomLeft;
        axTopRight    = max([axPosition(1:2)+axPosition(3:4); htTopRight]);
        htDiff        = axPosition(3:4) - (htTopRight - htBottomLeft);
        
        axBottomLeft  = axBottomLeft + htDiff/2;
        axTopRight    = axTopRight - htDiff/2;
        
        if isempty(plotRect)
          plotRect = [axBottomLeft axTopRight];
        else
          plotRect = [ ...
            min([plotRect(1:2); axBottomLeft  ]), ...
            max([plotRect(3:4); axTopRight    ])];
        end
        
        axesMaxArea = max([axesMaxArea; axPosition(3:4)]);
        
        %% Outer Rect
        inset         = ax.TightInset;
        exBottomLeft  = axBottomLeft - inset(1:2) - 10;
        exTopRight    = axTopRight   + inset(3:4) + 10; %+ inset(1:2);
                
        if isempty(outerRect)
          outerRect = [exBottomLeft exTopRight];
        else
          outerRect = [ ...
            min([outerRect(1:2); exBottomLeft ]), ...
            max([outerRect(3:4); exTopRight   ])];
        end
        
        
      end
      
      plotRect(3:4)     = plotRect(3:4)-plotRect(1:2);
      %outerRect(1:2)    = outerRect(1:2)+[-15 5];
      outerRect(3:4)    = outerRect(3:4)-outerRect(1:2);
      
      hax = axes('Parent', hdOutput, 'Units','pixels', 'Position', plotRect , ...
        'Visible', 'off', 'Color', 'none', 'Box', 'on');
      hax2 = axes('Parent', hdOutput, 'Units','pixels', 'Position', outerRect , ...
        'Visible', 'off', 'Color', 'none', 'Box', 'on');      
      
      %% Fix Text
      titleFont   = 8;
      smallFont   = 5;
      adjustFont  = 0;
      fontUnits   = 'points';
      
      hdTexts = unique(findall(hdOutput, 'type', 'text'));
      for m = 1:numel(hdTexts)
        hgText = handle(hdTexts(m));
        
        hgText.FontUnits  = fontUnits;
        hgText.FontSize   = hgText.FontSize+adjustFont;
        
        if hgText.FontSize < smallFont
          hgText.FontSize   = smallFont;
        end        
        
        try
          str   = hgText.String;
          nstr  = {};
          
          adjustText  = num2str(adjustFont,'%+1.0f');
          smallText   = num2str(smallFont,'%1.0f');
          
          %disp({adjustText, smallText});

          for l = 1:size(str,1)
            %nstr = strvcat(nstr, regexprep(strtrim(str(l,:)),'(\\fontsize{)([\d\.]+)(})', ['$1${max(2, ' int2str(smallFont-2) ', str2num($2)+' int2str(adjustFont) ')}$3']));
            nstr{end+1,1} = regexprep(strtrim(str(l,:)), ...
              '(\\fontsize{)([\d]+)(})', ...
              ['$1' '${int2str(max([2 ' smallText ' str2num($2)' adjustText ' ]) )}' '$3']);
          end
          %disp(str);
          %disp(nstr);
          hgText.String = nstr;
        catch err
          debugStamp(err,1);
        end
        %hgText.Margin = hgText.Margin + 2;
        %hgText.BackgroundColor = 'g';
      end      
      
      
      %% Fix OverlayAxes
      for m = 1:numel(hgObjects.('OverlayAxes'))
          ax = hgObjects.('OverlayAxes')(m);
        if m==1
          ax.Position     = plotRect;
          htx = (findobj(ax,'Type', 'text'));
          
          set(htx(1), 'Units', 'normalized', 'Position',[0 1], ...
            'FontUnits', fontUnits, 'FontSize', titleFont, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
          
          set(htx(1), 'Units', 'pixels', 'Position', HG.pixelPosition(htx(1)) + [0 +7 0]);
        else
          try delete(ax); end
        end
      end
      
      %% Fix ColorBarAxes
      for m = 1:numel(hgObjects.('ColorBarAxes'))
        ax = hgObjects.('ColorBarAxes')(m);
        if m==1
          ax.Units        = 'pixels';
          axPosition      = ax.Position;
          axPosition(3)   = max(min(250, plotRect(3)/4), 175);
          axPosition(4)   = axPosition(3)/(max(ax.XLim)-min(ax.XLim));
          
          ax.Position = [ ...
            plotRect(1)+plotRect(3)-axPosition(3) plotRect(2)+plotRect(4)+axPosition(4)/2 axPosition(3:4)];
          ax.Visible  = 'on';
        else
          try delete(ax); end
        end
      end
            
      %% Fix Appearances
      
      %% Fix Layout
      
      %% Output Results
      assignin('base', 'hgObjects', hgObjects);
            
      %% Export Document
      export_fig(fullfile('Output','export.pdf'), '-painters', hdOutput);
      
      %% Delete Figure
      %try deleteHandle(obj.OutputFigure); end
      
      catch err
        warning(S);
        rethrow(err);
      end
      
      set(0, 'ScreenPixelsPerInch', screenPPI);
      warning(S);
    end
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.createComponent@Grasppe.Graphics.PlotFigure();
      
      obj.ColorBar = Grasppe.Graphics.ColorBar('Axes', obj.OverlayAxes, 'Size', 10);
      obj.OverlayAxes.registerHandle(obj.ColorBar);
      obj.registerHandle(obj.ColorBar);
      
      %obj.ColorBar.createPatches; obj.ColorBar.createLabels;
    end
    
    
    function preparePlotAxes(obj)
      obj.bless;
      
      try debugStamp(obj.ID); end; % catch, debugStamp(); end;
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
      
      try debugStamp(obj.ID); catch, debugStamp(); end;
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
        plotAxesStruct.object = Grasppe.Graphics.PlotAxes('ParentFigure', obj);
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
      
      plotInset     = [0 0 0 0];
      try plotInset = obj.PlotAxes{1}.handleGet('TightInset'); end
      
      try
        obj.TitleText.handleSet('Units', 'pixels');
        
        titlePosition = obj.TitleText.handleGet('Position');
        titleExtent   = obj.TitleText.handleGet('Extent');
        
        % titlePosition = [plotArea(1) + plotArea(3)/2 ... %-titleExtent(3))/2  ...
        %   plotArea(2)+plotArea(4)-(1*titleExtent(4))  ...
        %   titlePosition(3)]; %+plotArea(4)
        %
        % titlePosition = titlePosition - [0 plotInset(2)+plotInset(4) 0];
        
        titlePosition = [plotArea(1) plotArea(2)+plotArea(4) titlePosition(3)];
        
        titlePosition = titlePosition + [0 plotInset(2)+plotInset(4) 0];
      catch err
        debugStamp(err, 1);        
      end
      
      try 
        obj.TitleText.handleSet('Position', titlePosition);
        obj.TitleText.handleSet('HorizontalAlignment', 'left');
        obj.TitleText.handleSet('VerticalAlignment', 'bottom');
      catch err
        debugStamp(err, 1);        
      end
      
      try
        colorBar = obj.ColorBar;
        colorBar.handleSet('Units', 'pixels');
        colorBarPosition  = colorBar.handleGet('Position');
        colorBarWidth     = 250;
        colorBarHeight    = 25;
        colorBarOffset    = (titleExtent(4) - colorBarHeight)/2; %(20-colorBarHeight)
        colorBarPosition = [...
          plotArea(1)+plotArea(3)-colorBarWidth ...
          plotArea(2)+plotArea(4)-colorBarOffset ...
          colorBarWidth colorBarHeight];
        colorBarPosition = colorBarPosition + [0 plotInset(2)+plotInset(4) 0 0];
      catch err
        debugStamp(err, 1);
      end
           
      try obj.ColorBar.handleSet('Position', colorBarPosition); end      
      
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
      
      for m = 1:numel(plotAxes)
        plotAxes{m}.FontSize = 6;
        plotAxes{m}.handleSet('LooseInset', [0,0,0,0]);
      end
      
    end
    
    
    function layoutPlotAxes(obj)
      obj.bless;
      
      try
        cells           = sum(~cellfun(@isempty,obj.PlotAxes));
        parentPosition  = HG.pixelPosition(obj.Handle);
        margins         = [20 20 20 20]; % L/B/R/T
        spacing         = 60; %-50;
        padding         = [30 30 30 10];
        minimumSize     = [150 125]; %W/H
        sizingRatio     = 1.25;
        
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
          h  = w/cellWidthRatio;
          for c = minColumns:maxColumns
            r = ceil(cells/c);
            wT = c*w;
            hT = r*h;
            u = (w*h*cells)/(plottingWidth*plottingHeight);
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
          
          try
            if plotBottom < (plottingHeight)
              obj.PlotAxes{m}.handleSet('Parent', obj.Handle);
              if ~isempty(obj.PlotAxes{m}) && ishandle(obj.PlotAxes{m}.Handle)
                obj.PlotAxes{m}.handleSet('ActivePositionProperty', 'OuterPosition');
                obj.PlotAxes{m}.handleSet('Units', 'pixels');
                obj.PlotAxes{m}.handleSet('Position', plotPosition(m, :));
              end
            else
              obj.PlotAxes{m}.handleSet('Parent', obj.HiddenFigure);
            end
          catch err
            try debugStamp(obj.ID); end
            dispf('Layout FAILED for %s', obj.PlotAxes{m}.ID);
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
        try debugStamp(obj.ID); end
        %disp(err);
      end
    end
    
    
    
  end
  
end

