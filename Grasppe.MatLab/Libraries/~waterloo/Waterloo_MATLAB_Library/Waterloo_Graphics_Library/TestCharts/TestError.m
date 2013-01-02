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
gr1=subplot(f, 2, 2, 1);
a1=errorbar(gxgca, x, y, y/3.5, 'LineSpec', '-ob');
errorbar(a1, [], y*2, y/3.5*2,'LineSpec', '-sg');
errorbar(a1, [], y*5, y/3.5*5, 'LineSpec', '-dr');
Y=errorbar(a1, [], y*10, y/3.5*10, 'LineSpec', '-^m');
Y.getObject().getPlots().get(0).getVisualModel().setLineColor(java.awt.Color.cyan);
Y.getObject().getVisualModel().setEdgeColor(java.awt.Color.cyan);
Y.getObject().getVisualModel().getEdgeStroke().set(0,java.awt.BasicStroke(15));
Y.getObject().getVisualModel().setFill(java.awt.Color.yellow);
gr1.getObject().setTitleText('Mode 1');

gr1.getObject().getView().autoScale();



% [MODE 2]
% Vertical errors - show only upper bar
% Follows MATLAB convention: x, y. lower, upper
% Waterloo maps data to ExtraData0 through 3 using the usual unit circle
% convention: 0=RIGHT/EAST, 1=UPPER/NORTH, 2=LEFT/WEST, 3=LOWER/SOUTH.
gr2=subplot(f, 2, 2, 2);
a1=errorbar(gxgca, x, y, [], y/3.5,'LineSpec', '-ob');
b1=errorbar(gxgca, x, y*2, [], y/3.5*2,'LineSpec', '-sg');
c1=errorbar(gxgca, x, y*5, [], y/3.5*5,'LineSpec', '-dr');
d1=errorbar(gxgca, x, y*10, [], y/3.5*10,'LineSpec', '-^m');
gr2.getObject().setTitleText('Mode 2');
gr2.getObject().getView().autoScale();



% [MODE 3]
% All 4 bars
gr3=subplot(f, 2, 2, 3);
a1=errorbar(gxgca, x, y, y/3.5, y/3.5, 'LeftData', y/8,'RightData', y/8, 'LineSpec', '-ob');
b1=errorbar(gxgca, x, y*2, y/3.5*2, y/3.5*2,'LeftData', y/16*2,'RightData', y/16*2,'LineSpec', '-sg');
c1=errorbar(gxgca, x, y*5, y/3.5*5, y/3.5*5,'LeftData', y/16*5, 'RightData', y/16*5,'LineSpec', '-dr');
d1=errorbar(gxgca, x, y*10, y/3.5*10, y/3.5*10, 'LeftData', y/32*10, 'RightData', y/32*10,'LineSpec', '-^m');
gr3.getObject().setTitleText('Mode 3');
gr3.getObject().getView().autoScale();

% [MODE 4]
% Upper and right bars
gr4=subplot(f, 2, 2, 4);
a1=errorbar(gxgca, x, y, [], y/3.5, 'RightData', y/8, 'LineSpec', '-ob');
b1=errorbar(gxgca, x, y*2, [], y/3.5*2,'RightData', y/16*2,'LineSpec', '-sg');
c1=errorbar(gxgca, x, y*5, [], y/3.5*5,'RightData', y/16*5,'LineSpec', '-dr');
d1=errorbar(gxgca, x, y*10, [], y/3.5*10, 'RightData', y/32*10,'LineSpec', '-^m');
gr4.getObject().setTitleText('Mode 4');
gr4.getObject().getView().autoScale();


drawnow();

%f.save(fullfile(tempdir(), 'TestFig'));
% disp('Doing save to XML test:')
% disp('Test1.xml');
% kcl.waterloo.XMLCoder.GJEncoder.save('Test1.xml', gr1.getObject().hgcontrol);
% if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
% disp('Test2.xml');
% kcl.waterloo.XMLCoder.GJEncoder.save('Test2.xml', gr2.getObject().hgcontrol);
% if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
% disp('Test3.xml');
% kcl.waterloo.XMLCoder.GJEncoder.save('Test3.xml', gr3.getObject().getView());
% if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
% disp('Test4.xml');
% kcl.waterloo.XMLCoder.GJEncoder.save('Test4.xml', gr4.getObject().getView().getPlots().get(0));
% if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
return
end