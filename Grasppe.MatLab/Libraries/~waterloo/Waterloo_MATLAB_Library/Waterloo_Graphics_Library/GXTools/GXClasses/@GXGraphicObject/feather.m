function plotobj=feather(target, U, varargin)
%         feather(U,V)
%         feather(Z)
%         feather(...,LineSpec)
%         feather(axes_handle,...)
%         h = feather(...)
%
% Also:
% stem('Parent', GXGraphicObject, 'PropertyName1',propertyvalue1,...)
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
    [target, varargin]=ProcessPairedInputs(target, X, varargin{:});
    X=[];Y=[];
else
    switch nargin
        case 2
            if isreal(U)
                Y=U;
                X=1:numel(Y);
            else
            end
        case 3
            X=U;
            Y=varargin{1};
            varargin=[];
        otherwise
            X=U;
            Y=varargin{1};
            varargin=varargin(2:end);
    end
end

args=horzcat({'XData', X, 'YData', Y}, 'MarkerFaceColor', 'none', varargin);
props=kcl.waterloo.plot.WPlot.parseArgs(args);

plotobj=GXPlot(target, 'feather', props);


return
end