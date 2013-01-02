classdef GAccordion < GBasicCardGroup
    % GAccordion class
    % A GAccordion supports mutiple views inside a MATLAB container where
    % only one view is visible at any time.
    % GAccordion provides a usable GUI for the GCardPane
    % Example:
    %    g=GAccordion(target);
    %       where target is a MATLAB container handle (figure, uipanel etc).
    %
    % Add graphics to the GAccordion by creating a tab:
    %           MyPanel=g.addTab('My new panel');
    %           ax=axes('parent', 'MyPanel',.....);
    %
    % To find the panel later:
    %           MyPanel=g.getComponentAt(n)
    %               where n is the tab number
    %
    % GAccordion displays are controlled from the banners shown at the top
    % of each card. Individual cards can be undocked to a new figure,
    % redocked, selected and closed using the buttons displayed.
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 08/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties (SetAccess=protected, GetAccess=public)
        Depth=30;
    end
    
    properties (Access=private)
        deleteUndocked=true;
        bannerPanelList;
        CardContainer;
        ResizeFix=false;
    end
    
    methods
        
        function obj=GAccordion(target)
            % Create a uipanel...
            obj.Parent=target;
            obj.CardContainer=uipanel(target, 'Units', 'normalized',...
                'BorderType', 'none',...
                'Position', [0 0 1 1],...
                'Tag','GAccordion:CardPaneContainer');
            % ... and put a CgacrdPane into it
            obj.Components{1}=GCardPane(obj.CardContainer);
            % Resizing of the parent controls the layout of the GAccordion
            set(target, 'ResizeFcn', {@LocalResize, obj});
            if verLessThan('MATLAB', '7.10') && ~verLessThan('MATLAB', '7.7')
                obj.ResizeFix=true;
            end
            obj.onCleanup();
        end
        
        function comp=getComponentAt(obj, idx)
            % getComponentAt returns the MATLAB container (card) for the
            % specified index
            % Example:
            %       obj.getComponentAt(idx)
            %    where idx is the card number
            comp=obj.getComponent(1).getComponent(idx);
            return
        end
        
        function setSelectedIndex(obj, idx)
            % setSelectedIndex sets and displays the specified card
            % Example:
            %       obj.setSelectedIndex(idx)
            %    where idx is the card number
            obj.getComponent(1).setSelectedIndex(idx);
            LocalResize(obj.Parent, [], obj);
            return
        end
        
        function comp=getSelectedComponent(obj)
            % getSelectedComponent returns the currently container
            % for the currently selected card
            % Example:
            %     h=obj.getSelectedComponent()
            if obj.getSelectedIndex()>=1
                comp=obj.getComponent(1).Components{obj.getSelectedIndex()};
            else
                comp=[];
            end
            return
        end
        
        
        function idx=getSelectedIndex(obj)
            % getSelectedIndex returns the index of the currently selected
            % card
            % Example:
            %     h=obj.getSelectedIndex()
            idx=obj.getComponent(1).getSelectedIndex();
            return
        end
        
        function idx=indexOfComponent(obj, comp)
            % indexOfComponent returns the index of the specified
            % component if the component is a card (or -1 if it is not)
            % Example:
            %     h=obj.indexOfComponent(comp)
            %      where comp is a MATLAB uicontainer, uipanel etc added to
            %      the GAccordion using addTab.
            idx=obj.getComponent(1).indexOfComponent(comp);
            return
        end
        
        function n=getTabCount(obj)
            % indexOfComponent returns the number of tabs (cards) in this
            % GAccordion
            % Example:
            %           n=obj.getTabCount();
            n=obj.getComponent(1).getTabCount();
            return
        end
        
        
        function comp=addTab(obj, string)
            % addTab adds a new card to the GAccordion and returns the
            % MATLAB container for that card
            % Example:
            %   comp=obj.addTab(title)
            %    where title is a string that will be used as the title for
            %    this card in the top banner
            comp=insertTab(obj, string);
            return
        end
        
        
        function removeTab(obj, idx)
            % removeTab removes a specified card (uipanel) from the layout
            % Example:
            %   obj.removeTab(index)
            if obj.isValidTab(idx)
                obj.Components{1}.removeTab(idx);
                bannerPanel=obj.bannerPanelList{idx};
                delete(bannerPanel);
                obj.bannerPanelList(idx)=[];
                LocalResize(obj.Parent, [], obj);
                if idx==1 && ~isempty(obj.bannerPanelList)
                    hlist=get(obj.bannerPanelList{1}, 'UserData'); 
                    hlist{3}.setEnabled(false);
                end
            end
            return
        end
        
        
        function flag=isValidTab(obj, idx)
            flag=obj.getComponent(1).isValidTab(idx);
            return
        end
        
        
        function undockTab(obj, idx)
            % undocks a specified card (uipanel) from the layout creating a
            % new figure for it
            % Example:
            %   obj.undockTab(index)
            if obj.isValidTab(idx)
                thisCard=obj.getComponentAt(idx);
                units=get(thisCard, 'Units');
                set(thisCard, 'Units', 'pixels');
                pos=get(thisCard, 'Position');
                set(thisCard, 'Units', units);
                pos(1)=100;pos(2)=100;
                newF=figure('Units', 'pixels', 'Position', pos, 'IntegerHandle', 'off');
                h=copyobj(thisCard, newF);
                set(h,'Units', 'normalized', 'Position',[0 0 1 1], 'Visible', 'on');
                set(newF, 'Name', get(h, 'UserData'));
                docker=jcontrol(newF, javax.swing.JButton(GTool.getDefaults().get('Icon.DOCK')), 'Position', [0.9 0.9, 0.05 0.05]);
                docker.setOpaque(false);
                set(docker, 'Units', 'pixels');
                pos=get(docker, 'Position');
                pos(3:4)=[25 25];
                set(docker, 'Position', pos);
                set(docker, 'Units', 'normalized');
                set(docker, 'ActionPerformedCallback', {@LocalDock, obj, h, idx});
                obj.removeTab(idx);
                if obj.deleteUndocked
                    list=getappdata(ancestor(obj.CardContainer, 'figure'),'GToolHandleList');
                    list{end+1}=newF;
                    setappdata(ancestor(obj.CardContainer, 'figure'),'GToolHandleList', list);
                end
            end
            return
            
            function LocalDock(hObject, EventData, obj, h, idx)
                % Callback from undocked thisCard - inserts the
                % component back at the original tab index
                if idx==1 && ~isempty(obj.bannerPanelList)
                    hlist=get(obj.bannerPanelList{1}, 'UserData'); 
                    hlist{3}.setEnabled(true);
                end
                flag=obj.isAnimated();
                obj.setAnimated(false);
                for k=obj.getTabCount():-1:idx
                    obj.Components{1}.Components{k+1}=obj.Components{1}.Components{k};
                    obj.bannerPanelList{k+1}=obj.bannerPanelList{k};
                end
                obj.Components{1}.Components{idx}=[];
                obj.bannerPanelList{idx}=[];
                obj.insertTab(get(h, 'UserData'), h, idx);
                LocalResize(obj.Parent, [], obj);
                obj.setAnimated(flag);
                return
            end
            
        end
        

        function setAnimated(obj, flag)
            % setAnimated switches between animation/no animation
            % Example
            %     obj.setAnimated(true);
            %     obj.setAnimated(false);
            obj.getComponent(1).setAnimated(flag);
            return
        end
        
        
        function val=isAnimated(obj)
            % isAnimated returns the animation flag
            % Example
            %     flag=obj.isAnimated();
            val=obj.getComponent(1).isAnimated();
            return
        end
        
        function setDockable(obj, idx, flag)
            t=get(get(obj.bannerPanelList{idx},'Children'), 'UserData');
            t.getComponent(1).getComponent(0).setVisible(flag);
            return
        end
        
        function setClosable(obj, idx, flag)
            t=get(get(obj.bannerPanelList{idx},'Children'), 'UserData');
            t.getComponent(1).getComponent(2).setVisible(flag);
            return
        end
        
        function setDockMode(obj, str)
            switch str
                case {'delete', 'clone'}
                    obj.dockMode=str;
                otherwise
                    warning('GTabContainer:setDockmode', 'Unsupported mode requested')
            end
            return
        end
        
    end
    
    
    
    methods (Access=private)
        
        function thisCard=insertTab(obj, string, comp, idx)
            if nargin<4
                idx=obj.getTabCount()+1;
            end
            pos=getpixelposition(obj.Components{1}.getParent());
            pos(4)=pos(4)-((idx-1)*obj.Depth)-1;

            % Content pane for this tab
            if nargin<3
                thisCard=uipanel(obj.Components{1}.getParent(), 'Units', 'pixels',...
                    'Position', [1 1 pos(3) pos(2)],...
                    'BorderType', 'none',...
                    'Tag', 'GAccordionthisCard',...
                    'UserData', string);
                obj.Components{1}.insertTab(thisCard);
            else
                fh=ancestor(comp, 'figure');
                thisCard=copyobj(comp, obj.Components{1}.getParent());
                set(thisCard, 'Units', 'pixels',...
                    'Position', [1 1 pos(3) pos(2)],...
                    'BorderType', 'none',...
                    'Tag', 'GAccordionthisCard',...
                    'UserData', string);
                obj.Components{1}.insertTab(thisCard, idx);
                delete(fh);
            end
            
            % Banner for this tab, note the associated thisCard is
            % cross-referenced in the UserData property
            pos(2)=max(1,pos(4)-obj.Depth)-1;
            bannerPanel=uipanel(obj.getParent(), 'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', pos,...,...
                'Tag', 'GAccordionBannerPanel');
            
            obj.Components{1}.insertTab(thisCard, idx);
            
            jbanner=jcontrol(bannerPanel, GTool.getDefault('Accordion.Panel'), 'Position', [0 0 1 1]);
            jbanner.setBackground(GTool.getDefault('Accordion.BannerBackground'));
            jbanner.setBorder(javax.swing.border.LineBorder(java.awt.Color.black,1,true));
            layout=javax.swing.SpringLayout();
            jbanner.setLayout(layout);
            
            left=jbanner.add(GTool.getDefault('Accordion.InnerPanel'));
            left.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.LEFT));
            right=jbanner.add(GTool.getDefault('Accordion.InnerPanel'));
            right.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));
            right.getLayout().setVgap(1);
            center=jbanner.add(GTool.getDefault('Accordion.InnerPanel'));
            center.setLayout(java.awt.FlowLayout());
            center.setPreferredSize(java.awt.Dimension(200,32767));
            set(handle(center, 'callbackproperties'), 'MouseClickedCallback', {@PanelSelection, thisCard, obj});
            set(jbanner, 'MouseClickedCallback', {@PanelSelection, thisCard, obj});
            
            layout.putConstraint(javax.swing.SpringLayout.WEST,left,1,javax.swing.SpringLayout.WEST,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.NORTH,left,1,javax.swing.SpringLayout.NORTH,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.EAST,right,-1,javax.swing.SpringLayout.EAST,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.NORTH,right,1,javax.swing.SpringLayout.NORTH,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.SOUTH,right,-1,javax.swing.SpringLayout.SOUTH,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.NORTH,center,1,javax.swing.SpringLayout.NORTH,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.SOUTH,center,-1,javax.swing.SpringLayout.SOUTH,jbanner.hgcontrol);
            layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER,center,0,javax.swing.SpringLayout.HORIZONTAL_CENTER,jbanner.hgcontrol);
            
            bck=GTool.getDefault('Accordion.InnerBannerBackground');
            left.setBackground(bck);
            center.setBackground(bck);
            right.setBackground(bck);
            
            dockButton=handle(right.add(javax.swing.JButton(GTool.getDefault('Icon.UNDOCK'))),'callbackproperties');
            dockButton.setPreferredSize(java.awt.Dimension(25,25));
            set(dockButton, 'ActionPerformedCallback', {@Undock, thisCard, obj});
            
            selectionButton=handle(right.add(javax.swing.JButton(GTool.getDefault('Icon.DOWNARROW'))),'callbackproperties');
            selectionButton.setPreferredSize(java.awt.Dimension(25,25));
            if idx==1
                selectionButton.setEnabled(false);
            else
                set(selectionButton, 'ActionPerformedCallback', {@SelectionChange, thisCard, obj});
            end
            
            closeButton=handle(right.add(javax.swing.JButton(GTool.getDefault('Icon.CLOSE'))),'callbackproperties');
            set(closeButton, 'ActionPerformedCallback', {@ClosePane, thisCard, obj});
            closeButton.setPreferredSize(java.awt.Dimension(25,25));
            
            txt=left.add(javax.swing.JLabel(string));
            set(handle(txt, 'callbackproperties'), 'MouseClickedCallback', {@PanelSelection, thisCard, obj});
            txt.setForeground(GTool.getDefault('Accordion.TextColor'));
            set([bannerPanel, thisCard], 'Units', 'normalized');
            set(bannerPanel, 'UserData', {thisCard, dockButton, selectionButton, closeButton});
            obj.bannerPanelList{idx}=bannerPanel;
            
            dockButton.setOpaque(false);
            selectionButton.setOpaque(false);
            closeButton.setOpaque(false);
            
            obj.setSelectedIndex(idx);
            
            set([thisCard, bannerPanel], 'Units', 'normalized');
            LocalResize(obj.Parent, [], obj);
            return
        end
        
        
    end
    
end

function LocalResize(hObject, EventData, obj)
% NB Apparently unnecessary set positions with normalized units are needed
% for R2008b & R2009a/b
if obj.getTabCount()==0 || isempty(obj.bannerPanelList)
    return
end
% Get the size of the main container
pos=gc_getpixelposition(hObject);
% For each tab, resize the banner
h2=[obj.bannerPanelList{:}];
for k=1:obj.getSelectedIndex()
    if obj.ResizeFix;set(h2(k), 'Position', get(h2(k), 'Position')+0.1);end
    gc_setpixelposition(h2(k),  [1 pos(4)-(k*obj.Depth) pos(3) obj.Depth+1]);
    hlist=get(h2(k), 'UserData');
    hlist{3}.setIcon(GTool.getDefaults().get('Icon.DOWNARROW'));
end
upperEdge=pos(4)-(k*obj.Depth)-1;
count=0;
for k=numel(h2):-1:obj.getSelectedIndex()+1
    if obj.ResizeFix;set(h2(k), 'Position', get(h2(k), 'Position')+0.1);end
    gc_setpixelposition(h2(k), [1 (count*obj.Depth) pos(3) obj.Depth+1]);
    hlist=get(h2(k), 'UserData');
    hlist{3}.setIcon(GTool.getDefaults().get('Icon.UPARROW'));
    count=count+1;
end
lowerEdge=(count*obj.Depth)+obj.Depth+1;
if obj.ResizeFix;set(obj.Components{1}.getParent(), 'Position', get(obj.Components{1}.getParent(), 'Position')+0.1);end
gc_setpixelposition(obj.Components{1}.getParent(), [1 lowerEdge pos(3) upperEdge-lowerEdge]);
h=findall(obj.Components{1}.getParent(), 'Tag', 'GAccordionthisCard');
set(h, 'Position', [0 0 1 1]);
return
end


function PanelSelection(hObject, EventData, thisCard, obj)
idx=obj.indexOfComponent(thisCard);
obj.setSelectedIndex(idx);
LocalResize(obj.CardContainer, [], obj);
return
end

function SelectionChange(hObject, EventData, thisCard, obj)
idx=obj.indexOfComponent(thisCard);
moveDirection=getDirection(hObject);
if strcmpi(moveDirection,'down')
    idx=max(1,idx-1);
end
obj.setSelectedIndex(idx);
LocalResize(obj.CardContainer, [], obj);
return
end


function Undock(hObject, EventData, comp, obj)
idx=obj.indexOfComponent(comp);
obj.undockTab(idx);
return
end

function ClosePane(hObject, EventData, thisCard, obj)
idx=obj.indexOfComponent(thisCard);
obj.removeTab(idx);
return
end

function moveDirection=getDirection(hObject)
if hObject.getIcon().equals(GTool.getDefaults().get('Icon.DOWNARROW'))
    moveDirection='down';
else
    moveDirection='up';
end
return
end
