classdef GSideBar < GFlyoutPanel
    % GSideBar provides animated flyout toolbars at the 4 sides
    % of a figure
    %
    % This is an extension of the more general-purpose GFlyoutPanel.
    % NOTE: GSideBar requires SwingX to be on your MATLAB path
    %
    % Example:
    % obj=GSideBar(parent, point)
    % where 
    % parent is a figure handle
    % point is 'east', 'west', 'north' or 'south' [ or 'right', 'left', 'top', 'bottom'].
    %
    % To add components (typically JButtons) to the panel use obj.add(...)
    % after instantiation
    %
    % The "Width" of the flyout determines the size of the panel while
    % "ComponentHeight" sets the height of the components inside the panel.
    % Both are set in pixels and will be retained through any resizing of
    % the parent container - facilitating the use of fixed size elements
    % like icons.
    % Note that for panels at the top and bottome "Width" is the height and
    % "ComponentHeight" is the component width.
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    % 
    % Author: Malcolm Lidierth 02/11
    % Copyright The Author & King's College London 2011-
    % --------------------------------------------------------------------- 
    
    
    % Revisions:
    %       21.07.2012 Replace obj.Panel references with obj.Components{1}
    
    
    properties
        ComponentHeight;
    end
    
    methods
        
        function obj=GSideBar(target, point)
            % Create a GFlyoutPanel
            obj=obj@GFlyoutPanel(target, point);
            % Add a JContainer to the MATLAB panel...
            try
                obj.Object=jcontrol(obj.Components{1}, org.jdesktop.swingx.JXPanel(), 'Position', [0 0 1 1]);
            catch ex
                disp(ex);
                error('GSideBar requires the SwingLabs SwingX extensions - these need to be on your MATLAB path');
            end
            % ... and give it a vertical layout
            obj.Object.setLayout(org.jdesktop.swingx.VerticalLayout());
            % Add a collapsible pane for animation
            switch obj.Point
                case {javax.swing.SwingConstants.TOP, javax.swing.SwingConstants.BOTTOM}
                    cp=org.jdesktop.swingx.JXCollapsiblePane(javaMethod('valueOf',...
                        'org.jdesktop.swingx.JXCollapsiblePane$Direction','LEFT'));
                    cp.setLayout(org.jdesktop.swingx.HorizontalLayout());
                otherwise
                    cp=org.jdesktop.swingx.JXCollapsiblePane(javaMethod('valueOf',...
                        'org.jdesktop.swingx.JXCollapsiblePane$Direction','DOWN'));
                    cp.setLayout(org.jdesktop.swingx.VerticalLayout());
            end
            obj.Object.add(cp);
            % Intialise explicitly
            set(obj.Object, 'Visible', 'off');
            cp.setAnimated(true);
            cp.setCollapsed(true);
            % Add/supplement MouseMotionHandler
            % This overrides the callback created by GBasicHotSpot
            if isappdata(target, 'MouseMotionHandlerObject')
                h=getappdata(target, 'MouseMotionHandlerObject');
            else
                % Not strictly needed as GBasicHotSpot will have done this
                h=MouseMotionHandler(target);
            end
            h.add(obj.Rectangle, {@GSideBarCallback, 'on'});
            h.addExit(obj.Rectangle, {@GSideBarCallback, 'off'});
            % Default to square components
            obj.ComponentHeight=obj.Width;
            % Setup data for the callback 
            set(obj.Rectangle, 'UserData', {obj.Components{1}, obj.Object, cp, obj.Point, obj.ComponentHeight});
            obj.Type='GSideBar';
            return
        end
        
        function add(obj, newobj)
            % Add a component to the collapsible pane
            new=obj.Object.getComponent(0).add(newobj);
            new.setPreferredSize(java.awt.Dimension(obj.Width,obj.Width));
            return
        end
        
        function setWidth(obj, w)
            % setWidth - sets the width (or height if horizontal) of the flyout
            obj.Width=w;
            for k=0:obj.Object.getComponent(0).getContentPane().getComponentCount()-1
                obj.Object.getComponent(0).getContentPane().getComponent(k).setPreferredSize(java.awt.Dimension(w,obj.ComponentHeight));
            end
            % NB Using code in GFlyoutPanel
            fcn=get(obj.Panel,'ResizeFcn');
            fcn{1}(obj.Panel,[],obj);
            return
        end
        
        function setComponentHeight(obj, ht)
            % setComponentHeight - sets the component heights (or widths if horizontal)
            % inside the flyout
            for k=0:obj.Object.getComponent(0).getContentPane().getComponentCount()-1
                obj.Object.getComponent(0).getContentPane().getComponent(k).setPreferredSize(java.awt.Dimension(obj.Width,ht));
            end
            % NB Using code from GFlyoutPanel
            fcn=get(obj.Panel,'ResizeFcn');
            fcn{1}(obj.Panel,[],obj);
            return
        end
        
        function gap=getGap(obj)
            % getGap returns the gap between components in the layout
            gap=obj.Object.getComponent(0).getContentPane().getLayout().getGap();
            return
        end
        
        function setGap(obj,gap)
            % setGap sets the gap between components in the layout
            obj.Object.getComponent(0).getContentPane().getLayout().setGap(gap);
            return
        end
        
        function color=getBackground(obj)
            % sets the visible background color
            color=obj.Object.getComponent(0).getContentPane().getBackground();
            return
        end
        
        function setBackground(obj,color)
            if isvector(color)
                color=GColor.getColor(color);
            end
            obj.Object.getComponent(0).getContentPane().setBackground(color);
            return
        end
        
    end
end


% CALLBACK
function GSideBarCallback(hObj, Eventdata, state)
userdata=get(hObj, 'UserData');
if userdata{2}.getComponent(0).getContentPane().getComponentCount()==0;return;end
resetRsz=get(userdata{1}, 'ResizeFcn');
set(userdata{1}, 'ResizeFcn',[]);
switch state
    case 'on'
        set(userdata{1}, 'Visible', 'on');
        set(userdata{2}, 'Visible', 'on');
        userdata{3}.setCollapsed(false);
    case 'off'
        userdata{3}.setCollapsed(true);
        set(userdata{1}, 'Visible', 'off');
        set(userdata{2}, 'Visible', 'off');
end
% Size dynamically to contents
units=get(userdata{1}, 'Units');
set(userdata{1},'Units', 'pixels');
pos=get(userdata{1}, 'Position');
factor=userdata{2}.getComponent(0).getContentPane().getComponentCount()*...
    (userdata{5}+userdata{2}.getComponent(0).getContentPane().getLayout().getGap());
switch userdata{4}
    case {javax.swing.SwingConstants.TOP, javax.swing.SwingConstants.BOTTOM}
        midpoint=pos(1)+pos(3)/2;
        newpos=[midpoint-factor/2,...
            pos(2),...
            factor,...
            pos(4)];
    otherwise
        midpoint=pos(2)+pos(4)/2;
        newpos=[pos(1),...
            midpoint-factor/2,...
            pos(3),...
            factor];
end
set(userdata{1}, 'Position', newpos);
% Restore
set(userdata{1},'Units', units);
set(userdata{1}, 'ResizeFcn',resetRsz);
return
end



