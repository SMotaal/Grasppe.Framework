function plotobj=cscatter(target, X, Y, varargin)
% cscatter method for GXGraphicObject objects
%
% cscatter plots are line/scatter plots where the markers are Swing
% components.
%
% Examples:
% cscatter(GXGraphicObject, X,Y) 
% cscatter(GXGraphicObject, X, Y, Z) 
% cscatter(...,'PropertyName', propertyvalue)
% h=cscatter(...)
% 
% Also:
% h=line('Parent', GXGraphicObject, 'PropertyName1', propertyvalue1,...)
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

if ischar(target)
    [target, varargin]=ProcessPairedInputs(target, X, Y, varargin{:});
    X=[];Y=[];
else
    if numel(X)~=numel(Y) && ~(isempty(X) || isempty(Y))
        error('X and Y must be of equal length');
    end
    if nargin>3 && isnumeric(varargin{1})
        Z=varargin{1};
        varargin{1}=[];
    end
end

args=PreProcessGraphicsArgs(varargin{:});
plotobj=GXPlot(target, 'line');
PostProcessGraphicsArgs(plotobj.getObject(), args{:});

if ~isempty(X) || ~isempty(Y)
    plotobj.getObject().setXData(X);
    plotobj.getObject().setYData(Y);
end


ch=GXPlot(target, 'cscatter');
plotobj.getObject().add(ch.getObject());
ch.getObject().setComponents(javax.swing.JButton().getClass());
%ch.getObject().setPreferredSize(15,15);

target.getView().updatePlots();

return
end