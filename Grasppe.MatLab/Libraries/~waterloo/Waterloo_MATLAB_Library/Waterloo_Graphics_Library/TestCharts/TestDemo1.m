function TestDemo1()
% TestDemo1
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
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', mfilename());


t= 0:.035:2*pi;
[a,b]=pol2cart(t,sin(2*t).*cos(2*t));

gr1=subplot(f, 2, 2, 1);
a1=line(gxgca, a, b, 'LineSpec','-om');
gr1.getObject().getView().autoScale();

gr2=subplot(f, 2, 2, 2);
a2=stairs(gxgca, a, b, 'Linespec','-ob', 'MarkerSize', 2);
gr2.getObject().getView().autoScale();

gr3=subplot(f, 2, 2, 3);
a3=scatter(gxgca, a, b, abs(b)*50,'LineSpec','-ob');
gr3.getObject().getView().autoScale();

gr4=subplot(f, 2, 2, 4);
colormap('cool');
a4=scatter(gxgca, a, b, max(abs(a),abs(b))*200, max(abs(a)*1/max(abs(a))*255, abs(b)*1/max(abs(b))*255));
gr4.getObject().getView().autoScale();



drawnow();
return 
end