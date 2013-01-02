function TestStairs()
% TestScatter2 illustrates some simple line/scatter plots
%
% Modes 1 to 4 show how you can mix primitive data with shared references
% to a data object to achieve improved memory performance.
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
% Copyright The Author & King's College London 2011-
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
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', 'TestStairs');
x = linspace(-2*pi,2*pi,40);
y=sin(x);

% Now  plot some graphs

% Stairs only
gr1=subplot(f, 1, 2, 1);
a1=stairs(gxgca, x, y, 'LineColor', 'r');
b1=stairs(gxgca, x, y*2,'LineColor', 'g');
c1=stairs(gxgca, x, y*5,'LineColor', 'm');
d1=stairs(gxgca, x, y*10,'LineColor', 'b');
gr1.getObject().setTitleText('Stairs');
gr1.getObject().getView().autoScale();

% Stairs + markers: markers are specified because there is a 'LineSpec'
% argument
gr2=subplot(f, 1, 2, 2);
a1=stairs(gxgca, x, y, 'LineSpec', '-ob', 'MarkerSize', 3);
b1=stairs(gxgca, x, y*2,'LineSpec', '-sg', 'MarkerSize', 3);
c1=stairs(gxgca, x, y*5, 'LineSpec', '-dr', 'MarkerSize', 3);
d1=stairs(gxgca, x, y*10, 'LineSpec', '-^m', 'MarkerSize', 3);
gr2.getObject().setTitleText('Stairs + markers');
gr2.getObject().getView().autoScale();



drawnow();
return 
end