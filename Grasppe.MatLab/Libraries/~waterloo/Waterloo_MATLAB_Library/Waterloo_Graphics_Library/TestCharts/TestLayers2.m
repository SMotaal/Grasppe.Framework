function [f, ax1, ax2, ax3]=TestLayers2()
% TestWFrame uses a GXFrame and illustrates the use if wwrap
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

f=GXFigure();
ax1=subplot(f,1,1,1);

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
feather(ax1,u,v, 'MarkerFaceColor', [java.awt.Color.RED,java.awt.Color.GREEN.darker(), java.awt.Color.BLUE], 'MarkerSize', java.awt.Dimension(15,5),...
                'LineColor', [java.awt.Color.RED,java.awt.Color.GREEN.darker(), java.awt.Color.BLUE], 'LineWidth', 2);
%ax1.setAxisBox(true);


ax2=ax1.getView().add(javaObjectEDT(kcl.waterloo.graphics.GJGraph.createInstance()));
t= 0:.035:2*pi;
[x,y]=pol2cart(t,sin(2*t).*cos(2*t));
b=scatter(wwrap(ax2), x, y, [], 'MarkerFaceColor',java.awt.Color.GREEN.darker());
b.getObject().setAlpha(0.55);
ax2.setAxesBounds(-1.5,-1.5,2,2);
drawnow();

ax3=ax1.getView().add(javaObjectEDT(kcl.waterloo.graphics.GJGraph.createInstance()));
c=scatter(wwrap(ax3), x, y, [], 'MarkerFaceColor',java.awt.Color.RED.darker());
ax3.setAxesBounds(-0.5,-0.5,2,2);
c.getObject().setAlpha(0.75);
drawnow();

ax1.getView().setReverseY(true);

return 
end