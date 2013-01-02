classdef GBasicDivider < GTool
    %     GBasicDivider is the workhorse class for GSplitPane type
    %     subclasses
    %
    %     Example:
    %         sp=GBasicDivider(parent, orientation)
    %             divides a MATLAB container (parent) into two parts.
    %             Orientation is a string which determines whether the
    %             divider is 'vertical' or 'horizontal'*. 
    %             The parent can be any container that is valid as input
    %             to the javacomponent.m function and can parent a uipanel.
    % 
    %             *Unlike in Swing, division is defined by the orientation
    %              of the divider rather than the split in the container.
    %              A vertical divider splits the container left to right
    %              - a horizontal divider splits top and bottom.
    %             
    %      The divider can be moved on screen using the mouse or its
    %      position can be set programatically using the setProportion
    %      method (see below).
    %                       
    %      The GBasicDivider constructor leaves the two divisons of the parent
    %      empty. To associate these with a MATLAB component use
    %                       sp.setComponent(index, container);
    %               index = 1 for left or lower and 2 for right or upper
    %               containers
    %      The component can be any MATLAB HG object with a Position or
    %      OuterPosition property (e.g. uipanels, axes etc).
    %      Typically GBasicDividers will be created by a call to another
    %      class, e.g. GSplitPane which contains calls to setComponent which do
    %      this for you. For typical usage, see the help for GSplitPane.
    %
    %
    %      GBasicDivider Methods provide the ability to customize the 
    %      appearance of the divider to your application e.g.:
    %
    %      Appearance:
    %             getFill/setFill
    %                     gets/sets the color of the divider. The color is a
    %                     Java color object e.g. java.awt.Color(0,1,0), or a set
    %                     of RGB values. Alpha values are supported e.g.
    %                               sp.setFill(0,0,1,0.5);
    %                               sp.setFill(java.awt.Color(0,0,0,0.5);
    %                     [Alpha values<1 are not properly supported in MATLAB
    %                     on all platforms e.g. Windows.
    %             getBorder/setBorder
    %                       gets/sets the border for the divider. The border is
    %                       a Java border object
    %                               sp.setBorder(javax.swing.border.LineBorder(java.awt.Color(0,0,1));
    %             getWidth/setWidth
    %                       gets/sets the divider width (in centimeters). The
    %                       default is 0.275cm.
    %                               sp.setWidth(0.5);
    %
    %      Control:
    %             getProportion/setProportion
    %                    Sets the position of the divider in its parent
    %                               sp.setProportion(Proportion);
    %                    where Proportion is the proportion of the parent to be allocated to the
    %                    left or lower division of the parent (for vertical and horizontal
    %                    dividers respectively), e.g. sp1.setProportion(0.25) allocates 1/4 of the
    %                    parent to the left or lower division.
    %
    %              setLock/isLocked
    %                    Sets or gets a flag that controls whether the
    %                    divider can be moved by the mouse (true) or not (false).
    %
    %      Destructor:
    %             delete    cleanly deletes a GBasicDivider object;
    %                       This method will be called automatically when you
    %                       close a figure associated with any GBasicDivider
    %                       instance.
    %
    % Notes
    %   Application Data Area
    %       Variables  added to the application data area of the parent
    %       on construction:
    %           hasGBasicDivider     set to true
    %
    %     Dependencies:
    %         Requires Project Waterloo jcontrol, MUtilities and isMultipleCall
    %         These are available on the FEX or as a package at
    %                   http://sourceforge.net/projects/waterloo/
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 07/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties
        Orientation='horizontal';
        Parent=[];
        Tag='';
        Type='GBasicDivider';
        Components=cell(1,2);
        Width=GTool.getDefault('Divider.Width');
        LockFlag=false;
        Animated=GTool.getDefault('Divider.Animated');
    end
    
    properties(SetAccess=protected, GetAccess=public)
        Created=now();
        ProgrammedProportion;
    end
    
    
    methods
        
        function divider=GBasicDivider(target, orient)
            % GBasicDivider constructor
            if isappdata(target, 'hasGBasicDivider')
                warning('GBasicDivider:hasGBasicDivider', 'Only one GBasicDivider can be added to a MATLAB container');
                divider=[];
                return
            end
            divider.Parent=target;
            % Create the divider
            if nargin>=2 && strcmpi(orient,'horizontal')
                divider.Orientation=orient;
            end
            % Tag the parent
            setappdata(target, 'hasGBasicDivider', true);
            divider.onCleanup();
            return
        end
        
        function val=getParent(divider)
            % getParent method
            val=divider.Parent;
            return
        end
        
        function ancestor(divider, type, str)
            % ancestor method - acts on the hgcontainer
            if nargin<3
               ancestor(divider.Object.hgcontainer, type)
            else
                ancestor(divider.Object.hgcontainer, type, str);
            end
            return
        end
        
        function position=getPosition(divider)
            % getPosition returns the MATLAB position vector for the
            % GBasicDivider object
            position=divider.Object.Position;
            return
        end
        
        function setPosition(divider, position)
            % setPosition sets the MATLAB position vector for the
            % GBasicDivider object
            if divider.LockFlag==true;return;end
            if numel(position)==4
                divider.Object.Position=position;
            else
                error('GBasicDivider:Position', '4 element position vector required');
            end
            return
        end
        
        function Proportion=getProportion(divider)
            % getProportion returns the relative location of the GBasicDivider
            % in the parent container.
            switch divider.Orientation
                case 'vertical'
                    Proportion=divider.Object.Position(1);
                case 'horizontal'
                    Proportion=divider.Object.Position(2);
            end
            return
        end
        
        function setProportion(divider, Proportion)
            % getProportion sets the relative location of the GBasicDivider
            % in the parent container. A Proportion of 0.25 will allocate 1/4
            % of the container to the first compartment and 3/4 to the
            % second
            if divider.LockFlag==true;return;end
            switch divider.Orientation
                case 'vertical'
                    divider.Object.Position(1)=Proportion;
                case 'horizontal'
                    divider.Object.Position(2)=Proportion;
            end
            update(divider);
            divider.ProgrammedProportion=Proportion;
            %drawnow();
            return
        end
        
        function fill=getFill(divider)
            % getFill returns the fill color for the divider. 
            fill=divider.Object.getBackground();
            return
        end
        
        function setFill(divider, varargin)
            % setFill sets the fill color for the divider
            % Example:
            %   obj.setFill(Java color object)
            %   obj.setFill(R,G,B)
            %   obj.setFill(R,G,B, Alpha)
            if nargin>=3
                divider.Object.setBackground(java.awt.Color(varargin{:}));
            else
                divider.Object.setBackground(varargin{1});
            end
            return
        end
        
        function border=getBorder(divider)
            % getBorder returns the Java border object for the divider
            border=divider.Object.Border;
            return
        end
        
        function setBorder(divider, border)
            % setBorder sets the Java border object for the divider
            % Example:
            % obj.setBorder(Java border object)
            divider.Object.setBorder(border);
            divider.Object.setForeground(border.getLineColor());
            return
        end
           
        function setComponent(divider, index, component)
            % setComponent sets the MATLAB container, for the specified
            % division of the divider
            % Example:
            % obj.setComponent(index, component)
            %   where index is 1 = left or lower divison
            %                  2 = right or upper division
            if index>0 && index<3
                divider.Components{index}=component;
            else
            end
            update(divider);
            return
        end
        
        function width=getWidth(divider)
            % getWidth returns the width of the divider in cm
            width=divider.Width;
            return
        end
        
        function setWidth(divider, width)
            % setWidth sets the width of the divider in cm
            divider.Width=width;
            divider.restoreWidth();
            divider.update();
            return
        end
        
        function setLock(divider, flag)
            % setLock locks/unlocks the divider
            % A locked divide can not be moved with the mouse or
            % programatically via setProportion
            divider.LockFlag=flag;
            switch flag
                case true
                    divider.removeCallbacks();
                    divider.Object.getComponent(0).setText(GTool.getDefault('Divider.LockedText'));
                case false
                    divider.installCallbacks();
                    switch divider.Orientation
                        case 'vertical'
                            divider.Object.getComponent(0).setText(GTool.getDefault('Divider.VerticalText'));
                        case 'horizontal'
                            divider.Object.getComponent(0).setText(GTool.getDefault('Divider.HorizontalText'));
                    end
            end
            return
        end
        
        function flag=isLocked(divider)
            % isLoaked returns the lcok status
            flag=divider.LockFlag;
            return
        end
        
        function setAnimated(flag)
            % Animates the drag if flag is true
            divider.Animated=logical(flag);
            return
        end
        
        function flag=isAnimated(divider)
            % Returns the animation state
            flag=divider.Animated;
            return
        end
        
        function restoreWidth(divider)
            % restoreWidth restores the width of the divider when the
            % parent is resized
            pos=gc_getpixelposition(divider.Object.hgcontainer);
            switch divider.Orientation
                case 'vertical'
                    pos(3)=divider.Width*java.awt.Toolkit.getDefaultToolkit().getScreenResolution()/2.54;
                case 'horizontal'
                    pos(4)=divider.Width*java.awt.Toolkit.getDefaultToolkit().getScreenResolution()/2.54;
            end
            setpixelposition(divider.Object.hgcontainer, pos);
            return
        end
        
        function update(divider)
            % update refreshes the parent e.g. when it is resized
            divider.restoreWidth();
            divpos=gc_getpixelposition(divider.Object.hgcontainer);
            ppos=gc_getpixelposition(get(divider.Object,'Parent'));
            compunits1=[];
            compunits2=[];
            switch divider.Orientation
                case 'vertical'
                    component1=getComponent(divider, 1);
                    if ~isempty(component1)
                        if isprop(component1, 'OuterPosition')
                            compunits1=get(component1, 'Units');
                            set(component1, 'Units', 'pixels', 'OuterPosition', [1 1 max(1,divpos(1)-1) max(1,ppos(4))]);
                        else
                            %set(component1, 'Position', [0 0 divider.getProportion() 1]);
                            gc_setpixelposition(component1, [1 1 max(1,divpos(1)-1) max(1,ppos(4))]);
                        end
                    end
                    component2=getComponent(divider, 2);
                    if ~isempty(component2)
                        compunits2=get(component2, 'Units');
                        if isprop(component2, 'OuterPosition')
                            set(component2, 'Units', 'pixels', 'OuterPosition',...
                                [divpos(1)+divpos(3)-1 1 max(1,ppos(3)-divpos(3)-divpos(1)+2) max(1,ppos(4))]);
                        else
                            gc_setpixelposition(component2, [divpos(1)+divpos(3) 1 max(1,ppos(3)-divpos(3)-divpos(1)+1) max(1,ppos(4))]);
                        end
                    end
                case 'horizontal'
                    component1=getComponent(divider, 1);
                    if ~isempty(component1)
                        if isprop(component1, 'OuterPosition')
                            compunits1=get(component1, 'Units');
                            set(component1, 'Units', 'pixels', 'OuterPosition',...
                                round([1 divpos(2)+divpos(4)-1 max(1,ppos(3)+1) max(1,ppos(4)-divpos(4)-divpos(2)+3)]));
                            set(component1, 'Units', compunits1);
                        else
                            gc_setpixelposition(component1, [1 divpos(2)+divpos(4)+1 max(1,ppos(3)-1) max(1,ppos(4)-divpos(4)-divpos(2))]);
                        end
                        
                    end
                    component2=getComponent(divider, 2);
                    if ~isempty(component2)
                        if isprop(component2, 'OuterPosition')
                            compunits2=get(component2, 'Units');
                            set(component2, 'Units', 'pixels', 'OuterPosition', [1 1 max(1,ppos(3)) max(1,divpos(2))]);
                            set(component2, 'Units', compunits2);
                        else
                            %set(component2, 'Position', [0 0 1 divider.getProportion()]);
                            gc_setpixelposition(component2, [1 1 max(1,ppos(3)) max(1,divpos(2))]);
                        end
                    end
            end
            if ~isempty(compunits1);set(component1, 'Units', compunits1);end
            if ~isempty(compunits2);set(component2, 'Units', compunits2);end
            %refresh(gcf);
            return
        end
        
        function installCallbacks(obj)
            set(obj.Object.hgcontrol, 'MouseEnteredCallback', {@MouseEnteredCallback, obj.Orientation});
            set(obj.Object.hgcontrol, 'MouseExitedCallback', @MouseExitedCallback);
            set(obj.Object.hgcontrol, 'MouseDraggedCallback', {@MouseDraggedCallback, obj});
%             set(obj.Object.hgcontrol, 'MousePressedCallback', {@MousePressedCallback, obj});
            set(obj.Object.hgcontrol, 'MouseReleasedCallback', {@MouseReleasedCallback, obj});
             set(obj.Object, 'ResizeFcn', {@DividerResize, obj});
            return
        end
        
        
    end
    
    methods(Static)
        
        % Programmable mouse drag
        function doMouseDrag(obj, hObject, EventData)
            MouseDraggedCallback(hObject, EventData, obj)
            return
        end
           
    end
end

% Mouse shape control
function MouseEnteredCallback(hObject, Eventdata, orientation)
switch orientation
    case 'horizontal'
        setptr(gcf, 'uddrag');
    case 'vertical'
        setptr(gcf, 'lrdrag');
end

return
end

function MouseExitedCallback(hObject, EventData)
setptr(gcf, 'arrow');
drawnow();
return
end

function MouseReleasedCallback(hObject, EventData, divider)
drawnow();
update(divider);
return
end

% Divider movement control
function MouseDraggedCallback(hObject, EventData, divider)
% Dismiss multiple events
if isMultipleCall();return;end
set(hObject, 'MouseDraggedCallback', []);
% Update divider location
pos=get(0, 'PointerLocation');
parent=get(hObject.hghandle, 'Parent');
pos=MUtilities.convertPosition(pos, 0, parent);
parentpos=gc_getpixelposition(parent);
cpos=hgconvertunits(ancestor(hObject.hghandle,'figure'),get(hObject.hghandle,'Position'),get(hObject.hghandle,'Units'),...
          'Pixels',parent);%gc_getpixelposition(hObject.hghandle);
switch divider.Orientation
    case 'horizontal'
        if pos(2)>10 && pos(2)<parentpos(4)-15
            cpos(2)=pos(2);
        end
    case 'vertical'
        if pos(1)>10 && pos(1)<parentpos(3)-15
            cpos(1)=pos(1);
        end
end
% Tidy up
gc_setpixelposition(hObject.hghandle,cpos);
if divider.Animated==true
    update(divider);
    %drawnow();%refresh(gcf);
end
set(hObject, 'MouseDraggedCallback', {@MouseDraggedCallback, divider})
return
end


function DividerResize(hObject, EventData, obj)
set(hObject, 'ResizeFcn', []);
obj.restoreWidth();
uistack(hObject, 'top');
set(hObject, 'ResizeFcn', {@DividerResize, obj});
return
end


