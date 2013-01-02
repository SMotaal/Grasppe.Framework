classdef GSplitPaneDivider < GBasicDivider
    %     GSplitPaneDivider class
    %
    %     Example:
    %         sp=GSplitPaneDivider(parent, orientation)
    %             divides a MATLAB container (parent) into two parts.
    %             orientation is a string which determines whether the division
    %             is 'vertical' or 'horizontal'.
    %             parent can be any container that is valid as input
    %             to the javacomponent.m function and can parent a uipanel
    %
    %      When the divider is moved, all graphics objects in the parent
    %      will resize automatically if isAnimated is true.
    %      The divider can be moved on screen using the mouse or its position
    %      can be set programatically using the setProportion method (see below).
    %
    %      The GSplitPaneDivider constructor leaves the two divisons of the parent
    %      empty. To associate these with a MATLAB container use
    %                       sp.setComponent(index, container);
    %               index = 1 for left or lower and 2 for right or upper
    %               containers
    %      The container can be any MATLAB HG object with a Position or
    %      OuterPosition property.
    %      Typically GSplitPaneDividers will be created by a call to another
    %      class, e.g. GSplitPane which contains calls to setComponent which do
    %      this for you. For typical usage, see the help for GSplitPane.
    %
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 07/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties (Access=public)
        moveL;
        moveR;
    end
    
    methods
        
        function divider=GSplitPaneDivider(target, orient)
            % GSplitPaneDivider constructor
            p=GTool.getDefault('Divider.SplitPaneContainer');
            divider=divider@GBasicDivider(target, orient);
            divider.Object=jcontrol(target, p, 'Position', [0 0 1 1], 'Tag', 'GSplitPaneDivider');
            divider.Object.setBorder(GTool.getDefault('Divider.Border'));
            divider.Object.setBackground(GTool.getDefault('Divider.Fill'));
            layout=javax.swing.SpringLayout();
            divider.Object.setLayout(layout);
            label=javax.swing.JLabel();
            divider.Object.add(label);
            switch lower(orient)
                case {'vertical', 'v', 'vert'}
                    if strfind(class(divider.Object.hgcontrol), 'GJGradientPanel')
                        divider.Object.setAnchor(javax.swing.SwingConstants.WEST)
                    end
                    divider.Object.Position(3)=divider.Width;
                    set(divider.Object, 'Units', 'normalized');
                    divider.Object.Position(1)=0.5;
                    divider.Orientation='vertical';
                    layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, label, 0,...
                        javax.swing.SpringLayout.VERTICAL_CENTER, divider.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER, label, 0,...
                        javax.swing.SpringLayout.HORIZONTAL_CENTER, divider.Object.hgcontrol);
                    label.setText(GTool.getDefault('Divider.SplitPaneVerticalText'));
                    
                    lb=javax.swing.JButton(GTool.getDefault('Icon.MOVELEFT'));
                    lb.setPreferredSize(java.awt.Dimension(7,20));
                    lb.setContentAreaFilled(false);
                    lb.setBorder(javax.swing.border.EmptyBorder(1,1,1,1));
                    %                     lb.setBackground(GTool.getDefault('Divider.Fill'));
                    divider.Object.add(lb);
                    layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER, lb, 0,...
                        javax.swing.SpringLayout.HORIZONTAL_CENTER, divider.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.NORTH, lb, 10,...
                        javax.swing.SpringLayout.NORTH, divider.Object.hgcontrol);
                    divider.moveL=handle(lb, 'callbackproperties');
                    
                    rb=javax.swing.JButton(GTool.getDefault('Icon.MOVERIGHT'));
                    rb.setPreferredSize(java.awt.Dimension(7,20));
                    rb.setContentAreaFilled(false);
                    rb.setBorder(javax.swing.border.EmptyBorder(1,1,1,1))
                    %                     rb.setBackground(GTool.getDefault('Divider.Fill'));
                    divider.Object.add(rb);
                    layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER, rb, 0,...
                        javax.swing.SpringLayout.HORIZONTAL_CENTER, divider.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.NORTH, rb, 30,...
                        javax.swing.SpringLayout.NORTH, divider.Object.hgcontrol);
                    divider.moveR=handle(rb, 'callbackproperties');
                    
                case {'horizontal', 'h', 'hor'}
                    % default to horizontal
                    if strfind(class(divider.Object.hgcontrol), 'GJGradientPanel')
                        divider.Object.setAnchor(javax.swing.SwingConstants.NORTH)
                    end
                    divider.Object.Position(4)=divider.Width;
                    set(divider.Object, 'Units', 'normalized');
                    divider.Object.Position(2)=0.5;
                    divider.Orientation='horizontal';
                    layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, label, -2,...
                        javax.swing.SpringLayout.VERTICAL_CENTER, divider.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER, label, 0,...
                        javax.swing.SpringLayout.HORIZONTAL_CENTER, divider.Object.hgcontrol);
                    label.setText(GTool.getDefault('Divider.SplitPaneHorizontalText'));
                    
                    lb=javax.swing.JButton(GTool.getDefault('Icon.MOVEUP'));
                    lb.setPreferredSize(java.awt.Dimension(7,20));
                    lb.setContentAreaFilled(false);
                    lb.setBorder(javax.swing.border.EmptyBorder(1,1,1,1));
                    %                      lb.setBackground(GTool.getDefault('Divider.Fill'));
                    divider.Object.add(lb);
                    layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, lb, -1,...
                        javax.swing.SpringLayout.VERTICAL_CENTER, divider.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.EAST, lb, -10,...
                        javax.swing.SpringLayout.EAST, divider.Object.hgcontrol);
                    divider.moveL=handle(lb, 'callbackproperties');
                    
                    rb=javax.swing.JButton(GTool.getDefault('Icon.MOVEDOWN'));
                    rb.setPreferredSize(java.awt.Dimension(7,20));
                    rb.setContentAreaFilled(false);
                    rb.setBorder(javax.swing.border.EmptyBorder(1,1,1,1));
                    %                     rb.setBackground(GTool.getDefault('Divider.Fill'));
                    divider.Object.add(rb);
                    layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, rb, -1,...
                        javax.swing.SpringLayout.VERTICAL_CENTER, divider.Object.hgcontrol);
                    layout.putConstraint(javax.swing.SpringLayout.EAST, rb, -30,...
                        javax.swing.SpringLayout.EAST, divider.Object.hgcontrol);
                    divider.moveR=handle(rb, 'callbackproperties');
                otherwise
                    error('GSplitPaneDivider.orientation: Unsupported orientation %s', orient);
            end
            % Set up callbacks for mouse control
            divider.installCallbacks();
            return
        end
        
        
        function setAnimated(obj,flag)
            obj.Animated=flag;
            return
        end
        
        function flag=isAnimated(obj)
            flag=obj.Animated;
            return
        end
    end
end


