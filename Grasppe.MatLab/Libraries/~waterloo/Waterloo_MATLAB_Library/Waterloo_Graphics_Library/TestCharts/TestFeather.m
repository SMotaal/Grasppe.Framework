function f=TestFeather()
% TestFeather illustrates some feather plots
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

% Create a GXFigure instead of a plain MATLAB figure...
f=GXFigure();
% ... we can still size it using a MATLAB call - it's a MATLAB figure window 
% after all
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);

theta = (-90:10:90)*pi/180;
r = 2*ones(size(theta));
[u,v] = pol2cart(theta,r);

% GRAPH 1
gr1=subplot(f, 2, 2, 1);
feather(gxgca,u,v, 'LineWidth', 2);
gr1.getObject().setTitleText('MATLAB-like');
gr1.autoScale();

% GRAPH 2
gr2=subplot(f, 2, 2, 2);
feather(gxgca,u,v, 'MarkerFaceColor', 'b', 'LineColor', 'b');
gr2.getObject().setTitleText('Filled arrows');
gr2.autoScale();

% GRAPH 3
gr3=subplot(f, 2, 2, 3);
feather(gxgca,u,v, 'LineColor', 'b', 'MarkerFaceColor', 'c', 'MarkerSize', java.awt.Dimension(15,5));
gr3.getObject().setTitleText('Two Colors');
gr3.autoScale();

% GRAPH 4
gr4=subplot(f, 2, 2, 4);
feather(gxgca,u,v, 'MarkerFaceColor', [java.awt.Color.RED,java.awt.Color.GREEN.darker(), java.awt.Color.BLUE], 'MarkerSize', java.awt.Dimension(15,5),...
                'LineColor', [java.awt.Color.RED,java.awt.Color.GREEN.darker(), java.awt.Color.BLUE], 'LineWidth', 2);
gr4.getObject().setTitleText('Multiple Colors');
gr4.autoScale();


return 
end