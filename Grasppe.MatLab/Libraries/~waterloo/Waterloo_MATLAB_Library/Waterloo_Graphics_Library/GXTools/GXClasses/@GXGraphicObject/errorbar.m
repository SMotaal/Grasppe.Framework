function plotobj=errorbar(target,  X, Y, L, U, varargin)
%   errorbar(GXGraphicObject, Y, E)
%   errorbar(GXGraphicObject, X, Y, E)
%   errorbar(GXGraphicObject, X, Y, L, U)   
%   errorbar(GXGraphicObject, ...,'LineSpec')
%   H = errorbar(GXGraphicObject, ...) returns a vector of errorbarseries handles in H.
%
% Also:
% errorbar('Parent', GXGraphicObject, 'PropertyName1',propertyvalue1,...)
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
    [target, varargin]=ProcessPairedInputs(target, X, Y, L, U,varargin{:});
    X=[];Y=[];L=[];U=[];
else
    switch nargin
        case 3
            %   ERRORBAR(GXGraphicObject, Y, E)
            L=Y;
            U=Y;
            Y=X;
            X=1:numel(Y);
        case 4
            %   ERRORBAR(GXGraphicObject, X, Y, E)
            %   ERRORBAR(GXGraphicObject, X, E, LineSpec)
            if ischar(L)
                varargin={'LineSpec', L};
                U=Y;
                L=Y;
                Y=X;
                X=1:numel(Y);
            else
                U=L;
            end
        case 5
            %   ERRORBAR(GXGraphicObject, X, Y, L, U)
            %   ERRORBAR(GXGraphicObject, X, Y, E, LineSpec)
            if ischar(U)
                varargin={'LineSpec', U};
                U=L;
            end
        case 6
            %   ERRORBAR(GXGraphicObject, ..., LineSpec)
            varargin={'LineSpec', varargin{:}};
            U=L;
        otherwise
            % NO ACTION - ADDITIONAL INPUTS WILL BE SUPPORTED BY WATERLOO
            % BUT NOT MATLAB

    end
end

args=horzcat({'XData', X, 'YData', Y, 'LowerData', L, 'UpperData', U}, varargin);
props=kcl.waterloo.plot.WPlot.parseArgs(args);

if  props.containsKey('MarkerFcn')
    plotobj=GXPlot(target, 'scatter', props);
    % Clear XData for the child plots - it can be shared with the parent
    props.put('XData',[]);
    ebar=kcl.waterloo.plot.WPlot.errorbar(props);
    ln=kcl.waterloo.plot.WPlot.line(props);
    plotobj.getObject() + ebar.getPlot();
    plotobj.getObject() + ln.getPlot();
else
    plotobj=GXPlot(target, 'errorbar', props);
end

return
end