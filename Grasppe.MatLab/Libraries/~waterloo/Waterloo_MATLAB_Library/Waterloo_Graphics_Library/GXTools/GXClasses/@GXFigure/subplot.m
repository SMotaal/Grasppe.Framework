function varargout=subplot(target, varargin)
% subplot method for GXFigure class
%
% subplot creates GXGraph objects at the specified locations
% Examples:
% subplot(GXFigureHandle, n, m, p);
% subplot(GXFigureHandle, n, m, p, 'replace');
% subplot(GXFigureHandle, n, m, P);
%       where the GXGraphs/axes are to be arranged in an m X n matrix.
%       p is the position to populate, or a 2-element vector P if the
%       GXGraph is to occupy more than one slot in the matrix.
%       With these forms, the GXFigure.Components{p} will be set to the
%       GXGraph handle (or the upper left slot, P(1), with a vector P).
% subplot(GXFigureHandle, 'Position',[left bottom width height]);
%       creates a GXGraph at the position specified. The handle is not stored
%       in the GXFigure.Components array but will be stored in the
%       GXFigure.CurrentAxes property.
% h=subplot(...);
%
% GXGraphs and MATLAB axes can be mixed in a GXFigure by calling both the
% overloaded and standard MATLAB subplot methods e.g.:
%           g=GXFigure();
%           subplot(g, 2, 3, [2 6])
%           % Then, standard calls:
%           figure(g.getParent());
%           subplot(2,3,1);
%           subplot(2,3,4);
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


% Synch to gcf in MATLAB
set(0, 'CurrentFigure', target.Parent);%figure(target.Parent);%


if ~isscalar(varargin{1})
    % subplot(GXFigureHandle, 'Position',[left bottom width height]);
    ax=axes('Parent', target.Parent, 'Units', get(target.Parent, 'Units'), 'Position', varargin{1}, 'Visible', 'off', 'Tag', 'GXFigure:subplot:createdAxes');
    p=uipanel(target.Parent, 'Units', get(target.Parent, 'Units'), 'Position', varargin{1}, 'BackgroundColor','w','Tag', 'GXFigure:subplot:createdPanel');
    varargout{1}=GXGraph(p);
    varargout{1}.getObject().setID(ax);
    set(ax, 'UserData', {varargout{1} p});
    target.Components.put(NaN,ax);
    return
end

if ischar(varargin{end})
    % subplot(GXFigureHandle, n, m, p, 'replace');
    N=numel(varargin)-1;
    switch varargin{end}
        case 'replace'
            h=target.Components.get(varargin{3});
            if ishandle(h)
                h2=get(target.Components.get(varargin{3}),'UserData');
                delete(h);
                delete(h2{1}.getParent());
                target.Components.remove(varargin{3});
            end
    end
else
    N=numel(varargin);
end


if N==3
    ah=subplot(varargin{1:2}, varargin{3});
    ud=get(ah, 'UserData');
    if (iscell(ud) && isa(ud{1},'GXGraphicObject'))
        varargout{1}=ud{1};
    elseif ~isempty(get(ah, 'Children'))
        % If we have a populated set of axes, return the handle
        varargout{1}=ah;
        return
    else
        set(ah,'Visible', 'off','Tag', 'GXFigure:subplot:createdAxes');
        pos=get(ah, 'OuterPosition');
        
        % Workaround for issues in MATLAB versions around R2010
        % OuterPosition can have negative y-origin and size>1 for
        % a 1x1 or 2x1 axes grid in subplot.
        if pos(2)<0 && pos(4)>1
            pos(4)=1+0.5*pos(2);
            pos(2)=-pos(2)/2;
        end
        if pos(1)<0 && pos(3)>1
            pos(3)=1+0.5*pos(1);
            pos(1)=-pos(1)/2;
        end
        
        set(ah, 'OuterPosition', pos);
        p=uipanel(target.Parent, 'Position', pos, 'BackgroundColor','w','Tag', 'GXFigure:subplot:createdPanel');
        if ~isscalar(varargin{3})
            % subplot(GXFigureHandle, n, m, P);
            varargout{1}=GXGraph(p);
            target.Components.put(varargin{3}, varargout{1}.getID());
        else
            % subplot(GXFigureHandle, n, m, p);
            if target.Components.containsValue(varargin{3}) && isvalid(target.Components.get(varargin{3}))
                ud=get(ah, 'UserData');
                varargout{1}=ud{1};
            else
                varargout{1}=GXGraph(p);
                varargout{1}.getObject().setID(ah)
                target.Components.put(varargin{3}, ah);
                set(ah, 'UserData', {varargout{1} p});
            end
        end
    end
end

target.CurrentAxes=varargout{1};
% Add drawnow for R2012b/Win7/Java 1.6.0_31-b05
drawnow();

return
end