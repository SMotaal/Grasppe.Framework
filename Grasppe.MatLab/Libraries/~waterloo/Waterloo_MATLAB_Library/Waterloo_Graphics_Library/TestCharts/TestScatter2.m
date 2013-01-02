function [f, gr1, gr2, gr3, gr4]=TestScatter2()
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
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', 'TestScatter2');
x=0.5:0.5:10;
y=log(x);

% Now  plot some graphs


% [MODE 1]
% Draw a series of independent lines. Each has its own copy x data object
% each of which contains a copy of the x data in primitive form. With many
% data points, this will be memory inefficient.
% PLOTS ARE INDEPENDENTLY CLICKABLE.
gr1=subplot(f, 2, 2, 1);
a1=line(gxgca, x, y, 'LineSpec', '-ob');
b1=line(gxgca, x, y*2, 'LineSpec', '-sg');
c1=line(gxgca, x, y*5, 'LineSpec', '-dr');
d1=line(gxgca, x, y*10, 'LineSpec', '-^m');
gr1.getObject().setTitleText('Mode 1');
gr1.getObject().getView().autoScale();

% FOR THE REMAINING PLOT WE USE LINE INSTEAD OF SCATTER SO WE GET A LINE
% THROUGH THE POINTS TOO

% [MODE 2]
% Draw a family of lines. Set x to [], so they inherit the x data of the first. 
% When there are many points in the data, this can give a
% substantial saving on memory. Note that you can set the x-data in
% any child plot later. Then it will use the new data, rather than looking
% higher in the family tree.
% CLICKING ON A LINE SELECTS ALL OF THEM BECAUSE THEY ARE ALL CHILD PLOTS OF THE
% FIRST.
% NOTE HERE THAT ALPHA IS ALSO USED TO MAKE THE PLOTS PARTIALLY TRANSPARENT
gr2=subplot(f, 2, 2, 2);
a2=line(gxgca, x, y, 'LineSpec', '-ob', 'Alpha', 0.5);
b2=line(a2, [], y*2, 'LineSpec', '--sg', 'Alpha', 0.5);
c2=line(a2, [], y*5, 'LineSpec', '.dr', 'Alpha', 0.5);
d2=line(a2, [], y*10, 'LineSpec', ':^m', 'Alpha', 0.5);
gr2.getObject().setTitleText('Mode 2');
gr2.getObject().getView().autoScale();

% [MODE 3]
% Draw a family of lines as above but have each descend from the previous
% one. Each plot searches upwards in the family tree to find its x-data. For
% plot d3, this means it looks in c3, which looks in b3 which looks in a3 before
% any data are found (which may be slow for very long trees).
% If x-data are subsequently added directly to plot c3, it will affect c3 and
% its descendants, so the plot would change for both c3 and d3 in this case, 
% while a3 and b3 would not change.
% CLICKING ON A LINE SELECTS ALL OF THEM BECAUSE THEY ARE ALL DESCEBDANT PLOTS OF THE
% FIRST.
% MARKERFACECOLORS HERE ARE SPECIFIED IN THE JAVAFX.SCENCE.PAINT.COLOR
% CLASS USING NAMED CONSTANT FIELDS. HEXADECIMAL VALUES CAN ALSO BE SUPPLIED,
% E.G. '#0000FF' OR '0X0000FF' FOR BLUE.
% See http://docs.oracle.com/javafx/2.0/api/javafx/scene/paint/Color.html
gr3=subplot(f, 2, 2, 3);
% if (~isempty(java.lang.System.getProperties().get('WATERLOO_JAVAFX_LOADED')))
    a3=line(gxgca, x, y, 'LineSpec', '-ob', 'MarkerFaceColor', 'ALICEBLUE');
    b3=line(a3, [], y*2, 'LineSpec', '--sg', 'MarkerFaceColor', 'CORAL');
    c3=line(b3, [], y*5, 'LineSpec', '.dr', 'MarkerFaceColor', 'SEAGREEN');
    d3=line(c3, [], y*10, 'LineSpec', ':^m', 'MarkerFaceColor', 'DARKKHAKI');
% else
%     % JavaFX not available
%     a3=line(gxgca, x, y, 'LineSpec', '-ob', 'MarkerFaceColor', 'g');
%     b3=line(a3, [], y*2, 'LineSpec', '--sg', 'MarkerFaceColor', 'y');
%     c3=line(b3, [], y*5, 'LineSpec', '.dr', 'MarkerFaceColor', 'g');
%     d3=line(c3, [], y*10, 'LineSpec', ':^m', 'MarkerFaceColor', 'c');
% end
gr3.getObject().setTitleText('Mode 3');
gr3.getObject().getView().autoScale();

% [MODE 4]
% Draw a series of independent lines. Here, each has a shared reference to
% the same x data object so this is still  memory efficient. Now changing
% the x data for plot c4 would affect plot c4 only as d4 has its own
% x-data reference (but subsequently setting that to [] would
% cause the plot to look in c4 for its data).
% Note that you can access the vectors by reference* from your own code
% - and therefore alter their contents dynamically. Any changes will be
% reflected in the plots when the graphics are next refreshed through a
% paint call.
% *By default, a java.lang.Double[]. An Apache Math3 package ArrayRealVector
% can be used instead - those are in the kcl-waterloo-math.jar file.
% PLOTS ARE INDEPENDENTLY CLICKABLE
gr4=subplot(f, 2, 2, 4);
gr4.getObject().setTitleText('Mode 4');
a4=line(gxgca, x, y, 'LineSpec', '-ob', 'MarkerFaceColor', 'ALICEBLUE');
% Get the x-data object...
xref=a4.getObject().getXData().getDataBuffer();
% ... and use it for the remaining plots
b4=line(gxgca, [], y*2, 'LineSpec', '--sg', 'MarkerFaceColor', 'SEAGREEN');
b4.getObject().getXData().setDataBuffer(xref);%b4.getObject().setXData(xref);
c4=line(gxgca, [], y*5, 'LineSpec', '.db', 'MarkerFaceColor', 'CORAL');
c4.getObject().getXData().setDataBuffer(xref);%c4.getObject().setXData(xref);
d4=line(gxgca, [], y*10, 'LineSpec', ':^y', 'MarkerFaceColor', 'DARKGREEN');
d4.getObject().getXData().setDataBuffer(xref);
gr4.getObject().getView().autoScale();


drawnow();


% disp('Doing save to XML test:')
% disp('Test1.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir,'Test1.kclf'), gr1.getObject().hgcontrol);
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% disp('Test2.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir,'Test2.kclf'), gr2.getObject().hgcontrol);
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% disp('Test3.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir,'Test3.kclf'), gr3.getObject().getView());
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;

% disp('Test4.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir,'Test4.kclf'), gr2.getObject().getView().getPlots().get(0));
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% gr1.getObject().getView().setToolTipText('Draw a series of independent lines.');
% gr2.getObject().getView().setToolTipText('Draw a family of lines.');
% gr3.getObject().getView().setToolTipText('Draw a family of lines and have each descend from the previous one.');
% gr4.getObject().getView().setToolTipText('Draw a series of independent lines but with a comon x-data object.');

drawnow()

return 
end