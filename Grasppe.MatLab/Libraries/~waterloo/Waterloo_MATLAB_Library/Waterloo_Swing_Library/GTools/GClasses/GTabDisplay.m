classdef GTabDisplay < GTool
    % GTabDisplay class
    % 
    % A GTabDisplay provides the graphical control element for a tab-style
    % control of a GCardPane
    %
    % A GTabDisplay is not a stand-alone component but functions only 
    % within the context of a container class that also houses a
    % GCardDisplay such as the GTabContainer class.
    %
    % The GTabDisplay implements the controls that affect tab selection,
    % docking etc internally, but these need to be propagated to the
    % GCardPane via the container: For tab selection, set the 
    % SelectionChangeCallback property of the GTabDisplay to call
    % a function in the container class. Undocking/closing buttons have no
    % affect unless callbacks are set for them in the containing class.
	%
    % Example:
    %       g=GTabDisplay(target, side);
    %
    %       where   target
    %                   is the MATLAB container to receive the
    %                   GTabDisplay (typically a figure or uipanel)
    %               side 
    %                   is 'top' or bottom' and sets the position of the
    %                   tab display within the host MATLAB container.
    %
    % For an example of the use of GTabDisplay, see the GTabContainer
    % class.
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 09/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties (Access=public)
        StateChangedCallback;
        tabButton;  
    end
    
    properties (SetAccess=private, GetAccess=public)
        Parent;
        Type=mfilename();
        TabContainer;
        Theme;
        Display;
        Components;
        SelectedIndex=-1;
        
        tabPlacement;
        viewPort;
        
        ListButton;
    end
    
    
    methods
        
        function tabPanel=GTabDisplay(pobj, point)
            tabPanel.Parent=pobj.TabButtonContainer;
            tabPanel.TabContainer=pobj;
            container=pobj.TabButtonContainer;
            layout=javax.swing.SpringLayout();
            tabPanel.Object=jcontrol(container, GTool.getDefault('TabDisplay.Panel'), 'Position', [0 0 1 1]);
            color=GTool.getDefault('TabDisplay.Background');
            try
                color=color.getColor2();
            catch %#ok<CTCH>
                color=color.brighter();
            end
            tabPanel.Object.setBorder(javax.swing.border.LineBorder(color,1,false));
            tabPanel.Object.setLayout(layout);
            tabPanel.Object.setBackground(GTool.getDefault('TabDisplay.Background'));
            tabPanel.tabPlacement=point;
            switch tabPanel.tabPlacement
                case {javax.swing.JTabbedPane.TOP, javax.swing.JTabbedPane.BOTTOM}
                    endPanel1=tabPanel.Object.add(javax.swing.JPanel(java.awt.GridLayout(1,1)));
                    centerPanelHost=handle(tabPanel.Object.add(javax.swing.JViewport()));
                    listPanel=tabPanel.Object.add(javax.swing.JPanel(java.awt.GridLayout(1,1)));
                    endPanel2=tabPanel.Object.add(javax.swing.JPanel(java.awt.GridLayout(1,1)));
                    
                    centerPanelHost.setBackground(java.awt.Color(0,0,0,0));

                    centerPanel=handle(javax.swing.JPanel());
                    centerPanelHost.setView(centerPanel);
                    centerPanel.setLayout(javax.swing.SpringLayout());
                    centerPanel.setBackground(java.awt.Color(0,0,0,0));
                    
                    endButton1=endPanel1.add(javax.swing.JButton(GTool.getDefault('Icon.MOVELEFT')));
                    endButton2=endPanel2.add(javax.swing.JButton(GTool.getDefault('Icon.MOVERIGHT')));
                    listButton=listPanel.add(javax.swing.JButton(GTool.getDefault('Icon.DOWNARROW')));
                    
                    endButton1.setContentAreaFilled(false);
                    endButton1.setFocusPainted(false);
                    endButton1.setBorder(javax.swing.border.SoftBevelBorder(javax.swing.border.SoftBevelBorder.LOWERED));
                    endButton1.setPreferredSize(java.awt.Dimension(15,32767));
                    listButton.setContentAreaFilled(false);
                    listButton.setFocusPainted(false);
                    listButton.setBorder(javax.swing.border.SoftBevelBorder(javax.swing.border.SoftBevelBorder.LOWERED));
                    listButton.setPreferredSize(java.awt.Dimension(15,32767));
                    endButton2.setContentAreaFilled(false);
                    endButton2.setFocusPainted(false);
                    endButton2.setBorder(javax.swing.border.SoftBevelBorder(javax.swing.border.SoftBevelBorder.LOWERED));
                    endButton2.setPreferredSize(java.awt.Dimension(15,32767));

                    layout.putConstraint(javax.swing.SpringLayout.WEST, endPanel1, 2,javax.swing.SpringLayout.WEST, tabPanel.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.NORTH, endPanel1, 2,javax.swing.SpringLayout.NORTH, tabPanel.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.SOUTH, endPanel1, -3,javax.swing.SpringLayout.SOUTH, tabPanel.Object.hgcontrol);
                    
                    layout.putConstraint(javax.swing.SpringLayout.EAST, endPanel2, -3,javax.swing.SpringLayout.EAST, tabPanel.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.NORTH, endPanel2, 2,javax.swing.SpringLayout.NORTH, tabPanel.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.SOUTH, endPanel2, -3,javax.swing.SpringLayout.SOUTH, tabPanel.Object.hgcontrol);
                    
                    layout.putConstraint(javax.swing.SpringLayout.EAST, listPanel, -2, javax.swing.SpringLayout.WEST, endPanel2);
                    layout.putConstraint(javax.swing.SpringLayout.NORTH, listPanel, 2,javax.swing.SpringLayout.NORTH, tabPanel.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.SOUTH, listPanel, -3,javax.swing.SpringLayout.SOUTH, tabPanel.Object.hgcontrol);
                   
                    layout.putConstraint(javax.swing.SpringLayout.WEST, centerPanelHost, 20,javax.swing.SpringLayout.WEST, tabPanel.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.EAST, centerPanelHost, -5,javax.swing.SpringLayout.WEST, listPanel);
                    switch tabPanel.tabPlacement
                        case javax.swing.JTabbedPane.TOP
                            layout.putConstraint(javax.swing.SpringLayout.NORTH, centerPanelHost, 5,javax.swing.SpringLayout.NORTH, tabPanel.Object.hgcontrol);
                            layout.putConstraint(javax.swing.SpringLayout.SOUTH, centerPanelHost, 0,javax.swing.SpringLayout.SOUTH, tabPanel.Object.hgcontrol);
                        case javax.swing.JTabbedPane.BOTTOM
                            layout.putConstraint(javax.swing.SpringLayout.NORTH, centerPanelHost, 0,javax.swing.SpringLayout.NORTH, tabPanel.Object.hgcontrol);
                            layout.putConstraint(javax.swing.SpringLayout.SOUTH, centerPanelHost, -5,javax.swing.SpringLayout.SOUTH, tabPanel.Object.hgcontrol);
                    end
                    
                    layout.putConstraint(javax.swing.SpringLayout.WEST, centerPanel, -2,javax.swing.SpringLayout.WEST, centerPanelHost);
                    layout.putConstraint(javax.swing.SpringLayout.EAST, centerPanel, -2,javax.swing.SpringLayout.EAST, centerPanelHost);
                    layout.putConstraint(javax.swing.SpringLayout.NORTH, centerPanel, 0,javax.swing.SpringLayout.NORTH, centerPanelHost);
                    layout.putConstraint(javax.swing.SpringLayout.SOUTH, centerPanel, 0,javax.swing.SpringLayout.SOUTH, centerPanelHost);
                    centerPanel.setPreferredSize(java.awt.Dimension(32767,centerPanel.getHeight()));

                    tabPanel.Object.revalidate();
                    
                    set(handle(endButton1, 'callbackproperties'), 'ActionPerformedCallBack', {@MoveLeft, tabPanel});
                    set(handle(endButton2, 'callbackproperties'), 'ActionPerformedCallBack', {@MoveRight, tabPanel});
                    set(handle(listButton, 'callbackproperties'), 'ActionPerformedCallback', {@CardSelector, tabPanel});
                case {javax.swing.JTabbedPane.LEFT, javax.swing.JTabbedPane.RIGHT}
            end
            
            tabPanel.Display=centerPanel;
            tabPanel.viewPort=centerPanelHost;
            tabPanel.Theme=GTool.getTheme();
            
            tabPanel.ListButton=handle(listButton, 'callbackproperties');
            tabPanel.onCleanup();
            return
        end
        
        function [comp, label, dockButton, closeButton]=addTab(obj, str)
            % addTab adds a tab to the GTabDisplay
            % Example
            %       [comp, label, dockButton, closeButton]=obj.addTab(str)
            %           where comp is a Swing component added to the
            %           GTabDisplay with contents [L to R] dockButton, label,
            %           and closeButoon. 
            [comp, label, dockButton, closeButton]=createTabButton(str, obj);
            obj.Display.add(comp);
            switch obj.tabPlacement
                case javax.swing.JTabbedPane.TOP
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.SOUTH, comp, 1,...
                        javax.swing.SpringLayout.SOUTH, obj.Display);
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.NORTH, comp, 1,...
                        javax.swing.SpringLayout.NORTH, obj.Display);
                case javax.swing.JTabbedPane.BOTTOM
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.NORTH, comp, 0,...
                        javax.swing.SpringLayout.NORTH, obj.Display);
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.SOUTH, comp, -1,...
                        javax.swing.SpringLayout.SOUTH, obj.Display);
            end
            if obj.Display.getComponentCount()==1
                obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.WEST, comp, 5,...
                    javax.swing.SpringLayout.WEST, comp.getParent());
            else
                lastC=obj.Display.getComponent(obj.Display.getComponentCount()-2);
                obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.WEST, comp, 5,...
                    javax.swing.SpringLayout.EAST, lastC);
            end
            obj.Display.revalidate();
            obj.tabButton{end+1}=comp;
            obj.setSelectedIndex(obj.getTabCount());
            set(label, 'ActionPerformedCallBack', {@ActionPerformedCallback, obj});
            return
        end
        
        function comp=getComponent(obj, idx)
            comp=obj.Object.getComponent(idx);
            return
        end
        
        function val=getComponentCount(obj)
            % getComponentCount returns the number of tabs
            % Example:
            %       n=obj.getComponentCount()
            val=numel(obj.tabButton);
            return
        end
        
        function comp=getJavaComponentAt(obj, idx)
            % getJavaComponentAt returns the Swing component associated
            % with a specified tab
            % Example:
            %       jobj=obj.getJavaComponentAt(n)
            comp=obj.tabButton{idx};
            return
        end
        
        function idx=indexOfJComponent(obj, comp)
            % indexOfJComponent returns the index of the specified
            % component
            % Example:
            %     h=obj.indexOfComponent(comp)
            for k=1:numel(obj.tabButton)
                if obj.tabButton{k}.equals(comp);
                    idx=k;
                    return
                end
            end
            idx=-1;
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
            % setSelectedIndex selects the specified tab
            % Example:
            %     obj.setSelectedIndex(n)
            if obj.isValidTab(idx)
                % Use the old index to start...
                if obj.isValidTab(obj.SelectedIndex)
                    comp=obj.getJavaComponentAt(obj.SelectedIndex);
                    comp.setBackground(comp.getBackground().darker());
                end
                % ... now the new one
                %obj.SelectedIndex=idx;
                if (obj.TabContainer.getSelectedIndex()~=idx)
                    obj.TabContainer.setSelectedIndex(idx);
                end
                for m=1:numel(obj.Components)
                    obj.Components{m}.setSelectedIndex(idx);
                end
                comp=obj.getJavaComponentAt(idx);
                comp.setBackground(comp.getBackground().brighter());
                refresh(gcf);
            elseif idx<0
                % Resets to no selection - used when removing tabs
                if obj.isValidTab(obj.SelectedIndex)
                    comp=obj.getJavaComponentAt(obj.SelectedIndex);
                    comp.setBackground(comp.getBackground().darker());
                end
                obj.SelectedIndex=-1;
            end
            obj.scrollToSelectedTab();
            return
        end
        
        function forceSelectedIndex(obj, idx)
            obj.SelectedIndex=idx;
        end
        
        
        function idx=getSelectedIndex(obj)
            idx=obj.SelectedIndex;
            return
        end
        
        
        function clearSelection(obj)
            comp=obj.getJavaComponentAt(obj.getSelectedIndex());
            comp.setBackground(comp.getBackground().darker());
            obj.SelectedIndex=-1;
            return
        end
        
        function addPane(obj, cardpane)
            obj.Components{end+1}=cardpane;
            return
        end
        
        function n=getTabCount(obj)
            n=obj.getComponentCount();
            return
        end
        
        function tpos=getTabPlacement(obj)
            tpos=obj.tabPlacement;
            return
        end
        
        function setBackground(varargin)
            return
        end
        
        function setBackgroundAt(varargin)
            return
        end
        
        function flag=isValidTab(obj, n)
            if n>0 && n<=obj.getTabCount()
                flag=true;
            else
                flag=false;
            end
            return
        end
        
        function setDockable(obj, idx, flag)
            obj.tabButton{idx}.getComponent(1).setVisible(flag);
            return
        end
        
        function setClosable(obj, idx, flag)
            obj.tabButton{idx}.getComponent(2).setVisible(flag);
            return
        end
        
        function removeTab(obj, idx)
            % removeTab removes a specified tab from the layout
            % Example:
            %   obj.removeTab(index)
            if obj.isValidTab(idx)
                currentIndex=obj.getSelectedIndex();
                obj.setSelectedIndex(-1);
                obj.tabButton{idx}.getParent().remove(obj.tabButton{idx});
                obj.tabButton(idx)=[];
                if numel(obj.tabButton)>0
                    obj.tabButton{1}.getParent().getLayout().putConstraint(javax.swing.SpringLayout.WEST,...
                        obj.tabButton{1},...
                        10,...
                        javax.swing.SpringLayout.WEST,...
                        obj.tabButton{1}.getParent());
                    obj.tabButton{1}.getParent().revalidate();
                end
                % NB numel(obj.Object.tabButton) now reduced by 1
                if numel(obj.tabButton)>=1
                    if idx==1
                        obj.tabButton{1}.getParent().getLayout().putConstraint(javax.swing.SpringLayout.WEST,...
                            obj.tabButton{1},...
                            10,...
                            javax.swing.SpringLayout.WEST,...
                            obj.tabButton{1}.getParent());
                    elseif idx<=numel(obj.tabButton)
                        obj.tabButton{idx}.getParent().getLayout().putConstraint(javax.swing.SpringLayout.WEST,...
                            obj.tabButton{idx},...
                            5,...
                            javax.swing.SpringLayout.EAST,...
                            obj.tabButton{idx-1});
                    end
                    obj.tabButton{1}.getParent().revalidate();
                    if currentIndex>idx
                        obj.setSelectedIndex(currentIndex-1);
                    else
                        obj.setSelectedIndex(currentIndex);
                    end
                end
            end
            return
        end
        
        function [comp, label, dockButton, closeButton]=insertTab(obj, str,idx)
            % addTab adds a tab to the GTabbedPane
            % Example
            %       [comp, label, dockButton, closeButton]=obj.addTab(str)
            %           where comp is a Swing component added to the
            %           GTabDisplay with contents [L to R] dockButton, label,
            %           and closeButoon.
            obj.setSelectedIndex(-1);
            [comp, label, dockButton, closeButton]=createTabButton(str, obj);
            obj.Display.add(comp, idx-1);
            obj.tabButton=[];
            for k=1:obj.Display.getComponentCount()
                obj.tabButton{k}=obj.Display.getComponent(k-1);
            end
            switch obj.tabPlacement
                case javax.swing.JTabbedPane.TOP
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.SOUTH, comp, 1,...
                        javax.swing.SpringLayout.SOUTH, obj.Display);
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.NORTH, comp, 1,...
                        javax.swing.SpringLayout.NORTH, obj.Display);
                case javax.swing.JTabbedPane.BOTTOM
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.NORTH, comp, 0,...
                        javax.swing.SpringLayout.NORTH, obj.Display);
                    obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.SOUTH, comp, -1,...
                        javax.swing.SpringLayout.SOUTH, obj.Display);
            end
            obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.WEST, obj.tabButton{1}, 5,...
                javax.swing.SpringLayout.WEST, obj.tabButton{1}.getParent());
            for k=2:numel(obj.tabButton)
                obj.Display.getLayout().putConstraint(javax.swing.SpringLayout.WEST, obj.tabButton{k}, 5,...
                    javax.swing.SpringLayout.EAST, obj.tabButton{k-1});
            end
            obj.Display.revalidate();
            set(label, 'ActionPerformedCallBack', {@ActionPerformedCallback, obj});
            obj.setSelectedIndex(idx);
            return
        end
        
    end
    
    methods (Access=private)
        
        function idx=getTabButtonIndex(obj, comp)
            for idx=1:numel(obj.tabButton)
                if comp.equals(obj.tabButton{idx})
                    return
                end
            end
            idx=-1;
            return
        end
        
        function scrollToSelectedTab(obj)
            idx=obj.getSelectedIndex();
            if obj.isValidTab(idx)
                bounds=obj.tabButton{idx}.getBounds();
                vp=obj.tabButton{idx}.getParent().getParent();
                obj.tabButton{idx}.getParent().scrollRectToVisible(bounds);
                vp.revalidate();
            end
            return
        end
        
    end
end

function [comp, label, dockButton, closeButton]=createTabButton(str, obj)
presentTheme=GTool.getTheme();
if ~strcmpi(obj.Theme, presentTheme)
    GTool.setTheme(obj.Theme);
end
layout=javax.swing.SpringLayout();
comp=handle(javax.swing.JPanel(layout), 'callbackproperties');

label=handle(comp.add(javax.swing.JButton(str)),'callbackproperties');
dockButton=handle(comp.add(javax.swing.JButton(GTool.getDefault('TabDisplay.Icon.UNDOCK'))),'callbackproperties');
closeButton=handle(comp.add(javax.swing.JButton(GTool.getDefault('TabDisplay.Icon.CLOSE'))),'callbackproperties');

color=GTool.getDefault('TabDisplay.Background');
try
    color1=color.getColor1();
catch %#ok<CTCH>
    color1=color.brighter();
end
comp.setBackground(color1.brighter());
comp.setBorder(javax.swing.border.SoftBevelBorder(javax.swing.border.SoftBevelBorder.RAISED, color1, color1.brighter()));

% Setup text
label.setForeground(GTool.getDefault('TabDisplay.TextColor'));
label.setHorizontalAlignment(javax.swing.JLabel.CENTER);
label.setContentAreaFilled(false);
label.setFocusPainted(false);
label.setBorder([]);
label.setBackground(color1);
if isempty(label.getText())
    width=150;
else
    width=label.getFontMetrics(label.getFont()).stringWidth(label.getText())+45;
end
comp.setPreferredSize(java.awt.Dimension(width,20));
layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER, label, 0, javax.swing.SpringLayout.HORIZONTAL_CENTER, comp);
layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, label, 0, javax.swing.SpringLayout.VERTICAL_CENTER, comp);

% Setop dock button
dockButton.setPreferredSize(java.awt.Dimension(15,15));
dockButton.setContentAreaFilled(false);
dockButton.setBorder([]);
dockButton.setBackground(color1);
layout.putConstraint(javax.swing.SpringLayout.EAST, dockButton, -5, javax.swing.SpringLayout.WEST, label);
layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, dockButton, 0, javax.swing.SpringLayout.VERTICAL_CENTER, comp);

% Setup close button
closeButton.setPreferredSize(java.awt.Dimension(15,15));
closeButton.setContentAreaFilled(false);
closeButton.setBackground(color1);
closeButton.setBorder([]);
layout.putConstraint(javax.swing.SpringLayout.WEST, closeButton, 5, javax.swing.SpringLayout.EAST, label);
layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, closeButton, 0, javax.swing.SpringLayout.VERTICAL_CENTER, comp);

comp.revalidate();
if ~strcmpi(GTool.getTheme(), presentTheme)
    GTool.setTheme(presentTheme);
end
return
end


function ActionPerformedCallback(hObject, EventData, obj)
if ~isempty(obj.StateChangedCallback)
    if ischar(obj.StateChangedCallback)
        eval(obj.StateChangedCallback)
    elseif iscell(obj.StateChangedCallback)
        if numel(obj.StateChangedCallback)==1
            obj.StateChangedCallback{1}(obj.TabContainer, EventData)
        else
            obj.StateChangedCallback{1}(obj.TabContainer, EventData, obj.StateChangedCallback{2:end});
        end
    elseif isa(obj.StateChangedCallback, 'function_handle')
        obj.StateChangedCallback(obj.TabContainer, EventData)
    end
end
idx=obj.getTabButtonIndex(hObject.getParent());
obj.setSelectedIndex(idx);
return
end

function MoveLeft(hObject, EventData, obj)
obj.setSelectedIndex(max(1, obj.getSelectedIndex()-1));
return
end

function MoveRight(hObject, EventData, obj)
obj.setSelectedIndex(min(obj.getTabCount(), obj.getSelectedIndex()+1));
return
end

% MOVE TO THE TABCONTAINER

% Drop down list creation and control
function CardSelector(hObject, EventData, obj)
if obj.getComponentCount()>0
    list=cell(1,obj.getComponentCount());
    for k=1:obj.getComponentCount()
        list{k}=obj.tabButton{k}.getComponent(0).getText();
    end
    p=java.awt.Point(0,0);
    javax.swing.SwingUtilities.convertPointToScreen(p, hObject);
    p=MUtilities.convertToMATLAB(p);
    pos=MUtilities.convertPosition(p, 0, gcf);
    list=javax.swing.JList(list);
    sc=javax.swing.JScrollPane(list, javax.swing.JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED, javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
    ht=min(200,1.5*(list.getModel().getSize())*sc.getViewport().getView().getFontMetrics(sc.getViewport().getView().getFont()).getHeight());
    switch obj.tabPlacement
        case javax.swing.JTabbedPane.TOP
            j=jcontrol(gcf, sc, 'Units', 'pixels', 'Position', [pos(1)-150 pos(2)-ht 150 ht]);
        case javax.swing.JTabbedPane.BOTTOM
            j=jcontrol(gcf, sc, 'Units', 'pixels', 'Position', [pos(1)-150 pos(2) 150 ht]);
    end
    set(j, 'Units', 'normalized');
    set(handle(list,'callbackproperties'), 'MouseClickedCallback', {@LocalDelete, j, obj});
    set(handle(list,'callbackproperties'), 'MouseExitedCallback', {@LocalDelete, j, obj});
end
return
end

function LocalDelete(hObject, EventData, j, obj)
obj.setSelectedIndex(hObject.getSelectedIndex()+1);
delete(j);
return
end

