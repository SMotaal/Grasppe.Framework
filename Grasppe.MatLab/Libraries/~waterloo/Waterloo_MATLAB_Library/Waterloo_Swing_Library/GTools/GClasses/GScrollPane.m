classdef GScrollPane < GTool
    % GScrollPane class - provides a scrolling uipanel within a MATLAB
    % container
    %
    % A GScrollPane provides a scrolling uipanel. You can added objects to
    % this panel outside the normal position bounds of [0 0 1 1]. The
    % scollbars will then let you scroll to the required location
    %
    % Example:
    %   g=GScrollPane(figure());
    %   h1=uipanel('Parent', g.getView(), 'Position', [0 0 1 1]);
    %   h2=uipanel('Parent', g.getView(), 'Position', [0.25 -0.75 0.5 0.5]);
    %   h3=uipanel('Parent', g.getView(), 'Position', [1.25 0.25 0.5 0.5]);
    %   h4=uipanel('Parent', g.getView(), 'Position', [1 -1 1 1]);
    %   set(get(g.getView(), 'Parent'), 'BackgroundColor', 'w');
    %   g.revalidate();
    %   x=load('durer.mat');
    %   axes('Parent', h1);
    %   imagesc(x.X);
    %   axes('Parent', h2);
    %   imagesc(x.X);
    %   axes('Parent', h3);
    %   imagesc(x.X);
    %   axes('Parent', h4);
    %   imagesc(x.X);
    %   colormap('gray');
    %
    % Note that you get access to the scrollable panel by calling the getView()
    % method. The "components" of a GScrollPane are the scrollbars; the
    % added uipanels are not availble through the object. Use
    %               get(g.getView(), 'Children')
    % to retrieve the added objects from the MATLAB graphics hierarchy.
    %
    % The revalidate methods is called automatically when resizing and may be
    % called by the user to syncronize the added contents with the
    % scrollbars.
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
        outer;
        inner;
        rightscroll;
        bottomscroll;
    end
    
    methods
        
        function obj=GScrollPane(target)
            % GScrollPane constructor
            obj.Parent=target;
            obj.Object=[];
            % Outer panel that hosts the inner scrolling panel
            obj.outer=uipanel('Parent', target, 'Units', 'normalized',...
                'BorderType', 'none', 'Position', [0 0 1 1]);
            % The panel that scrolls - note that clipping is set off
            obj.inner=uipanel('Parent', obj.outer, 'Units', 'normalized',...
                'BorderType', 'none', 'Position', [0 0 1 1],...
                'Clipping', 'off');
            % Right scrollbar
            pos=[0.95 0 0.05 1];
            obj.rightscroll=uipanel('Parent', target, 'Units', 'normalized', 'Tag', 'RightScrollBar',...
                'BorderType', 'none', 'Position', pos);
            obj.Components{1}=jcontrol(obj.rightscroll, javax.swing.JScrollBar(javax.swing.JScrollBar.VERTICAL),...
                'Units', 'normalized', 'Position', [0 0 1 1], 'Tag', 'VerticalScrollBar');
            % Bottom scrollbar
            pos=[0 0 1 0.05];
            obj.bottomscroll=uipanel('Parent', target, 'Units', 'normalized','Tag', 'BottomScrollBar',...
                'BorderType', 'none', 'Position', pos);
            obj.Components{2}=jcontrol(obj.bottomscroll, javax.swing.JScrollBar(javax.swing.JScrollBar.HORIZONTAL),...
                'Units', 'normalized', 'Position', [0 0 1 1], 'Tag', 'HorizontalSCcrollBar');
            set(obj.Parent, 'ResizeFcn', {@LocalResize});
            set(obj.Components{1}, 'AdjustmentValueChangedCallback', {@VerticalAction});
            set(obj.Components{2}, 'AdjustmentValueChangedCallback', {@HorizontalAction});
            
            % We have two controlling objects - in Components 1 and 2 - so
            % use the application data area to pass object. 
            setappdata(obj.Parent, 'GScrollPane_handles',obj)
            return
        end
         
        function revalidate(obj)
            % Revalidates the contents of the view
            contents=get(obj.inner, 'Children');
            x1=Inf;y1=Inf;x2=-Inf;y2=-Inf;
            innerpos=getpixelposition(obj.inner);
            for k=1:numel(contents)
                pos=getpixelposition(contents(k));
                x1=min(x1, pos(1));
                y1=min(y1, pos(2));
                x2=max(x2,pos(1)+pos(3));
                y2=max(y2,pos(2)+pos(4));
            end
            % N.B. No need for update of screen as ValueAdjusted events will be
            % fired
            obj.Components{2}.setMinimum(x1);
            obj.Components{2}.setMaximum(x2-innerpos(3));
            if y1<0;y2=y2-innerpos(4);end
            obj.Components{1}.setMinimum(y1);
            obj.Components{1}.setMaximum(y2);
            return
        end

        function h=getView(obj)
            % Returns the handle of the scrolling panel
            % Example:
            %         h=obj.getView();
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
function LocalResize(hObject, EventData)
obj=getappdata(hObject, 'GScrollPane_handles');
set(obj.outer, 'Position', [0 0 1 1]);
outerpos=gc_getpixelposition(obj.outer);
pos=outerpos;
w=obj.Components{1}.getUI().getPreferredSize(obj.Components{1}.hgcontrol).getWidth();
pos(1)=pos(1)+pos(3)-w;
pos(3)=w;
gc_setpixelposition(obj.rightscroll, pos);
pos=outerpos;
h=obj.Components{2}.getUI().getPreferredSize(obj.Components{2}.hgcontrol).getHeight();
pos(1)=1;
pos(2)=1;
pos(3)=pos(3)-w;
pos(4)=h;
gc_setpixelposition(obj.bottomscroll, pos);

% Do not remove - this code coerces MATLAB into paint the graphics as
% required
pos=outerpos;
pos=pos+1;
gc_setpixelposition(obj.outer, pos);
pos=pos-1;
gc_setpixelposition(obj.outer, pos);

if isempty(EventData)
    obj.revalidate();
end

return
end


% These synch the value in the scrollbar and the position of the scrolling
% panel.
function VerticalAction(hObject, EventData)
ch=getappdata(get(get(hObject.hghandle, 'Parent'), 'Parent'), 'GScrollPane_handles');
limits=getpixelposition(ch.inner);
limits(2)=ch.Components{1}.getValue()+limits(4);
setpixelposition(ch.inner, limits);
LocalResize(get(get(hObject.hghandle, 'Parent'), 'Parent'), false);
return
end

function HorizontalAction(hObject, EventData)
ch=getappdata(get(get(hObject.hghandle, 'Parent'), 'Parent'), 'GScrollPane_handles');
limits=getpixelposition(ch.inner);
limits(1)=-ch.Components{2}.getValue();
setpixelposition(ch.inner, limits);
LocalResize(get(get(hObject.hghandle, 'Parent'), 'Parent'), false);
return
end