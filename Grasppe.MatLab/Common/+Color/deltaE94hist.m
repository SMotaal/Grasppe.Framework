function [hF, labels] = deltaE94hist(DE94,filename)
%DELTAE94HIST generates color difference histogram for samples
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


%%
% 1. Create figure
hF = figure('Name', 'CIELab Color Difference Plot', ...
    'units',Unit);

hA = axes; hold on;

DE94(floor(DE94)>10) = 11;

inRange = 0:1:11;
xRange = inRange; %[inRange max(DE94)*2];
xSize = numel(xRange);
ySize = numel(DE94);
binCount = histc(DE94,xRange)
y = binCount./ySize.*100;

%%
% Prepare the data
set(hA,'FontWeight', 'bold');

hBars = bar(hA, xRange, y, 'BarWidth', 1);


for b = inRange+1
    text(xRange(b),y(b)+5,int2str(binCount(b)));
end

xlabel('\DeltaE^*_{94} Color Difference (truncated decimals)');
ylabel(sprintf('Percent of Samples (%d Total)',ySize))

labels = {'0','1','2','3','4','5','6','7','8','9','10','10+'};
set(hA,'XTickLabel', labels);
set(hA,'XTick',0:1:11);
axis([-0.5 11.5 0 100]);
set(hA, 'XTickMode', 'manual');% ,... 
    %'YTickMode', 'manual', 'ZTickMode', 'manual'); %, ...
%set(hF, 'InvertHardCopy', 'on');
%set(hF, 'PaperPositionMode', 'auto');



if exist('filename','var'),
    %if ~exist('format','var'), ...
    format  = '-depsc2';
    disp(['Saving to ' filename]);
    try
        print(format,filename);
    catch exception
        disp(['Failed to save!']);
        rethrow(exception);
    end
end


end