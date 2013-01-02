classdef GElasticPane < GSplitPaneDivider
    %     GElasticPane is a GSplitPane with an 'empty' side
    %     You can expand or shrink the populated side using the  mouse controls.
    %     Graphics on populated side will be drawn above other 
    %     graphics.   
    %
    %     Example:
    %     GElasticPane(parent, point)
    %     GElasticPane(parent, point, flag)
    %     GElasticPane(parent, point, flag, jcomponent)
    %
    %     parent is the MATLAB container for the GSplitPaneDivider.
    %           This will be populated on one side only as indicated by:
    %           point is 'east', 'west', 'north' or 'south' [ or 'right', 'left', 'top', 'bottom'].
    %           The populated side has a uipanel associated with it.
    %     flag if true, the GElasticPane will spring back to its programmed
    %           position after a mouse drag (default)
    %     jcomponent, if specified, is a Swing container to add to the uipanel.
    %           This will fill the uipanel if specified here.
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
    
    
    properties
%         JComponent;
        Side;
    end
    
    properties (Access=public)
        ZOrder=0;
    end
    
    
    methods
        
        function pane=GElasticPane(target, point)
            switch lower(point)
                case {'east', 'right'}
                    idx=2;
                    orientation='vertical';
                    side=javax.swing.SwingConstants.RIGHT;
                case {'west', 'left'}
                    orientation='vertical';
                    idx=1;
                    side=javax.swing.SwingConstants.LEFT;
                case {'north', 'top'}
                    idx=1;
                    orientation='horizontal';
                    side=javax.swing.SwingConstants.TOP;
                case {'south', 'bottom'}
                    idx=2;
                    orientation='horizontal';
                    side=javax.swing.SwingConstants.BOTTOM;
            end
            pane=pane@GSplitPaneDivider(target, orientation);
            pane.Side=side;
            p1=uipanel('parent', target, 'Tag', 'GElasticPaneComponent', 'BorderType', 'none');
            pane.setComponent(idx, p1);
            set(pane, 'Type', 'GElasticPane');
            set(pane.Object.hgcontrol,'MouseDraggedCallback',...
                {@GElasticPaneDraggedCallback, pane});
            set(pane.Object.hgcontrol,'MouseReleasedCallback',...
                {@GElasticPaneSpringCallback, pane});
            pane.Animated=GTool.getDefault('ElasticPane.Animated');
            pane.setProportion(0.2);
            pane.moveL.setVisible(false);
            pane.moveR.setVisible(false);
            pane.onCleanup();
            return
        end
        
        function setProportion(obj, proportion)
            if obj.Side==javax.swing.SwingConstants.TOP
                proportion=1-proportion;
            end
            setProportion@GSplitPaneDivider(obj, proportion);
            obj.ProgrammedProportion=proportion;
            return
        end
        

        
    end
end

function GElasticPaneDraggedCallback(hObject, EventData, obj)
if isMultipleCall();return;end
panel=obj.getComponent(1);
if isempty(panel);panel=obj.getComponent(2);end
uistack(panel, 'top');
promote(obj);
GSplitPaneDivider.doMouseDrag(obj, hObject, EventData);
drawnow();
%set(obj.Object.hgcontrol,'MouseDraggedCallback', {@GElasticPaneDraggedCallback, obj});
return
end

function GElasticPaneSpringCallback(hObject, EventData, obj) %#ok<INUSL>
pause(0.1);
proportion=obj.getProportion();
steps=5;
diff=(obj.ProgrammedProportion-proportion)/steps;
t=timer('TimerFcn', {@LocalTimer, obj, diff, steps, proportion},...
    'ExecutionMode','fixedSpacing', 'Period', 0.005, 'TasksToExecute', steps, 'Tag', 'GTool:Timer');
start(t);
return
    function LocalTimer(tobj, EventData, obj, diff, steps, proportion)
        n=get(tobj, 'TasksExecuted');
        if n==steps
            stop(t);
            delete(t);
        end
        if obj.Side==javax.swing.SwingConstants.TOP
            obj.setProportion(1-(proportion+(n*diff)));
        else
            obj.setProportion(proportion+(n*diff));
        end
        return
    end
end

function promote(obj)
    fComponentContainer=javax.swing.SwingUtilities.getAncestorNamed('fComponentContainer', obj.Object.hgcontrol);
    container=obj.getComponent(1);
    if isempty(container); container=obj.getComponent(2);end
    h=[container; get(container, 'Children')];
    h=findall(h, 'type', 'hgjavacomponent');
    Z=obj.ZOrder;
    for k=1:numel(h)
        h2=get(h(k), 'UserData');
        if ~isempty(h2)
            setZOrder(fComponentContainer, h2, Z);
        end
    end
    setZOrder(fComponentContainer, obj.Object.hgcontrol, Z);
end

function setZOrder(container, obj, Z)
toMove=obj.getParent();
breakout=5;
while ~toMove.getParent().equals(container)
    toMove=toMove.getParent();
    breakout=breakout-1;
    if breakout<=0
        return;
    end
end
if container.getComponentZOrder(toMove)~=Z
    container.add(toMove,Z);
end
return
end



