classdef GCardPane < GBasicCardGroup
    % GCardPane class
    %
    % GCardPane's are a set of overlapping containers where only one layer
    % is visible at a time. These are the cards of the card pane. Probably
    % the most frequent use of such a display is in a tabbed pane - so in
    % GCardPane the cards are called tabs and are conrolled using methods
    % like addTab.
    %
    % GCardPane is the basis of the GTabbedPane - look at the code there
    % for examples of its use. Remember though, that any component can
    % control the GCardPane view through a call to its setSelectedIndex
    % method.
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 03/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    
    properties
        SelectedIndex=-1;
    end
    
    methods
        
        function obj=GCardPane(target)
            % GCardPane constructor
            % Examples:
            %     obj=GCardPane(target)
            %     obj=GCardPane(target, PropName1, PropValue1, PropName2,...)
            %     where target is the MATLAB container for the GCardPane
            %     The property name/value pairs are applied to the uipanel
            %     that forms the first card in the deck
            if isappdata(target, 'hasGCardPane')
                throw(MException('GCardPane:addingMultiple', 'Container may have only one GCardLayout'));
            end
            % Create a uipanel
            obj.Parent=uipanel('Parent', target, 'BorderType','none', 'Units', 'normalized', 'Position', [0 0 1 1]);
            setappdata(obj.Parent, 'hasGCardPane', true);
            obj.setAnimated(GTool.getDefault('GCardPane.Animated'));
            obj.onCleanup();
            return
        end
        
        function h=addTab(obj, varargin)
            h=uipanel('Parent', obj.Parent, 'BorderType', 'none', varargin{:}, 'Units', 'normalized', 'Position', [0 0 1 1]);
            obj.Components{end+1}=h;
            obj.setSelectedIndex(numel(obj.Components));
            return
        end
        
        
        function removeTab(obj, idx)
            % removeTab removes a specified card (uipanel) from the layout
            % Example:
            %   obj.removeTab(index)
            if obj.isValidTab(idx)
                delete(obj.Components{idx});
                obj.Components(idx)=[];
                % NOTE TabCount now reduced by 1
                if idx>obj.getTabCount()
                    obj.SelectedIndex=idx-1;
                elseif idx<=obj.getSelectedIndex()
                    obj.SelectedIndex=idx;
                else
                    return
                end
                obj.setSelectedIndex(obj.getSelectedIndex(),true);
            end
            return
        end
        
        function val=getTabCount(obj)
            % getTabCount returns the number of available cards
            % Example;
            %   val=obj.getTabCount()
            val=numel(obj.Components);
            return
        end
        
        function idx=getSelectedIndex(obj)
            % getSelectedIndex returns the index of the currently selected card
            % (uipanel)
            % Example:
            %     h=obj.getSelectedIndex()
            idx=obj.SelectedIndex;
            return
        end
        
        
        function comp=getSelectedComponent(obj)
            % getSelectedComponent returns the currently selected card
            % (uipanel)
            % Example:
            %     h=obj.getSelectedComponent()
            if obj.SelectedIndex>=1
                comp=obj.Components{obj.SelectedIndex};
            else
                comp=[];
            end
            return
        end
        
        
        function idx=indexOfComponent(obj, comp)
            for idx=1:numel(obj.Components)
                if obj.Components{idx}==comp;
                    return
                end
            end
            idx=-1;
            return
        end
        
        function resetAll(obj)
            h=findall(obj.Parent, 'Tag', 'GCardPane:TempAxes');
            if ~isempty(h);delete(h);end
            obj.setSelectedIndex(1);
            return
        end
        
        function flag=isValidTab(obj, idx)
            % isValidTab returns true if a specified Tab Index is is range
            % i.e. between 1 and getTabCount
            % Example:
            %       flag=obj.isValidTab(index);
            if idx>=1 && idx<=numel(obj.Components)
                flag=true;
                return
            else
                flag=false;
            end
        end
        
        function setSelectedIndex(obj, idx, flag)
            % setSelectedIndex sets the currently selected card (uipanel)
            % Example:
            %     h=obj.setSelectedIndex(index)
            
            % N.B. Explicitly control hgjavacomponent visibility for backwards
            % compatibility
            if (idx~=obj.SelectedIndex || (nargin==3 && flag==true)) && obj.isValidTab(idx)
                previousComponent=obj.getSelectedComponent();
                obj.SelectedIndex=idx;
                if ~isAnimated(obj)
                    h=[obj.Components{:}];
                    h=h(h~=obj.Components{idx});
                    set(h, 'Visible', 'off');
                    % N.B. Need this to deal with hgjavacomponents 
                    % explicitly for some MATLAB versions.
                    h=findall(h, 'Type', 'hgjavacomponent');
                    if ~isempty(h)
                        set(h, 'Visible', 'off');
                    end
                    set(obj.Components{idx}, 'Visible', 'on');
                    h=findall(obj.Components{idx}, 'Type', 'hgjavacomponent');
                    if ~isempty(h)
                        set(h, 'Visible', 'on');
                    end
                    drawnow();
                else
                    GTool.Switch(previousComponent, obj.Components{idx});
                    h=[obj.Components{:}];
                    h=h(h~=obj.Components{idx});
                    set(h, 'Visible', 'off');
                    h=findall(h, 'Type', 'hgjavacomponent');
                    if ~isempty(h)
                        set(h, 'Visible', 'off');
                    end
                    set(obj.Components{idx}, 'Visible', 'on');
                    h=findall(obj.Components{idx}, 'Type', 'hgjavacomponent');
                    if ~isempty(h)
                        set(h, 'Visible', 'on');
                    end
                end
                uistack(obj.Components{idx}, 'top');
            elseif idx>obj.getTabCount() && idx~=obj.getSelectedIndex()
                obj.setSelectedIndex(obj.getTabCount());
            end
            return
        end
        
        function comp=insertTab(obj, comp, idx)
            if get(comp, 'Parent')~=obj.Parent
                comp=copyobj(comp, obj.Parent);
            end
            if nargin<3
                idx=numel(obj.Components)+1;
            end
            obj.Components{idx}=comp;
            obj.setSelectedIndex(idx, true);
            return
        end
        
    end
end




