function h=gxgcf()
% gxgcf gets the current GXFigure.
%
% If the current MATLAB figure is a GXFigure, gxgcf returns the GXFigure
% instance
% If the current MATLAB figure is not a GXFigure, gxgcf returns its handle
% If no figure exists, gxgcf creates a GXFigure and returns the instance
%

current=get(0, 'CurrentFigure');
if isempty(current)
    h=GXFigure();
    return
else

h=get(current, 'UserData');
if iscell(h)
    h=h{1};
else
    h=current;
end


return
end
    