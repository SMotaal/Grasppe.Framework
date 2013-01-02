classdef GTaskPaneContainer < GTool
    % GTaskPaneContainer class
    % Example:
    % obj=GTaskPaneContainer(target, 'PropName1', 'PropValue1'.....)
    %
    % A GTaskPaneContainer is a container to which you can add collapsible
    % panels. Each added panel has a header with a title and button to allow
    % interactive collapsing/expansion. The GTaskPaneContainer has an
    % associated vertical JScrollPane that will appear as required.
    %
    % Add panels to the GTaskPaneContainer using the addTab methods, and
    % fill these with Swing components as required.
    %
    % [GTaskPaneContainer places a JXTaskPaneContainer in a JScrollpane
    % inside the target handle graphics container. This will typically be a
    % uipanel. The GTaskPaneContainer will fill the target uicontainer.
    % Add JXTaskPanes to the JXTaskPaneContainer using addTab, and fill
    % these with Swing components as required].
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 07/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties
        Components={};
        Parent=[];
        Type='GTaskPane';
    end
    
    methods
        
        function obj=GTaskPaneContainer(target, varargin)
            % GAccordion constructor
            % Example:
            % obj=GTaskPaneContainer(target, 'PropName1', 'PropValue1'.....)
            %
            % Places a JXTaskPaneContainer in a JScrollpane inside the
            % target handle graphics object.
            try
                tpane=org.jdesktop.swingx.JXTaskPaneContainer();
            catch
                error('GTaskPaneContainer requires the SwingLabs SwingX extensions - these need to be on your MATLAB path');
            end
            tpane.getLayout().setGap(2);
            tpane.setBorder(javax.swing.border.EmptyBorder(2,2,2,2));
            sc=javaObjectEDT('javax.swing.JScrollPane');
            sc.setViewportView(tpane);
            if ishghandle(target)
                obj.Object=jcontrol(target, sc, varargin{:}, 'Units', 'normalized', 'Position', [0 0 1 1]);
            else
                obj.Object=target.add(sc);
            end
            obj.Parent=target;
            return
        end
        
        function comp=addTab(obj, str)
            % addTab adds a JXTaskPane to the JXTaskPaneContainer
            % Example:
            % comp=addTab(title)
            % where title is a char array for the JXTaskPane's title.
            if nargin<1
                str='';
            end
            comp=javaObjectEDT(org.jdesktop.swingx.JXTaskPane(str));
            % comp.setSpecial(true);
            obj.Components{end+1}=obj.Object.getViewport().getComponent(0).add(comp);
            obj.Components{end}.setScrollOnExpand(true);
            obj.Components{end}.setCollapsed(true);
            drawnow();
            return
        end
        
    end
    
end


