classdef GScroller < GTool
    % GScroller class - provides a scrolling uipanel within MATLAB
    %
    % A GScroller has a single scroll bar placed on any side of a parent
    % MATLAB container. A central uipanel, added by the GScroller constructor
    % can be used to house multiple MATLAB graphics containers (i.e. in
    % Swing language it is the viewport view).
    % .
    % Example:
    % To create a GScroller
    %           g=GScroller(target, point, n)
    %     where  target  is the parent MATLAB container (figure, uipanel etc)
    %            point   is 'top', 'bottom', 'left' or right' and sets the
    %                    position of the scroll bar - 'north', 'south' etc
    %                    also accepted.
    %            n       is the number of added components to show in the
    %                    visible part of the scroller (default=4)
    %
    % To add a component use the add() method
    %                   g=GScroller(gcf, 'left', 5);
    %                   h=g.add();
    % adds a uipanel (h) to the central scrolling panel. This can be
    % populated in the usual way.
    % Subsequent calls to add() will add further panels. These can be
    % accessed with e.g h2=g.getComponent(2); 
    % All added uipanels have equal dimensions.
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 09/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties
        Parent;
        Components;
        NumberToDisplay;
        Type='GScroller'
    end
    
    properties(Access=private)
        orientation;
        point;
        outer;
        inner;
        scroll;
    end
    
    methods
        
        function obj=GScroller(target, point, n)
            obj.Parent=target;
            if nargin<3
                n=4;
            end
            obj.NumberToDisplay=n;
            switch point
                case {'top', 'north'}
                    pos=[0 0.95 1 0.05];
                    obj.orientation=javax.swing.JScrollBar.HORIZONTAL;
                    obj.point=javax.swing.SwingConstants.TOP;
                case {'right', 'east', 'vertical'}
                    pos=[0.95 0 0.05 1];
                    obj.orientation=javax.swing.JScrollBar.VERTICAL;
                    obj.point=javax.swing.SwingConstants.RIGHT;
                case {'left', 'west'}
                    pos=[0 0 0.05 1];
                    obj.orientation=javax.swing.JScrollBar.VERTICAL;
                    obj.point=javax.swing.SwingConstants.LEFT;
                case {'bottom', 'south', 'horizontal'}
                    pos=[0 0 1 0.05];
                    obj.orientation=javax.swing.JScrollBar.HORIZONTAL;
                    obj.point=javax.swing.SwingConstants.BOTTOM;
            end
            % Outer panel that hosts the inner scrolling panel
            obj.outer=uipanel('Parent', target, 'Units', 'normalized',...
                'BorderType', 'none', 'Position', [0 0 1 1]);
            % The panel that scrolls - note that clipping is set off
            obj.inner=uipanel('Parent', obj.outer, 'Units', 'normalized',...
                'BorderType', 'none', 'Position', [0 0 1 1],...
                'Clipping', 'off');
            % The scrollbar
            obj.scroll=uipanel('Parent', target, 'Units', 'normalized',...
                'BorderType', 'none', 'Position', pos);
            obj.Object=jcontrol(obj.scroll, javax.swing.JScrollBar(obj.orientation),...
                'Units', 'normalized', 'Position', [0 0 1 1]);
            obj.Object.setMinimum(0);
            obj.Object.setMaximum(10);
            obj.Object.setBlockIncrement(1);
            obj.Object.setEnabled(false);
            
            set(obj.scroll, 'ResizeFcn', {@LocalResize, obj});
            set(obj.Object, 'AdjustmentValueChangedCallback', {@ScrollAction, obj});
            
            % Set up for cleanup
            val=GTool.getDefaults().get('GTool.ClearCallbacks');
            val(end+1)=java.lang.String('AdjustmentValueChangedCallback');
            GTool.getDefaults().put('GTool.ClearCallbacks', val);
            
            
            obj.onCleanup();
            return
        end
        
        function h=add(obj)
            % Add a panel to the scrolling uipanel
            % Example:
            %           h=add()
            % adds the uipanel returning the HG handle in h.
            % h can also be retrieved using h=g.getComponent(n) where n is
            % the index of the component
            if obj.getComponentCount()==0
                switch obj.point
                    case {javax.swing.SwingConstants.RIGHT,javax.swing.SwingConstants.LEFT}
                        pos=[0 1-1/obj.NumberToDisplay 1 1/obj.NumberToDisplay];
                    case {javax.swing.SwingConstants.TOP,javax.swing.SwingConstants.BOTTOM}
                        pos= [0 0 1/obj.NumberToDisplay 1];
                end
                h=uipanel('parent', obj.inner, 'Units', 'normalized',...
                    'Position', pos);
                obj.Object.setMaximum(max(obj.NumberToDisplay, 10));
            else
                pos1=gc_getpixelposition(obj.inner);
                pos2=gc_getpixelposition(obj.Components{end});
                switch obj.point
                    case {javax.swing.SwingConstants.RIGHT,javax.swing.SwingConstants.LEFT};
                        pos=[pos2(1) pos2(2)-pos2(4) pos1(3) pos2(4)];
                    case {javax.swing.SwingConstants.TOP,javax.swing.SwingConstants.BOTTOM};
                        pos=[pos2(1)+pos2(3) pos2(2) pos1(3)/obj.NumberToDisplay pos2(4)];
                end
                h=uipanel('parent', obj.inner, 'Units', 'pixels',...
                    'Position', pos);
                obj.Object.setMaximum(max(obj.NumberToDisplay, obj.getComponentCount())*10);
                obj.Object.setVisibleAmount(10);
                if obj.getComponentCount()>=obj.NumberToDisplay
                    obj.Object.setEnabled(true);
                end
            end
            set([h, obj.inner], 'Units', 'normalized');
            obj.Components{end+1}=h;
            return
        end
        
        function remove(obj, comp)
            % Remove method - removes an added panel from the GScroller
            % Remove a panel by index
            %           obj.remove(idx)
            % where rem(idx,1)==0 or by supplying the MATLAB HG handle
            %           obj.remove(h)
            %
            if rem(comp,1)==0
                idx=comp;
                if obj.isValidIndex(idx)
                    for k=obj.getComponentCount():-1:max(idx,2)
                        gc_setpixelposition(obj.Components{k}, gc_getpixelposition(obj.Components{k-1}));
                    end
                    delete(obj.Components{idx})
                    obj.Components(idx)=[];
                else
                    error('Invalid index supplied');
                end
            else
                for k=1:obj.getComponentCount()
                    if comp==obj.Components{k}
                        obj.remove(k)
                        break
                    end
                end
            end
            obj.Object.setVisibleAmount(10);
            return
        end
        
        function scrollTo(obj, comp)
            % scrollTo method - makes an added panel visible in the GScroller
            % scrollTo a panel by index
            %           obj.scrollTo(idx)
            % where rem(idx,1)==0 or by supplying the MATLAB HG handle
            %           obj.scrollTo(h)
            %
            if rem(comp,1)==0
                idx=comp;
                if obj.isValidIndex(idx)
                    obj.Object.setValue(idx*10);
                    return
                else
                    error('Invalid index supplied');
                end
            else
                for k=1:obj.getComponentCount()
                    if comp==obj.Components{k}
                        obj.remove(k)
                        return
                    end
                end
            end
            return
        end
        
        function flag=isValidIndex(obj, idx)
            % isValidIndex returns true if a specified index is is range
            % i.e. between 1 and getComponentCount()
            % Example:
            %       flag=obj.isValidTab(index);
            if idx>=1 && idx<=numel(obj.Components)
                flag=true;
                return
            else
                flag=false;
            end
            return
        end
        
        
        function h=getView(obj)
            % getView returns the handle of the inner uipanel
            % Example:
            %       h=obj.getView();
            h=obj.inner;
            return
        end
        
        
        % TODO: This is generic and should be in GTool
        function n=getComponentCount(obj)
            n=numel(obj.Components);
            return
        end
        
    end
end


% Resize callback. This keeps the JScrollbar hgcontainer width constant and
% resizes the outer panel that hosts the scrolling panel. 
% LocalResize is also called to ensure that the contents of the
% scrolling panel are repainted after scrolling
function LocalResize(hObject, EventData, obj)
switch obj.point
    case javax.swing.SwingConstants.RIGHT;
        pos=gc_getpixelposition(obj.scroll);
        w=obj.Object.getUI().getPreferredSize(obj.Object.hgcontrol).getWidth();
        pos(1)=pos(1)+pos(3)-w;
        pos(3)=w;
    case javax.swing.SwingConstants.LEFT;
        pos=gc_getpixelposition(obj.scroll);
        w=obj.Object.getUI().getPreferredSize(obj.Object.hgcontrol).getWidth();
        pos(1)=1;
        pos(3)=w;
    case javax.swing.SwingConstants.TOP
        pos=gc_getpixelposition(obj.scroll);
        h=obj.Object.getUI().getPreferredSize(obj.Object.hgcontrol).getHeight();
        pos(2)=pos(2)+pos(4)-h;
        pos(4)=h;
    case javax.swing.SwingConstants.BOTTOM
        pos=gc_getpixelposition(obj.scroll);
        h=obj.Object.getUI().getPreferredSize(obj.Object.hgcontrol).getHeight();
        pos(2)=1;
        pos(4)=h;
end
gc_setpixelposition(obj.scroll, pos);
set(obj.outer, 'Position', [0 0 1 1]);
pos=gc_getpixelposition(obj.outer);
switch obj.point
    case javax.swing.SwingConstants.RIGHT;
        pos(1)=1;
        pos(3)=pos(3)-w;
    case javax.swing.SwingConstants.LEFT;
        pos(1)=w;
        pos(3)=pos(3)-w;
    case javax.swing.SwingConstants.TOP
        pos(2)=1;
        pos(4)=pos(4)-h;
    case javax.swing.SwingConstants.BOTTOM
        pos(2)=h+1;
        pos(4)=pos(4)-h;
end
gc_setpixelposition(obj.outer, pos);
return
end


% This synchs the value in the scrollbar and the position of the scrolling
% panel. A JScrollbar uses integer values, so we use 10 per added panel to
% get smooth scrolling.
function ScrollAction(hObject, EventData, obj)
pos=gc_getpixelposition(obj.inner);
switch obj.point
    case {javax.swing.SwingConstants.RIGHT, javax.swing.SwingConstants.LEFT}
        v=obj.Object.getValue()/10;
        v=min(v,obj.getComponentCount()-obj.NumberToDisplay+1);
        v=max(1,v);
        idx=fix(v);
        p1=gc_getpixelposition(obj.Components{idx});
        pos(2)=(obj.NumberToDisplay-1)*p1(4)-p1(2)+((v-idx)*p1(4));
    case {javax.swing.SwingConstants.TOP, javax.swing.SwingConstants.BOTTOM}
        v=obj.Object.getValue()/10;
        v=min(v, obj.getComponentCount()-obj.NumberToDisplay);
        v=max(1,v);
        idx=fix(v);
        p1=gc_getpixelposition(obj.Components{idx});
        pos(1)=-p1(1)-((v-idx)*p1(3));
end
gc_setpixelposition(obj.inner, pos);
LocalResize([],[],obj);
return
end

