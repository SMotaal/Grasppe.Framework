classdef GBasicHotSpot < GTool
    % GBasicHotSpot class provides the basic mechanisms for
    % flyout/popup toolbars and graphics in a MATLAB figure
    %
    % ---------------------------------------------------------------------
    % NOTE: This code uses MouseMotionHandler. You must be using this to
    % manage the WindowButtonMotionFcn functionality of your figure to use 
    % GBasicHotPanel
    % ---------------------------------------------------------------------
    %
    % Example:
    %       obj=GBasicHotSpot(hFig, area)
    %           hFig is a MATLAB figure handle
    %           area is a 4 element position vector [x y w h] describing
    %           the 'hot" area of your figure
    %       then
    %       obj.setLinkedList([mylist]);
    %           where mylist is a vector of MATLAB HG object handles.
    %
    %       When the mouse enters the rectangle [x y w h] the objects in
    %       mylist will be set visible, when it leaves they will be set
    %       invisible. This can be used to create flyout sidebars etc. -
    %       see GSideBar.
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    % 
    % Author: Malcolm Lidierth 12/10
    % Copyright The Author & King's College London 2011-
    % --------------------------------------------------------------------- 
    
    properties (SetAccess=private, GetAccess=public)
        LinkedObjectList;
        Parent=[];
    end
    
    properties (Access=protected)
        Rectangle;
        Position;
        Type='GBasicHotSpot';
    end
    
    methods
        
        function obj=GBasicHotSpot(target, area)
            obj.Parent=target;
            obj.Position=area;
            obj.Rectangle=annotation(target, 'rectangle', obj.Position, 'Color', 'none');
            if isappdata(target, 'MouseMotionHandlerObject')
                h=getappdata(target, 'MouseMotionHandlerObject');
            else
                h=MouseMotionHandler(target);
            end
            h.add(obj.Rectangle, {@GBasicHotSpotCallback, 'on'});
            h.addExit(obj.Rectangle, {@GBasicHotSpotCallback, 'off'});
            return
        end
        
        function setLinkedObjectList(obj, list)
            obj.LinkedObjectList=list;
            set(obj.Rectangle, 'UserData', list);
            return
        end
        
        function list=getLinkedObjectList(obj)
            list=obj.LinkedObjectList;
            return
        end
        
        
    end
end



% CALLBACKS
function GBasicHotSpotCallback(hObj, Eventdata, state)
list=get(hObj, 'UserData');
if ~isempty(list)
    set(list, 'Visible', state);
end
for k=1:numel(list)
    h=get(list(k), 'Children');
    if ~isempty(h)
        set(h, 'Visible',state);
    end
end
return
end







