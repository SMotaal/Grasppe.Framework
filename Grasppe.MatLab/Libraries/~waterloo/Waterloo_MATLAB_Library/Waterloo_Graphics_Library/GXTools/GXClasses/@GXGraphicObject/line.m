function plotobj=line(target, X, Y, varargin)
% line method for GXGraphicObject objects
%
% Examples:
% line(GXGraphicObject, X,Y) 
% line(GXGraphicObject, X, Y, Z) 
% line(...,'PropertyName',propertyvalue)
% h=line(...)
%
% Also:
% h=line('Parent', GXGraphicObject, 'PropertyName1',propertyvalue1,...)
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
%     if numel(X)~=numel(Y) && ~(isempty(X) || isempty(Y))
%         error('X and Y must be of equal length');
%     end
    if nargin>3 && isnumeric(varargin{1})
        Z=varargin{1};
        varargin{1}=[];
    end
end

if ~isempty(X)
    varargin=horzcat('XData', X, varargin);
end
    
if ~isempty(Y)
    varargin=horzcat('YData', Y, varargin);
end

props=kcl.waterloo.plot.WPlot.parseArgs(varargin);

if props.containsKey('Marker') || props.containsKey('MarkerFcn') || props.containsKey('LineSpec')
    plotobj=GXPlot(target, 'scatter', props);
    sc=kcl.waterloo.plot.WPlot.line(props);
    plotobj.getObject() + sc.getPlot();
else
    plotobj=GXPlot(target, 'line', props);
end



return
end