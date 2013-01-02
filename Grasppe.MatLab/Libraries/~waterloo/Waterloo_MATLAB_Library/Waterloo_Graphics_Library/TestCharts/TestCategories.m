function TestCategories()
% TestAnnotation


% Set up and create some data
f=GXFigure();
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', 'TestError');
x=0.5:0.5:10;
y=log(x);

% Now  plot some graphs


% [MODE 1]
% Vertical errors
gr1=subplot(f, 1, 1, 1);
a1=errorbar(gxgca, x, y, y/3.5, 'LineSpec', '-ob');
errorbar(a1, x, y*2, y/3.5*2,'LineSpec', '-sg');
errorbar(a1, x, y*5, y/3.5*5, 'LineSpec', '-dr');
errorbar(a1, x, y*10, y/3.5*10, 'LineSpec', '-^m');
gr1.getObject().setTitleText('Mode 1');
gr1.getObject().getView().autoScale();


a1.getObject().getXData().setCategory(2,'Label at 2');
a1.getObject().getXData().setCategory(4,'Label at 4');
a1.getObject().getXData().setCategory(6,'Label at 6');
a1.getObject().getXData().setCategory(8,'Label at 8');
a1.getObject().getXData().setCategory(10,'Label at 10');

a1.getObject().getYData().setCategory(-10,'Label at -10');
a1.getObject().getYData().setCategory(0,'Label at 0');
a1.getObject().getYData().setCategory(10,'Label at 10');
a1.getObject().getYData().setCategory(20,'Label at 20');
a1.getObject().getYData().setCategory(30,'Label at 30');

gr1.getObject().getView().setTopAxisPainted(true);
gr1.getObject().getView().setTopAxisLabelled(true);

gr1.getObject().revalidate();
gr1.getObject().repaint();

return
end