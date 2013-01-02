function h=gxgco()
% gxgco gets the current Waterloo object.
%
% Example:
%   h=gxgco();
%
% Returns the lastSelected object from Project Waterloo. If this is null,
% returns the MATLAB gco.
%

h=kcl.waterloo.graphics.GJContainerMouseHandler.getLastSelected();

if isempty(h)
    h=gco;
end


return
end
    