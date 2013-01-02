function a=TestAnnotation()
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
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', 'TestAnnotation');
x = linspace(-2*pi,2*pi,40);
y=sin(x);

% Now  plot some graphs

% Stairs only
gr1=subplot(f, 1, 1, 1);
a1=stairs(gxgca, x, y, 'LineColor', 'r', 'Alpha', 0.2);
b1=stairs(gxgca, x, y*2,'LineColor', 'g','Alpha', 0.2);
c1=stairs(gxgca, x, y*5,'LineColor', 'm','Alpha', 0.2);
d1=stairs(gxgca, x, y*10,'LineColor', 'b', 'LineWidth', 3,'Alpha', 0.2);
gr1.getObject().setTitleText('Stairs');
gr1.getObject().getView().autoScale();

% ARROWS AND LINES
% Text positions are specified relatived to the bounding rectangle of the
% line. To have fuller control, use a text annotation which allows the x,y
% position to be specified.

annotation(gr1, 'arrow', [5,2], [5,10], 'HeadLength', 0.2, 'HeadWidth', 1,...
    'String', 'The arrow points to a location set in graph units....',...
    'LineTextPosition', javax.swing.SwingConstants.TRAILING);

annotation(gr1, 'arrow', [5, 3, 1.5], [2, 4, 10], 'HeadLength', 0.2, 'HeadWidth', 1,...
    'String', '... and this one has a curve',...
    'TextColor', 'y',...
    'TextBackground', 'DARKGRAY',...
    'LineTextPosition', javax.swing.SwingConstants.LEADING);

annotation(gr1, 'line', [-5 -1], [5 10],...
    'String', 'Here''s a simple line annotation...',...
    'TextBackground', 'CORAL',...
    'LineTextPosition', javax.swing.SwingConstants.LEADING);

annotation(gr1, 'line', [-5 -1], [3 8],...
    'String', '... and one using a different line style',...
    'LineStyle', ':',...
    'LineTextPosition', javax.swing.SwingConstants.TRAILING);

annotation(gr1, 'line', [-3  0 3], [1 3 1],...
    'String', 'Lines can be curved too',...
     'LineWidth', 7.5,...
     'TextBackground', 'BEIGE',...
    'LineTextPosition', javax.swing.SwingConstants.NORTH);

annotation(gr1, 'line', [-3  0 3], [0 2 0],...
    'String', 'Lines can be curved too',...
    'LineColor', 'g',...
    'TextColor', 'b',...
    'TextBackground','y',...
     'LineWidth', 7.5,...
    'LineTextPosition', javax.swing.SwingConstants.SOUTH);

annotation(gr1, 'arrow', [-6 -2], [-1 -1], 'HeadLength', 0.25, 'HeadWidth', 0.5,...
    'String', 'Horizontal arrow',...
    'Fill', 'WHITE',...
    'LineWidth', 2,...
    'LineTextPosition', 'SOUTH');

annotation(gr1, 'arrow', [-2 -2], [-7 -2], 'HeadLength', 0.25, 'HeadWidth', 1,...
    'String', 'Vertical arrow',...
    'LineWidth', 2,...
    'Fill', java.awt.Color.white,...
    'LineTextPosition', 'LEADING');

% RECTANGLE AND ELLIPSES

a=annotation(gr1, 'rectangle', 1, -5, 4, 4, 'Fill', [], 'Text', 'Here''s a box with an ellipse inside it');
a=annotation(gr1, 'ellipse', 1, -5, 4, 4, 'Fill', []);


% ARBITRARY SHAPE - the AWT polygon data specifies shape and location
p = java.awt.Polygon();
x=[-1,-1,0,1, 1];
y=[-1,1,2 ,1,-1];
for i = 1:numel(x)
    p.addPoint(3+x(i),-8+y(i));
end
a=annotation(gr1, 'shape', p,  'Fill', java.awt.Color(0,0,1,0.25), 'Text', '...and a polygon');


% TEXT - using full pair/property call in this example
a=annotation('Parent', gr1, 'Style', 'text', 'XData', -5, 'YData', -8,  'TextBackground', 'GOLD', 'Text', 'Here''s a simple text annotaion');

drawnow();
gr1.getObject().repaint();
return 
end