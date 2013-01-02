function plotobj=contour(target, varargin)
% contour method for GXGraphicObject objects
% contour(Z)
% contour(Z,n)
% contour(Z,v)
% contour(X,Y,Z)
% contour(X,Y,Z,n)
% contour(X,Y,Z,v)
% contour(...,LineSpec)
% contour(axes_handle,...)
% [C,h] = contour(...)
% 
% See also: contour
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

C=contourc(varargin{:});
plotobj=GXPlot(target, 'contour', C);
target.getObject().getView().autoScale()
return
end