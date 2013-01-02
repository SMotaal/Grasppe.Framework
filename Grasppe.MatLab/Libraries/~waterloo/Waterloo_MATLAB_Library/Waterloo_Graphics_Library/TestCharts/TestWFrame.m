function f=TestWFrame()
% TestWFrame
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

% ALL THESE PLOTS USE THE STANDARD MATLAB CALLING CONVENTIONS. SEE THE 
% MATLAB DOCS FOR FURTHER DETAILS

import kcl.waterloo.graphics.*;
import kcl.waterloo.plot.*;

% Create a GXFrame instead of a  MATLAB figure and add 4 graphs to it.
% Create a GXFrame with a title and a 2x2 grid to accommodate the graphs.
% As GXFrame uses a JFrame subclass, not a MATLAB figure, MATLAB-graphics can not
% be added to it.

f=GXFrame('This is a WFrame, a pure Java subclass of JFrame, not a MATLAB figure window',2,2);
ax1=f.getObject().getGridPanel().add(GJGraphContainer.createInstance(GJGraph.createInstance()));
ax2=f.getObject().getGridPanel().add(GJGraphContainer.createInstance(GJGraph.createInstance()));
ax3=f.getObject().getGridPanel().add(GJGraphContainer.createInstance(GJGraph.createInstance()));
ax4=f.getObject().getGridPanel().add(GJGraphContainer.createInstance(GJGraph.createInstance()));

% ax1-ax4 are Java objcets. We could call the Java/Groovy class methods directly
% to add graphics to them. Alternatively, by wrapping the Waterloo Java
% objects in a custom MATLAB class instance, the MATLAB-like API can still be used to
% create graphics.

% Using wwrap causes MATLAB to call the overloaded methods (scatter, line etc) 
% for the GXGraphicObject superclass of wwrap.
% These in turn pass the the wwrap into GXPlot which handles the
% unwrapped Java objects and makes the calls to the underlying Java/Groovy code.

theta = (-90:10:90)*pi/180;
r = 2*ones(size(theta));
[u,v] = pol2cart(theta,r);
feather(wwrap(ax1),u,v, 'MarkerFaceColor', [java.awt.Color.RED,java.awt.Color.GREEN.darker(), java.awt.Color.BLUE], 'MarkerSize', java.awt.Dimension(15,5),...
                'LineColor', [java.awt.Color.RED,java.awt.Color.GREEN.darker(), java.awt.Color.BLUE], 'LineWidth', 2);
ax1.getView().autoScale();


t= 0:.035:2*pi;
[a,b]=pol2cart(t,sin(2*t).*cos(2*t));
line(wwrap(ax2), a, b, 'LineSpec','-om');
ax2.getView().autoScale();

x = linspace(-2*pi,2*pi,40);
y=sin(x);
stairs(wwrap(ax3), x, y, 'LineColor', 'r');
ax3.getView().autoScale();


[X,Y] = meshgrid(-2:.2:2);
Z = X.*exp(-X.^2 - Y.^2);
[DX,DY] = gradient(Z,.2,.2);
quiver(wwrap(ax4),X,Y,DX,DY, 0.9);
ax4.getView().autoScale();

drawnow();

return 
end