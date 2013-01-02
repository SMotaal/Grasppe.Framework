function [f, gr1, gr2, gr3, gr4]=TestError()
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

%
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', 'TestError');
x=0.5:0.5:10;
y=log(x);

% Now  plot some graphs


% [MODE 1]
% Vertical errors

a1=errorbar(gxgca, x, y, y/3.5, 'LineSpec', '-ob');
errorbar(a1, [], y*2, y/3.5*2,'LineSpec', '-sg');
errorbar(a1, [], y*5, y/3.5*5, 'LineSpec', '-dr');
Y=errorbar(a1, [], y*10, y/3.5*10, 'LineSpec', '-^m');
Y.getObject().getPlots().get(0).getVisualModel().setLineColor(java.awt.Color.cyan);
Y.getObject().getVisualModel().setEdgeColor(java.awt.Color.cyan);
Y.getObject().getVisualModel().getEdgeStroke().set(0,java.awt.BasicStroke(15));
Y.getObject().getVisualModel().setFill(java.awt.Color.yellow);


a1.getObject().getParentGraph().autoScale();


end