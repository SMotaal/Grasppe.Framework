function h=gxgca()
% gxgca returns the current GXGraph from a GXFigure or a MATLAB axes handle. 
%
% If the current axes is associated with a GXGraph, the GXGraph instance is
% returned
% Otherwise, the handle of the current MATLAB axes is returned. 
%
% Example:
%       h=gxgca()
%

currentFigure=gxgcf();

if isa(currentFigure, 'GXFigure')
    h=get(currentFigure, 'CurrentAxes');
    if isempty(h)
        h=subplot(currentFigure, 1, 1, 1);  
    elseif isa(h, 'GXGraph')
        return;
    else
        h=get(h,'UserData');
        if iscell(h)
            if isa(h{1},'GXGraph')
                h=h{1};   
            else
                h=get(currentFigure.getParent(), 'CurrentAxes');
            end
        else
            h=get(currentFigure.getParent(), 'CurrentAxes');
        end
    end
else
    h=get(currentFigure, 'CurrentAxes');
    if isempty(h)
        h=axes('Parent', currentFigure);
    end
end


return
end