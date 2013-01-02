function [f, label]=TestComponentAnnotation()
% TestAnnotation illustrates some annotations
%
% Annotations are added to graph containers via the graphs it contains.
% Position, shape, size etc are specified using the coordinates for
% that graph. If added directly to a graph container, the annotation uses
% the coordinates of the view (Layer 0).
%
% The graph then calls the container add method. Note that annotations are
% properties of the container and drawn by it above the graphs. 
%
% 
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 12/11
% Copyright The Author & King's College London 2012-
% ---------------------------------------------------------------------
%   
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%  
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% ---------------------------------------------------------------------

% Set up and create some data
f=GXFigure();
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', mfilename());
x = linspace(-2*pi,2*pi,40);
y=sin(x);

% Now  plot some graphs

% Stairs only
gr1=subplot(f, 1, 1, 1);
a1=stairs(gxgca, x, y, 'LineColor', 'r', 'Alpha', 0.3);
b1=stairs(gxgca, x, y*2,'LineColor', 'g','Alpha', 0.3);
c1=stairs(gxgca, x, y*5,'LineColor', 'm','Alpha', 0.3);
d1=stairs(gxgca, x, y*10,'LineColor', 'b', 'LineWidth', 3,'Alpha', 0.3);
gr1.getObject().setTitleText('Stairs');
gr1.getObject().getView().autoScale();

% Add some components to the container
str=sprintf('Adding Swing-based annotations is simple. This is a Swing JTextArea embedded in a JScrollPane.\nAdd Swing components to Waterloo graphs and their containers simply by calling the "add" method specifying the location for the added component in graph coordinates\n\ne.g. add(javax.swing.JTextField(''My Text'', 1, 10);\n\nNote that the size of the component, in pixels, will be determined by its preferredSize setting. To set that, you need to supply a java.awt.Dimension instance using setPreferredSize (for many components, a suitable default preferredSize will already be set by Java).');
str=sprintf('%s\n\nYou can also specify the alignment of the component:\nadd(component,x,y,alignX,alignY);\nalignX can be\n\tSwingConstants.LEFT, RIGHT or CENTER.\nalignY can be\n\tSwingConstants.TOP, BOTTOM or CENTER.',str);
str=sprintf('%s\n\nWhen added to a graph container, coordinates are specified in the coordinates of the view for that container. Painting of the added component is limited to the area of the container, not of the graph',str);
str=sprintf('%s\n\nWhen added to a graph, coordinates are specified in the coordinates of that graph. Painting of the added component is limited to the area of the graph',str);
tArea=javax.swing.JTextArea(str);
tArea.setPreferredSize(java.awt.Dimension(400,500));
tArea.setLineWrap(true);
tArea.setWrapStyleWord(true);
drawnow();
tScroll=gr1.getObject().add(javax.swing.JScrollPane(tArea), -3.5, 1, javax.swing.SwingConstants.CENTER, javax.swing.SwingConstants.TOP);
tScroll.setPreferredSize(java.awt.Dimension(400,200));



tButton=gr1.getObject().getView().add(javax.swing.JButton('Here''s a button...'), -4, 0);
tCheck=gr1.getObject().getView().add(javax.swing.JCheckBox('... and here''s a check box', true), -4, -2);
tSlider=gr1.getObject().getView().add(javax.swing.JSlider(), -4, -4);
tLabel=gr1.getObject().getView().add(javax.swing.JLabel('Here''s a slider'), -4, -4.5);

m=methods('kcl.gpl.tex.TeX');
if ~isempty(m)
    tTex=gr1.getObject().getView().add(kcl.gpl.tex.TeX.createInstance('\sigma=\sqrt{\frac{\sum x^2}{N} -\left(\frac{\sum x}{N}\right)^2}'), -4, -6.5);
    tTex.setPreferredSize(java.awt.Dimension(300,70));
    tTex.setBackground(java.awt.Color(1,1,0,0.5));
    label=tTex.getLabel();
else
    tTex=gr1.getObject().getView().add(javax.swing.JLabel('TeX NOT INSTALLED'), -4, -6.5);
    tTex.setForeground(java.awt.Color.blue);
end
str=sprintf('%s','If you have installed the GPL supplement, the area above will show a TeX equation using the GPL licensed JLatexMath code which is part of SciLab - see http://forge.scilab.org/index.php/p/jlatexmath/.');
tArea=gr1.getObject().getView().add(javax.swing.JTextArea(str), -4, -9.5);
tArea.setPreferredSize(java.awt.Dimension(375,75));
tArea.setLineWrap(true);
tArea.setWrapStyleWord(true);

drawnow();

gr=kcl.waterloo.graphics.GJGraph.createInstance();
p=kcl.waterloo.graphics.plots2D.GJScatter().createInstance();
p.setXData(1:10);
p.setYData(1:10);
gr.add(p);
container=kcl.waterloo.graphics.GJGraphContainer.createInstance(gr);
container.setPreferredSize(java.awt.Dimension(200,200));

gr1.getObject().getView().add(container, 3, 7);
gr.autoScale();

tArea=gr1.getObject().getView().add(javax.swing.JTextArea('Waterloo graphics are Swing components too - so you can also add graphs to graphs as above. With a Waterloo component plot, you can even make the symbols for each data point a Swing component - the mouse listeners for those components can then respond to a click on the component, e.g. by opening and displaying the relevant entry in a database'), 3, 0);
tArea.setPreferredSize(java.awt.Dimension(350,125));
tArea.setLineWrap(true);
tArea.setWrapStyleWord(true);

str=sprintf('Remember that Swing component classes saved to an XML file need to be recognised by the target computer to load them. If you add non-standard components that are not on the class path in the target environment, the saved data will not load fully, or perhaps at all.\nThis includes components from the Waterloo GPL supplements - so e.g. TeX components can only be loaded on platforms where the kcl.gpl.tex package is available.');
tArea=gr1.getObject().getView().add(javax.swing.JTextArea(str), 3, -5.5);
tArea.setPreferredSize(java.awt.Dimension(350,175));
tArea.setLineWrap(true);
tArea.setWrapStyleWord(true);
tArea.setBackground(java.awt.Color.yellow);
tArea.setForeground(java.awt.Color.red);

t=timer('ExecutionMode', 'fixedRate','Period', 0.05, 'TimerFcn', {@Callback,container}, 'TasksToExecute', 64, 'StopFcn', @delTimer);
start(t);


return
end

function Callback(hobj, eventData, container)
container.setRotation(container.getRotation()+pi/16);
end

function delTimer(hObj, eventData)
delete(hObj);
end
