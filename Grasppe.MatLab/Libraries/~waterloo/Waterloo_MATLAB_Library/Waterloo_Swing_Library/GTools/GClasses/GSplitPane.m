classdef GSplitPane < GSplitPaneDivider
    % GSplitPane simulates Java Swing JSplitPane behaviour within MATLAB 
    %
    % Example:
    %           pane=GSplitPane(parent, orientation);
    %               Divides the MATLAB container parent into two halves
    %               separated by a GSplitPaneDivider. Each half is
    %               populated with a standard MATLAB uipanel that can
    %               contain MATLAB and/or Java graphics.
    %               The division can be vertical or horizontal and is
    %               determined by the input string orientation
    %               (default='horizontal').
    %               Moving the GSplitPaneDivider with the mouse, or
    %               programatically, causes the uipanels and their contents
    %               to be resized automatically.
    %
    % GSplitPane functionality is provided by the GSplitPaneDivider
    % class methods. These can be accessed through the GSplitPane object
    % Divider property e.g.
    %                   pane.Divider.setWidth(0.5);
    % sets the GSplitPaneDivider width to 0.5cm. For a full list of methods
    % see the GSplitPaneDivider.m file
    %
    % For convenience, the following methods are also exposed as GSplitPane
    % methods
    %
    %    getComponent(index)
    %               returns the uipanel associated with the specified
    %               index
    %                   INDEX    ORIENTATION         UIPANEL
    %                     1       vertical           left
    %                     2       vertical           right
    %                     1       horizontal         upper
    %                     2       horizontal         lower
    % 
    %   getDivider()
    %        returns the GSplitPaneDivider object
    % 
    %   setProportion(Proportion)
    %       invokes the GSplitPaneDivider setProportion method
    %       This sets the position of the divider in its parent
    %       Proportion is the proportion of the parent to be allocated to the
    %       left or lower division of the parent (for vertical and horizontal
    %       dividers respectively), e.g. pane.setProportion(0.25) allocates 1/4 of the
    %       parent to the left or lower division.
    %
    %   setLock(flag)
    %       Locks (flag=true) or unlocks (false) the divider position.
    %       Locked GSplitPanes can not be moved by the mouse.
    %
    %   isLocked()
    %       Returns the lock flag
    %
    %   delete(pane)
    %       Cleanly deletes the splitpane. This is normally called 
    %       after deletion of the parent or from its DeleteFcn callback.
    %
    % Demonstration code:
    %             fig=figure();
    %             pane1=GSplitPane(fig, 'vertical');
    %             pane1.setProportion(0.2);
    %             % Now use the right side uipanel for another split pane
    %             pane2=GSplitPane(pane1.getComponent(2), 'horizontal');
    %             pane2.setProportion(0.2);
    %             ax1=axes('parent', pane1.getComponent(1));
    %             plot(ax1, 0:0.1:2, sin(0:0.1:2));
    %             ax2=axes('parent', pane2.getComponent(2));
    %             plot(ax2, 0:0.1:5, sin(0:0.1:5)+(0:0.1:5));
    %             ax3=axes('parent', pane2.getComponent(1));
    %             plot(ax3, 0:0.1:20, sin(0:0.1:20)-(0:0.1:20));
    %
    % Notes:
    %   The uipanels can contain any item that would normally be placed in
    %   a uipanel: axes, text, images etc as well as javacomponent derived
    %   objects.
    %
    %   Proper resizing of the contents of the uipanels requires that they
    %   use normalized units. If a uipanel has contents that are best
    %   resized with a different unit setting, set a custom ResizeFcn callback
    %   for those contents.
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 03/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------

    properties(Access=private)
        PreviousProportion=[];
    end
    
    methods
        
        function pane=GSplitPane(target, orient)
            pane=pane@GSplitPaneDivider(target, orient);
            if strcmp(get(target, 'Tag'), 'GSplitPaneComponent');
                h=allchild(target);
                set(target, 'Tag', 'GSplitPaneComponentParent');
            else
                h=[];
            end
            color=pane.getBorder().getLineColor();
            color=[color.getRed() color.getGreen(), color.getBlue()]/255;
            p1=uipanel('parent', target,'BorderType', 'none', 'Units', 'normalized',...
                'BackgroundColor', 'w', 'ForegroundColor', color, 'Tag', 'GSplitPaneComponent:1');
            p2=uipanel('parent', target,'BorderType', 'none', 'Units', 'normalized',...
                'BackgroundColor', 'w', 'ForegroundColor', color, 'Tag', 'GSplitPaneComponent:2');
            pane.setComponent(1, p1);
            pane.setComponent(2, p2);
            set(pane, 'Type', 'GSplitPane');
            
            switch lower(pane.Orientation)
                case 'vertical'
                    set(pane.moveL, 'ActionPerformedCallback', {@MoveL, pane});
                    set(pane.moveR, 'ActionPerformedCallback', {@MoveR, pane});
                otherwise
                    set(pane.moveL, 'ActionPerformedCallback', {@MoveR, pane});
                    set(pane.moveR, 'ActionPerformedCallback', {@MoveL, pane});
            end
            pane.onCleanup();
            return
        end
        
    end
 
end
 
function MoveL(hObect, EventData, obj)
if isempty(obj.PreviousProportion)
    obj.PreviousProportion=obj.getProportion();
    obj.setProportion(0);
    switch lower(obj.Orientation)
        case 'vertical'
            set(obj.getComponent(2), 'Visible','on');
            set(obj.getComponent(1), 'Visible','off');
            obj.moveL.setVisible(false);
        otherwise
            set(obj.getComponent(1), 'Visible','on');
            set(obj.getComponent(2), 'Visible','off');
            obj.moveR.setVisible(false);
    end
else
    obj.setProportion(obj.PreviousProportion());
    obj.PreviousProportion=[];
    h=[obj.Components{:}];
    hoff=findall(h, 'type', 'hgjavacomponent', 'Visible', 'off');
    set(h, 'Visible', 'on');
    set(hoff, 'Visible', 'off');
    forceResize();
    obj.moveL.setVisible(true);
    obj.moveR.setVisible(true);
end
return
end

function MoveR(hObect, EventData, obj)
if isempty(obj.PreviousProportion)
    obj.PreviousProportion=obj.getProportion();
    switch lower(obj.Orientation)
        case 'vertical'
            obj.setProportion(0.99);
            set(obj.getComponent(1), 'Visible','on');
            set(obj.getComponent(2), 'Visible','off');
            obj.moveR.setVisible(false);
        otherwise
            obj.setProportion(0.98);
            set(obj.getComponent(2), 'Visible','on');
            set(obj.getComponent(1), 'Visible','off');
            obj.moveL.setVisible(false);
    end
else
    obj.setProportion(obj.PreviousProportion());
    obj.PreviousProportion=[];
    h=findobj([obj.Components{:}]);
    hoff=findall(h, 'type', 'hgjavacomponent', 'Visible', 'off');
    set(h, 'Visible', 'on');
    set(hoff, 'Visible', 'off');
    forceResize();
    obj.moveL.setVisible(true);
    obj.moveR.setVisible(true); 
end
return
end

function forceResize()
units=get(gcf, 'Units');
set(gcf, 'Units', 'pixels');
pos=get(gcf, 'Position');
pos(4)=pos(4)+1;
set(gcf, 'Position', pos);
pos(4)=pos(4)-1;
set(gcf, 'Position', pos);
set(gcf, 'Units', units);
return
end