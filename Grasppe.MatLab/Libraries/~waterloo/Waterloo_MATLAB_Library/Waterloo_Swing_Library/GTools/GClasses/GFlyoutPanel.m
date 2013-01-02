classdef GFlyoutPanel < GBasicHotSpot
    % GFlyoutPanel class provides the basic mechanisms for flyout/popup toolbars
    % and graphics on the edges of a MATLAB figure
    %
    % Example:
    %       obj=GBasicFlyoutPanel(hFig, 'right')
    %       where hFig is a MATLAB figure handle
    %
    % obj.Panel will contain a uipanel that you can populate with
    % components.
    %
    % See also GSideBar
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    % 
    % Author: Malcolm Lidierth 12/10
    % Copyright The Author & King's College London 2011-
    % --------------------------------------------------------------------- 
   
    properties (Access=protected)
        Components;
        Point;
        Width=40;% in pixels
    end
      
    methods
        
        function obj=GFlyoutPanel(target, point)
            switch lower(point)
                case {'west', 'left'}
                    pos=[0.0 0.1 0.05 0.8];
                    loc=javax.swing.SwingConstants.LEFT;
                case {'north', 'top'}
                    pos=[0.1 0.925 0.8 0.075];
                    loc=javax.swing.SwingConstants.TOP;
                case {'south', 'bottom'}
                    pos=[0.1 0.0 0.8 0.075];
                    loc=javax.swing.SwingConstants.BOTTOM;
                otherwise
                    % Default to east
                    pos=[0.95 0.1 0.05 0.8];
                    loc=javax.swing.SwingConstants.RIGHT;
            end
            obj=obj@GBasicHotSpot(target, pos);
            obj.Type='GFlyoutPanel';
            obj.onCleanup();
            obj.Point=loc;
            obj.Components{1}=uipanel(target, 'Units', 'normalized', 'BorderType', 'none',...
                'Position', obj.Position, 'Hittest', 'off', 'Visible', 'off');
             set(obj.Rectangle, 'UserData', obj.Components{1});
             set(obj.Components{1}, 'ResizeFcn', {@LocalResizeCallback, obj});
             LocalResizeCallback([], [], obj)
            return
        end
        
        function panel=getComponent(obj, idx)
            if nargin==2 && idx>1
                warning('GFlyoutPanel:Indexed', 'GFLyoutPanels have only 1 component: ignoring index');
            end
            panel=obj.Components{1};
            return
        end
        
        function setWidth(obj,width)
            obj.Width=width;
            return
        end
        
        function width=getWidth(obj)
            width=obj.Width;
            return
        end

    end
end


function LocalResizeCallback(hObject, EventData, obj)
%set(hObject, 'ResizeFcn',[]);
if isMultipleCall();return;end
vec=[obj.Rectangle, obj.Components{1}];
for k=1:2
set(vec(k), 'Position', obj.Position);
set(vec(k), 'Units', 'pixels');
pos=get(vec(k), 'Position');
switch obj.Point
    case javax.swing.SwingConstants.RIGHT
        pos(1)=pos(1)+pos(3)-obj.Width;
        pos(3)=obj.Width;
    case javax.swing.SwingConstants.LEFT
        pos(3)=obj.Width;
    case javax.swing.SwingConstants.TOP
        pos(2)=pos(2)+pos(4)-obj.Width;
        pos(4)=obj.Width;
    case javax.swing.SwingConstants.BOTTOM
        pos(4)=obj.Width;
end
set(vec(k), 'Position', pos);
set(vec(k), 'Units', 'normalized');
end
if ~isempty(obj.Object)
    obj.Object.revalidate();
end
drawnow();
return
end





