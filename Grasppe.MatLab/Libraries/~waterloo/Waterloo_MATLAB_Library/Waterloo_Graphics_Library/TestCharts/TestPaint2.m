function TestPaint2()
% Illustrates use of GradientPaints

% Set up and create some data
f=GXFigure();
set(gcf, 'Units', 'normalized', 'Units', 'inches', 'Position', [2 2.5 5 5], 'Name', 'TestPaint2');
t= 0:.035:2*pi;
[x,y]=pol2cart(t,sin(2*t).*cos(2*t));

% Let's do something flashy

% Create some GradientPaints: these implement the java.awt.Paint interface
% just like java.awt.Color and can be used in Waterloo instead of a color
paint=kcl.waterloo.marker.GJRadialGradientFactory(0, 0, 5, [0.5 1.0], [java.awt.Color.blue, java.awt.Color.yellow]);
 
% Create a plot
gr1=subplot(f, 1, 1, 1);
thisPlot=line(gxgca, x, y, 'LineColor', 'b',...
    'LineWidth',5,...
    'Marker', kcl.waterloo.marker.GJMarker.Circle(7),...
    'EdgeColor', java.awt.Color.blue);
for k=1:numel(x)
    fillArray(k)=paint.getPaint(x(k), y(k)); %#ok<AGROW>
end
thisPlot.getObject().setFill(fillArray);
gr1.getObject().getView().autoScale();
end

