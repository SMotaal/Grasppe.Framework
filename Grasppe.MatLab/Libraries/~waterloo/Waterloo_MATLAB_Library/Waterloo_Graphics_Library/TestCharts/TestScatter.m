function f=TestScatter()
% TestScatter illustrates some simple scatter plots
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

% ALL THESE PLOTS USE THE STANDARD MATLAB CALLING CONVENTIONS. SEE THE 
% MATLAB DOCS FOR FURTHER DETAILS

%import kcl.waterloo.plotmodel2D.GJAbstractVisual.*

% Load seamount.mat - part of the standard MATLAB distribution
load seamount;

% Create a GXFigure instead of a plain MATLAB figure...
f=GXFigure();
% ... we can still size it using a MATLAB call - it's a MATLAB figure window 
% after all
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);


% GRAPH 1
% Fixed size markers with color set by z. Provide the handle of the
% GXFigure to invoke the overloaded subplot method which creates a GXGraph
% intead of a MATLAB axes object.
gr1=subplot(f, 2, 2, 1);
% Add a scatter plot - the GXGraph handle is supplied as input so the
% overloaded scatter method will be called
a=scatter(gr1, x, y, 100, z);
a.getObject().setAlpha(0.5);
% The handle of the Java graph container will be returned by getObject()
gr1.getObject().setTitleText('Fixed size')
gr1.getObject().getView().autoScale();


% GRAPH 2
% Variable sized markers
gr2=subplot(f, 2, 2, 2);
b=scatter(gr2, x, y, sqrt(-z/2), [.5 0 0], 'filled');
b.getObject().setAlpha(0.2);
gr2.getObject().setTitleText('Variable sized points');
gr2.getObject().getView().autoScale();

% GRAPH 3
gr3=subplot(f, 2, 2, 3);
c=scatter(gr3, x, y, 'Marker', 'o', 'MarkerFaceColor',  java.awt.Color(0,1,0,0.3), 'MarkerEdgeColor',  java.awt.Color(0,0,1,0.5));
gr3.getObject().getView().autoScale();

% GRAPH 4
% Component scatter - the markers are JButtons that can be independently
% programmed to be mouse active. Note we use gxgca here though gr4 could be
% used (and would be quicker) 
gr4=subplot(f, 2, 2, 4);
d=cscatter(gxgca, x, y);
gr4.getObject().getView().autoScale();

return 
end