classdef GTabContainer < GBasicCardGroup
    
    % TODO Check bug fix for setSelectedIndex
    
    % GTabContainer class
    % 
    % A GTabContainer provides a tab-controlled MATLAB view similar to the
    % Swing JTabbedPane.
    %
    % The GTabContainer has two primary components: a GTabDisplay which
    % provides the tab buttons and grapical controls for the view, and a
    % GCardPane which houses the MATLAB graphics. 
    %
    % Example:
    %           g=GTabContainer(target, side)
    %       where  target is the MATLAB container to receive the
    %               GTabContainer (typically a figure or uipanel)
    %              side is 'top' or bottom' and sets the position of the
    %              tab display relative to the GCardPane.
    %
    % The Waterloo Swig Library also provides a GTabbedPane which functions
    % similarly, but uses a Java Swing JTabbedPane instead of the custom
    % GTabDisplay used in the GTabContainer.
    %
    % GTabContainer and GTabDisplay objects are GTool theme enabled.
    %
    % Demo:
    %     GTool.setTheme('blue');
    %     g=GTabContainer(figure(), 'top');
    %     g.addTab('Panel 1');
    %     g.addTab('Panel 2');
    %     axes('Parent', g.getComponentAt(1));
    %     surf(peaks(30));
    %     axes('Parent', g.getComponentAt(2));
    %     contour(peaks(30));
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 09/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties(Access=public)
        deleteUndockedFigures=true;
        dockMode='delete';
    end
    
    properties (SetAccess=private, GetAccess=public)
        Depth=30;
        TabButtonContainer;          % This contains the Swing JTabbedPane
        TabMATLABComponentContainer; % This contains the GCardPane
    end
    
    methods
        function obj=GTabContainer(target, point)
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
                case javax.swing.JTabbedPane.BOTTOM
                    pos(2)=1;
                    pos(4)=obj.Depth+1;
                case javax.swing.JTabbedPane.LEFT
                    pos(1)=1;
                    pos(3)=obj.Depth();
                case javax.swing.JTabbedPane.RIGHT
                    pos(1)=pos(1)+pos(3)-obj.Depth;
                    pos(3)=obj.Depth;
            end
            set(obj.TabButtonContainer, 'Position', pos);
            set(obj.TabButtonContainer, 'Units', 'normalized');
            
            % ... then the GCardPane
            switch point
                case javax.swing.JTabbedPane.TOP
                    TabComponentContainerPosition=[1 1 pos(3) pos(2)];
                case javax.swing.JTabbedPane.BOTTOM
                    pt=gc_getpixelposition(target);
                    TabComponentContainerPosition=[1 obj.Depth pos(3) pt(4)-obj.Depth];
                case javax.swing.JTabbedPane.LEFT
                    pt=gc_getpixelposition(target);
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
            
            obj.Object=GTabDisplay(obj, point);
            
            % Do some housework...
            obj.Parent=target;
            setappdata(target, 'hasGTabbedPane', true);

            obj.onCleanup();
            return
        end
        
        function h=addTab(obj, str, dockAble, closeAble)
            % addTab adds a tab to the GTabbedPane
            % Example
            %       h=obj.addTab(str)
            if nargin<3
                dockAble=true;
            end
            if nargin<4
                closeAble=true;
            end
            status=obj.Components{1}.isAnimated();
            obj.Components{1}.setAnimated(false);
            h=obj.Components{1}.addTab();
            set(h,'BackgroundColor', GTool.getDefault('GCardPane.MATLABBackground'));
            [comp, label, dockButton, closeButton]=obj.Object.addTab(str);
            set(dockButton, 'ActionPerformedCallback', {@Undock, h, obj});
            set(closeButton, 'ActionPerformedCallback', {@CloseTab, obj});
            if ~dockAble;obj.setDockable(obj.getTabCount(), dockAble);end
            if ~closeAble;obj.setClosable(obj.getTabCount(), closeAble);end
            %obj.setSelectedIndex(obj.Object.getTabCount());
            obj.Components{1}.setAnimated(status);
            set(h, 'ResizeFcn', {@LocalResize, obj});
            return
        end
        
        function removeTab(obj, idx)
            % removeTab removes a specified card (uipanel) from the layout
            % Example:
            %   obj.removeTab(index)
            if obj.isValidTab(idx)
                obj.Components{1}.removeTab(idx);
                obj.Object.removeTab(idx);
            end
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
            if (obj.Object.getSelectedIndex()~=idx)
                obj.Object.forceSelectedIndex(idx);
            end
            return
        end
        
        function idx=getSelectedIndex(obj)
            idx=obj.Object.getSelectedIndex();
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
        
        function flag=isValidTab(obj, idx)
            flag=obj.getComponent(1).isValidTab(idx);
            return
        end
        
        function addPane(obj, cardpane)
            obj.Components{end+1}=cardpane;
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
        
        function n=getTabCount(obj)
            n=obj.getComponentCount();
            return
        end
        
%         function setBackground(obj)
%             return
%         end
        
        function setDockable(obj, idx, flag)
            obj.Object.setDockable(idx, flag);
            return
        end
        
        function setClosable(obj, idx, flag)
            obj.Object.setClosable(idx, flag);
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
        
        function undockTab(obj, idx)
            % undocks a specified card (uipanel) from the layout creating a
            % new figure for it
            % Example:
            %   obj.undockTab(index)
            if obj.isValidTab(idx)
                ContentPane=obj.getComponentAt(idx);
                units=get(ContentPane, 'Units');
                set(ContentPane, 'Units', 'pixels');
                pos=get(ContentPane, 'Position');
                set(ContentPane, 'Units', units);
                pos(1)=100;pos(2)=100;
                newF=figure('Units', 'pixels', 'Position', pos, 'IntegerHandle', 'off');
                if strcmp(obj.dockMode, 'clone')
                    % Temporarily clear DeleteFcn - otherwise deleting the
                    % clone deletes the originals
                    hgj=findall(ContentPane,'Type','hgjavacomponent');
                    del=get(hgj,'DeleteFcn');
                    set(hgj,'DeleteFcn',[]);
                end
                % Copy and ...
                h=copyobj(ContentPane, newF);
                % ... restore DeleteFcn as needed
                if strcmp(obj.dockMode, 'clone')
                    for kk=1:numel(hgj)
                        set(hgj(kk),'DeleteFcn', del{kk});
                    end
                end
                set(h,'Units', 'normalized', 'Position',[0 0 1 1], 'Visible', 'on');
                set(newF, 'Name', char(obj.Object.tabButton{idx}.getComponent(0).getText()));
                if strcmp(obj.dockMode, 'delete')
                    docker=jcontrol(newF, javax.swing.JButton(GTool.getDefaults().get('Icon.DOCK')), 'Position', [0.9 0.9, 0.05 0.05]);
                    docker.setOpaque(false);
                    pos=gc_getpixelposition(docker.hghandle);
                    pos(3:4)=[25 25];
                    gc_setpixelposition(docker.hghandle, pos);
                    set(docker, 'ActionPerformedCallback', {@LocalDock, obj, h, idx});
                    obj.removeTab(idx);
                end
                if obj.deleteUndockedFigures
                    list=getappdata(ancestor(obj.Parent, 'figure'),'GToolHandleList');
                    list{end+1}=newF;
                    setappdata(ancestor(obj.Parent, 'figure'),'GToolHandleList', list);
                end
            end
            return
            
            function LocalDock(hObject, EventData, obj, h, idx)
                % Callback from undocked ContentPane - inserts the
                % component back at the original tab index
                flag=obj.isAnimated();
                obj.setAnimated(false);
                for k=obj.getTabCount():-1:idx
                    obj.Components{1}.Components{k+1}=obj.Components{1}.Components{k};
                end
                obj.Components{1}.Components{idx}=[];
                h2=obj.Components{1}.insertTab(h, idx);
                [comp, label, dockButton, closeButton]=obj.Object.insertTab(get(ancestor(h, 'figure'),'Name'), idx);
                set(dockButton, 'ActionPerformedCallback', {@Undock, h2, obj});
                obj.setAnimated(flag);
                delete(ancestor(h,'figure'));
                return
            end
            
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

% function StateChangedCallback(hObject, EventData, obj)
% for m=1:numel(obj.Components)
%     obj.Components{m}.setSelectedIndex(obj.getSelectedIndex());
% end
% return
% end

function LocalResize(hObject, EventData, obj)
pos=gc_getpixelposition(obj.TabButtonContainer);
if pos(3)<=0 || pos(4)<=50
    % Avoid problems with completely collapsed side in e.g. a split pane
    return
end
switch obj.Object.getTabPlacement()
    case javax.swing.JTabbedPane.TOP
        ContainerPosition=[1 1 pos(3) pos(2)];
    case javax.swing.JTabbedPane.BOTTOM
        pt=gc_getpixelposition(obj.Parent);
        ContainerPosition=[1 obj.Depth pos(3) pt(4)-obj.Depth];
    case javax.swing.JTabbedPane.LEFT
    case javax.swing.JTabbedPane.RIGHT
end
gc_setpixelposition(obj.TabMATLABComponentContainer, ContainerPosition);
switch obj.Object.getTabPlacement()
    case javax.swing.JTabbedPane.TOP
        pos(2)=pos(2)+pos(4)-obj.Depth;
        pos(4)=obj.Depth;
    case javax.swing.JTabbedPane.BOTTOM
        pos(2)=1;
        pos(4)=obj.Depth;
    case javax.swing.JTabbedPane.LEFT
    case javax.swing.JTabbedPane.RIGHT
end
gc_setpixelposition(obj.TabButtonContainer, pos);
return
end


function Undock(hObject, EventData, comp, obj)
idx=obj.indexOfComponent(comp);
obj.undockTab(idx);
return
end


function CloseTab(hObject, EventData, obj)
previousIndex=obj.getSelectedIndex();
p=hObject.getParent();
for k=1:numel(obj.Object.tabButton)
    if p.equals(obj.Object.tabButton{k})
        obj.removeTab(k);
        if k<previousIndex
            obj.setSelectedIndex(previousIndex);
        else
            obj.setSelectedIndex(k-1);
        end
        return
    end
end
return
end