function [ hF ] = LabVectorPlot( LabEst, LabStd, cie, varargin )
%LABVECTORPLOT Summary of this function goes here
%   Detailed explanation goes here
%%
% Settings
ScaleFactor = 1;
Unit = 'points';
MarkSize = ScaleFactor * 75;
ArrowSize = ScaleFactor * 10;
FontSize = ScaleFactor * 15;
TitleFontWeight = 'bold';
LabelFontWeight = 'bold';
AxesFontWeight = 'demi';

PlotSize = ScaleFactor * 375;

FigurePlots = 2;
PlotTitles = {'a^* vs b^*', 'Chroma vs Lightness'};
PlotAxesLabels = {'b^*','a^*';'C^*_{ab}','L^*'};
PlotAxes=[-100, 100, -100, 100; 0, 100, 0, 100];
PlotSteps = [50, 50; 20, 20];
PlotAreaFactor = 0.75;

PlotAreas = abs(min(PlotAxes'))+max(PlotAxes');
PlotScales = PlotAreas./min(PlotAreas);

PlotPoints = size(LabStd,2);

L = 1; a = 2; b = 3;
vLab(1,:,:) = LabStd;
vLab(2,:,:) = LabEst;

vL(:,:) = vLab(:,L,:);
va(:,:) = vLab(:,a,:);
vb(:,:) = vLab(:,b,:);
vc = (va.^2.0+vb.^2.0).^0.5;
%vh = atan2(vb,va);

vX{1} = va; vY{1} = vb;
vX{2} = vc; vY{2} = vL;

XYZn = ref2XYZ(ones(length(cie.lambda),1),cie.cmf2deg,cie.illD65);
vRGB = XYZ2sRGB(Lab2XYZ(squeeze(vLab(2,:,:)),XYZn))';

extraprops={};
for k=1:2:size(varargin,2)
	prop = varargin{k};
	val  = varargin{k+1};
	%prop = [lower(prop(:)') '      '];
	if strcmpi(prop,'filename')
        filename = val;
        if ~exist('format','var'), format  = '-depsc2'; end;
    elseif strcmpi(prop,'format')
        format = val;
    elseif strcmpi(prop,'renderer')
        renderer = val;
    end
end

%%
% 1. Create figure
hF = figure('Name', 'CIELab Color Difference Plot', ...
    'units',Unit);

% if ~exist('filename','var')
%     if exist('renderer','var'),
%         set(hF,'Renderer',renderer);
%     end;
% end;

%%
% 2. Set figure size (position property of figure)
MonitorUsed = 1;
displays = get(0,'MonitorPositions');
dPos = displays(MonitorUsed,:);
xF = dPos(1);
yF = dPos(2);

sF = [FigurePlots*PlotSize PlotSize]; % figure size
set(hF,'Position',[xF yF sF]);

%movegui(hF,'center');
%movegui(hF,'onscreen');

hS=zeros(FigurePlots);

for p=1:FigurePlots
%%
% 3. Create subplot
    pSize = 1*PlotAreaFactor;
    sPos = [(0.5*(p-1.0))+((0.5-pSize/2.0)/2.0),((1-pSize)/2.0),(pSize/2.0),(pSize)];
    cS = subplot(1,FigurePlots,p, 'FontUnits',Unit); %, ...
        %'Position',sPos);
    hS(p) = cS; hold on;
    title(PlotTitles{p},'FontSize',FontSize,'FontWeight',TitleFontWeight);
    xlabel(PlotAxesLabels{p,1},'FontSize',FontSize,'FontWeight',LabelFontWeight);
    ylabel(PlotAxesLabels{p,2},'FontSize',FontSize,'FontWeight',LabelFontWeight);
    
%%
% 4. Create axes in subplot (use axes command)
    %axes(cS); %NOT USED SINCE SUBPLOT RETURNS AXES HANDEL
    set(cS,'FontWeight',AxesFontWeight, 'FontSize',FontSize * 0.75);

%%
% 5. Set Axis Limits (use axis([xmin, xmax, ymin, ymax]);)
    %PlotAxes(p,:)
    axis(PlotAxes(p,:));
    set(cS,'XTick', PlotAxes(p,1):PlotSteps(p,1):PlotAxes(p,2));
    set(cS,'YTick', PlotAxes(p,3):PlotSteps(p,2):PlotAxes(p,4));
    
%%
% 6. Run "axis manual"    
    axis('tight');
    pbaspect([1, 1, 1]);
    
%%
%7. Draw Arrows
    vx = vX{p}; vy = vY{p};
    subplot(hS(p));
    start = [vx(1,:)' vy(1,:)'];
    stop = [vx(2,:)' vy(2,:)'];
    arrow(start,stop,'EdgeColor','k','FaceColor','k', ...
        'Width',ArrowSize/7.5, 'Length', ArrowSize);

%%
% 8. Turn ?hold on?
% 9. Run Scatter
	if ~exist('filename','var')
        scatter(vx(1,:)',vy(1,:)',MarkSize, vRGB, 'filled', ...
            'MarkerEdgeColor',[1 1 1].*0.5, 'Clipping', 'off');
    else % This works around the forced rasterization from filled scatter
        cRadius = MarkSize * 0.025 * PlotScales(p);
        cDiameter = 2*cRadius;
        cRatio = [1 1];
        %cEdgeColor = [1 1 1].*0.5;
        cLineWidth = 0.5;

        for i = 1:PlotPoints
            cPosition = [vx(1,i)-cRadius, vy(1,i)-cRadius, cDiameter, cDiameter];
            cFaceColor = vRGB(i,:);
            cEdgeColor = cFaceColor.*0.75;
            rectangle('Position',cPosition,'Curvature',cRatio ...
                , 'FaceColor', cFaceColor, 'EdgeColor', cEdgeColor ...
                , 'LineWidth', cLineWidth, 'Clipping', 'off');
        end
    end        
end

%%
%10. Save to filename
if exist('filename','var')
    try
        print(format,filename);
    catch exception
        rethrow(exception);
    end
end


