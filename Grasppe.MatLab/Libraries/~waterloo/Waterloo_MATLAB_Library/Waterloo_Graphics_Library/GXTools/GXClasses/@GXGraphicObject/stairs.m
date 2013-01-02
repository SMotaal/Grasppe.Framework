function plotobj=stairs(target,  X, Y, varargin)
%   stairs(GXGraphicObject, Y)
%   stairs(GXGraphicObject, X, Y)
%   stairs(GXGraphicObject, X, Y)   
%   stairs(GXGraphicObject, ...,'LineSpec')
%   H = stairs(GXGraphicObject, ...) returns a vector of errorbarseries handles in H.
%
% Also:
% stairs('Parent', GXGraphicObject, 'PropertyName1',propertyvalue1,...)
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
    [target, varargin]=ProcessPairedInputs(target, X,Y,varargin{:});
    X=[];Y=[];
else
    switch nargin
        case 2
            X=1:numel(Y);
        case 3
        case 4
            varargin=horzcat('LineSpec', varargin);
        otherwise
    end
end

args=horzcat({'XData', X, 'YData', Y}, varargin);
props=kcl.waterloo.plot.WPlot.parseArgs(args);

if  props.containsKey('MarkerFcn')
    plotobj=GXPlot(target, 'stairs', props);
    sc=kcl.waterloo.plot.WPlot.scatter(props);
    plotobj.getObject() + sc.getPlot();
    X=X(2:end);
    args=horzcat({'XData', X, 'YData', Y}, varargin);
    props=kcl.waterloo.plot.WPlot.parseArgs(args);
    sc=kcl.waterloo.plot.WPlot.scatter(props);
    plotobj.getObject() + sc.getPlot();
else
    plotobj=GXPlot(target, 'stairs', props);
end



return
end