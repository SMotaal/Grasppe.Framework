function TestPaint()
% Illustrates use of GradientPaints

% Set up and create some data
f=GXFigure();
set(gcf, 'Units', 'normalized', 'Units', 'inches', 'Position', [1 1 5 5], 'Name', 'TestPaint');
t= 0:.035:2*pi;
[x,y]=pol2cart(t,sin(2*t).*cos(2*t));

% Let's do something flashy

% Create some GradientPaints: these implement the java.awt.Paint interface
% just like java.awt.Color and can be used in Waterloo instead of a color
paint1=java.awt.GradientPaint(0, 0, java.awt.Color.blue, 0, 5, java.awt.Color.yellow, true);
paint2=java.awt.GradientPaint(0, 0, java.awt.Color.white, 2, 3, java.awt.Color.red, true);
 
% Create a plot
gr1=subplot(f, 1, 1, 1);
line(gxgca, x, y, 'LineColor', paint1,...
    'LineWidth',5,...
    'Marker', kcl.waterloo.marker.GJMarker.Circle(7),...
    'EdgeColor', java.awt.Color.blue,...
    'MarkerFaceColor', paint2);
gr1.getObject().getView().autoScale();


t1=timer('ExecutionMode', 'fixedRate','Period', 0.1, 'TimerFcn', {@Callback, gr1.getObject()},...
    'TasksToExecute', 16, 'StopFcn', {@delTimer});
start(t1);

end

function Callback(hobj, eventData, container)
container.setRotation(container.getRotation()+pi/8);
end


function delTimer(hObj, eventData)
delete(hObj);
end






