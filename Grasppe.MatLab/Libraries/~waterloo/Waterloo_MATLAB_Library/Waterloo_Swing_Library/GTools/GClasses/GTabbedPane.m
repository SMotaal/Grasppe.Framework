classdef GTabbedPane < GBasicCardGroup
    % GTabbedPane implements a Swing tabbed pane in a MATLAB container and
    % associates the tabs with a GCardPane in the same parent.
    %
    % By default, tabs are placed at the top of the target MATLAB container
    % but positioning to the 'top', 'bottom', 'left' or 'right' can be
    % specified at construction.
    %
    % Note that a GTabbedPane subclasses GBasicCardGroup but also contains
    % one or more GCardPanes. The tabs of the GTabbedPane are used to
    % control which card(s) in the GCardPane(s) is/are visible.
    % Use getComponent to get the card pane(s). To access cards in the card
    % panes use getComponentAt.
    %
    % GTabbedPanes can control multiple GCardPanes simply by placing the
    % objects in the GTabbedPane's Components property using the addPane
    % method. Component 1 of the GTabbedPane is the default GCardPane
    % created on construction. All GCardPanes must have the same number of
    % cards - equal to getTabCount, but note that you can share objects 
    % between cards to avoid duplication - see GCardPane for details.
    % Additional GCardPanes do not share the same parent and need not be in
    % the same MATLAB figure.
    %
    % Notes:
    % A Swing JTabbedPane is used primarily to create the correct look and feel for
    % the platform. The Swing component for each tab is unused and is set by
    % default to be a javax.swing.JSeparator. However, there is no reason
    % why this could not be any other Swing compoenent e.g. a JPanel or JToolBar.
    % The setDepth method of the GTabbedPane can be used to ensure that the
    % JTabbedPane component area is large enough for these components to
    % be visible (set the depth in pixels).
    % Animation of the transition from one tab to another is controlled by
    % the individual components in the GTabbedPane.
    %
    % Example:
    %     g=GTabbedPane(gcf, 'top');
    %     g.addTab('Button 1');
    %     g.addTab('Button 2');
    %     axes('Parent', g.getComponentAt(1));
    %     [X,Y,Z] = peaks(30);
    %     surfc(X,Y,Z)
    %     colormap hsv
    %     axis([-3 3 -3 3 -10 5])
    %     g.setSelectedIndex(1);
    %     axes('Parent', g.getComponentAt(2));
    %     [x,y,z] = sphere;
    %     surf(x,y,z)
    %     hold on
    %     surf(x+3,y-2,z);
    %     surf(x,y+1,z-3);
    %     daspect([1 1 1]);
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 03/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties (SetAccess=private, GetAccess=public)
%         Components;
%         Parent;
%         Type=mfilename();
        Depth=30;
        TabButtonContainer;          % This contains the Swing JTabbedPane
        TabMATLABComponentContainer; % This contains the GCardPane
    end
    
    methods
        function obj=GTabbedPane(target, point, tabPane)
            % GTabbedPane constructor
            if isappdata(target, 'hasGTabbedPane')
                % Only 1 per MATLAB container
                throw(MException('GTabbedPane:addingMultiple', 'Container may have only one GTabbedPane'));
            end
            % Defaults
            if nargin<2;point='top';end
            % Tab buttons
            [TabButtonContainerPosition, point]=tabPlacement(point);
            % Create the JTabbedPane...
            obj.TabButtonContainer=uipanel('Parent', target, 'Position', TabButtonContainerPosition, 'BorderType', 'none');
            set(obj.TabButtonContainer, 'Units', 'pixels', 'Tag', 'GTabbedPane:TabButtonContainer');
            pos=get(obj.TabButtonContainer, 'Position');
            switch point
                case javax.swing.JTabbedPane.TOP
                    pos(2)=pos(2)+pos(4)-obj.Depth;
                    pos(4)=obj.Depth;
                    %border=javax.swing.border.EmptyBorder(0,10,0,10);
                case javax.swing.JTabbedPane.BOTTOM
                    pos(2)=1;
                    pos(4)=obj.Depth+1;
                    %border=javax.swing.border.EmptyBorder(0,10,0,10);
                case javax.swing.JTabbedPane.LEFT
                    pos(1)=1;
                    pos(3)=obj.Depth();
                    %border=javax.swing.border.EmptyBorder(10,0,10,0);
                case javax.swing.JTabbedPane.RIGHT
                    pos(1)=pos(1)+pos(3)-obj.Depth;
                    pos(3)=obj.Depth;
                    %border=javax.swing.border.EmptyBorder(10,0,10,0);
            end
            set(obj.TabButtonContainer, 'Position', pos);
            set(obj.TabButtonContainer, 'Units', 'normalized');
            panel=jcontrol(obj.TabButtonContainer, javax.swing.JPanel(java.awt.GridLayout(1,1)), 'Position', [0.005 0 0.995 1]);
            %panel.setBorder(border);
            panel.setBackground(java.awt.Color.white);
            if nargin<3
                tabPane=javaObjectEDT(javax.swing.JTabbedPane(point));
            else
                tabPane=javaObjectEDT(tabPane);
                tabPane.setTabPlacement(point);
            end
            panel.setBackground(java.awt.Color.white);
            %panel.setAlignmentX(align)
            obj.Object=handle(panel.add(tabPane),'callbackproperties');
            % ... then the GCardPane
            switch point
                case javax.swing.JTabbedPane.TOP
                    TabComponentContainerPosition=[1 1 pos(3) pos(2)];
                case javax.swing.JTabbedPane.BOTTOM
                    units=get(target, 'Units');
                    set(target, 'Units', 'pixels');
                    pt=get(target, 'Position');
                    set(target, 'Units', units);
                    TabComponentContainerPosition=[1 obj.Depth pos(3) pt(4)-obj.Depth];
                case javax.swing.JTabbedPane.LEFT
                    units=get(target, 'Units');
                    set(target, 'Units', 'pixels');
                    pt=get(target, 'Position');
                    set(target, 'Units', units);
                    TabComponentContainerPosition=[obj.Depth 1 pt(3)-obj.Depth pos(4)];
                case javax.swing.JTabbedPane.RIGHT
                    TabComponentContainerPosition=[1 1 pos(1) pos(4)];
            end
            
            obj.TabMATLABComponentContainer=uipanel('Parent', target, 'Units', 'pixels',...
                'Position', TabComponentContainerPosition,...
                'BackgroundColor', GTool.getDefault('GCardPane.MATLABBackground'),...
                'BorderType', 'none',...
                'Tag', 'GTabbedPane:TabMATLABComponentContainer');
            set(obj.TabMATLABComponentContainer, 'Units', 'normalized');
            obj.Components{1}=GCardPane(obj.TabMATLABComponentContainer);
            % Do some housework...
            obj.Parent=target;
            setappdata(target, 'hasGTabbedPane', true);
            obj.onCleanup();
            set(obj.Object, 'StateChangedCallback', {@StateChangedFcn, obj});
            return
        end
        
        function h=addTab(obj, str, comp)
            % addTab adds a tab to the GTabbedPane
            % Example
            %       h=obj.addTab(str)
            %           where str is a string for the tab button
            % Also
            %       h=addTab(obj, str, comp)
            %           where comp is a Swing component to add to the
            %           underlying JTabbedPane. Use setDepth to make 
            %           these visible       
            if nargin<3 || isempty(comp)
                switch obj.Object.getTabPlacement()
                    case {javax.swing.JTabbedPane.TOP, javax.swing.JTabbedPane.BOTTOM}
                        or=javax.swing.SwingConstants.HORIZONTAL;
                    case {javax.swing.JTabbedPane.LEFT, javax.swing.JTabbedPane.RIGHT}
                        or=javax.swing.SwingConstants.VERTICAL;
                end
                comp=javaObjectEDT(javax.swing.JSeparator(or));
            else
                comp=handle(javaObjectEDT(comp),'callbackproperties');
            end
            status=obj.Components{1}.isAnimated();
            obj.Components{1}.setAnimated(false);
            h=obj.Components{1}.addTab();
            set(h,'BackgroundColor', GTool.getDefault('GCardPane.MATLABBackground'));
            obj.Object.addTab(str,comp);
            obj.setSelectedIndex(obj.Object.getTabCount());
            obj.Components{1}.setAnimated(status);
            if obj.Object.getComponentCount()==1
                r=obj.Object.getUI().getTabBounds(obj.Object, 0);
                switch obj.Object.getTabPlacement()
                    case javax.swing.JTabbedPane.TOP
                        obj.setDepth(r.getHeight()+2);
                    case javax.swing.JTabbedPane.BOTTOM
                        obj.setDepth(r.getHeight()+3);
                    case javax.swing.JTabbedPane.LEFT
                        obj.setDepth(r.getWidth()+2);
                    case javax.swing.JTabbedPane.RIGHT
                        obj.setDepth(r.getWidth()+4);
                end
            end
            set(h, 'ResizeFcn', {@LocalResize, obj});
            return
        end
        
        
        function val=getComponentCount(obj)
            % getComponentCount returns the number of tabs
            % Example:
            %       n=obj.getComponentCount()
            val=obj.Object.getComponentCount();
            return
        end
        
        function comp=getJavaComponentAt(obj, idx)
            % getJavaComponentAt returns the Swing component associated
            % with a specified tab
            % Example:
            %       jobj=obj.getJavaComponentAt(n)
            try
                comp=obj.Object.getComponentAt(idx-1);
            catch e
                if ~isempty(strfind(e.message,'java.lang.ArrayIndexOutOfBoundsException'))
                    throw(MException('GTabbedPane:Index', 'Index (%d) out of bounds.',idx));
                else
                    rethrow(e);
                end
            end
            return
        end
            
        function comp=getComponentAt(obj, idx1, idx2)
            % getComponentAt returns the MATLAB container(s) associated
            % with a tab
            % Examples
            %      h=obj.getComponentAt(2);    % 2nd card
            %      h=obj.getComponentAt(2:5);  % 2nd through 5th cards
            % For GTabbedPanes with multiple components, you can specify
            % the GCardPane (or similar) 
            %      h=obj.getComponentAt(2, 1);   % return 1st card from 2nd
            %                                    % component
            % Singleton results are returned as a scalar, multiple results
            % as a cell array
            try                               
            if nargin==2
                n=1;
                idx=idx1;
                comp=obj.Components{n}.Components{idx};
            elseif nargin==3
                n=idx1;
                idx=idx2;
                comp=obj.Components{n}.Components(idx);
                if numel(comp)==1
                    comp=cellmat(comp);
                end
            end
            catch e
                switch e.identifier
                    case 'MATLAB:badsubscript'
                        throw(MException('GTabbedPane:Index', 'Index (%d) out of bounds.', idx));
                    otherwise
                        rethrow(e);
                end
            end
            return
        end
        
        function val=getDepth(obj)
            % getDepth returns the depth in pixels for the JTabbedPane.
            % Depth is the width for left/right aligned JTabbedPanes and
            % the height for top/bottom alignment
            % Example:
            %       d=obj.getDepth();
            val=obj.Depth;
            return
        end
        
        function setDepth(obj, val)
            % setDepth sets the depth in pixels for the JTabbedPane.
            % Depth is the width for left/right aligned JTabbedPanes and
            % the height for top/bottom alignment. 
            % Example:
            %       obj.setDepth(d);            
            obj.Depth=val;
            LocalResize(obj.TabButtonContainer, [], obj);
            return
        end
        
        function setSelectedIndex(obj, idx)
            % setSelectedIndex selects the specifid tab
            % Example:
            %     obj.setSelectedIndex(n)
            for m=1:numel(obj.Components)
                obj.Components{m}.setSelectedIndex(idx);
            end
            obj.Object.setSelectedIndex(idx-1);
            drawnow();
            return
        end
        
        function idx=getSelectedIndex(obj)
            idx=obj.Object.getSelectedIndex()+1;
            return
        end
        
        function addPane(obj, cardpane)
            obj.Components{end+1}=cardpane;
            return
        end
        
        function setDockable(varargin)
            return
        end
        
        function setClosable(varargin)
            return
        end
        
        function setAnimated(obj, flag)
            obj.Components{1}.setAnimated(flag);
            return
        end
        
        function flag=isAnimated(obj)
            flag=obj.Components{1}.isAnimated();
            return
        end
        
    end
    
end

% Helpers/Callbacks

function [TabButtonContainerPosition, point]=tabPlacement(point)
switch lower(point)
    case {'east', 'right'}
        TabButtonContainerPosition=[0.9 0 0.1 1];
        point=javax.swing.JTabbedPane.RIGHT;
    case {'west', 'left'}
        TabButtonContainerPosition=[0 0 1 1];
        point=javax.swing.JTabbedPane.LEFT;
    case {'north', 'top'}
        TabButtonContainerPosition=[0 0.9 1 0.1];
        point=javax.swing.JTabbedPane.TOP;
    case {'south', 'bottom'}
        TabButtonContainerPosition=[0 0 1 0.1];
        point=javax.swing.JTabbedPane.BOTTOM;
end
return
end

function StateChangedFcn(hObject, EventData, obj)
for m=1:numel(obj.Components)
    obj.Components{m}.setSelectedIndex(hObject.getSelectedIndex()+1);
end
return
end
    
function LocalResize(hObject, EventData, obj)
units=get(obj.TabButtonContainer, 'Units');
set(obj.TabButtonContainer, 'Units', 'pixels');
pos=get(obj.TabButtonContainer, 'Position');
if pos(3)<=0 || pos(4)<=0
    % Avoid problems with completely collapse side in e.g. a split pane
    set(obj.TabButtonContainer, 'Units', units);
    return
end
switch obj.Object.getTabPlacement()
    case javax.swing.JTabbedPane.TOP
        pos(2)=pos(2)+pos(4)-obj.Depth;
        pos(4)=obj.Depth;
    case javax.swing.JTabbedPane.BOTTOM
        pos(2)=1;
        pos(4)=obj.Depth;
    case javax.swing.JTabbedPane.LEFT
        pos(1)=1;
        pos(3)=obj.Depth();
    case javax.swing.JTabbedPane.RIGHT
        pos(1)=pos(1)+pos(3)-obj.Depth;
        pos(3)=obj.Depth;
end
set(obj.TabButtonContainer, 'Position', pos);
set(obj.TabButtonContainer, 'Units', units);
switch obj.Object.getTabPlacement()
    case javax.swing.JTabbedPane.TOP
        ContainerPosition=[1 1 pos(3) pos(2)];
    case javax.swing.JTabbedPane.BOTTOM
        units=get(obj.Parent, 'Units');
        set(obj.Parent, 'Units', 'pixels');
        pt=get(obj.Parent, 'Position');
        set(obj.Parent, 'Units', units);
        ContainerPosition=[1 obj.Depth pos(3) pt(4)-obj.Depth];
    case javax.swing.JTabbedPane.LEFT
        units=get(obj.Parent, 'Units');
        set(obj.Parent, 'Units', 'pixels');
        pt=get(obj.Parent, 'Position');
        set(obj.Parent, 'Units', units);
        ContainerPosition=[obj.Depth 1 pt(3)-obj.Depth pos(4)];
    case javax.swing.JTabbedPane.RIGHT
        ContainerPosition=[1 1 pos(1) pos(4)];
end
units=get(obj.TabMATLABComponentContainer, 'Units');
set(obj.TabMATLABComponentContainer, 'Units', 'pixels');
set(obj.TabMATLABComponentContainer,'Position', ContainerPosition);
set(obj.TabMATLABComponentContainer, 'Units', units);
return
end

        