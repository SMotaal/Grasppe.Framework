classdef MouseMotionHandler < handle
    %     MouseMotionHandler enables mouse motion callbacks on all HG object types
    %
    %     MouseMotionHandler provides an alternative to chaining callbacks
    %     or having a lengthy switch block in a WindowButtonMotionFcn
    %     callback to manage mouse motion effects. 
    %     MouseMotionHandler puts its own callback into a figure's
    %     WindowButtonMotionFcn property. This callback manages the servicing
    %     of callbacks for other objects in the figure. It actively 
    %     determines what is beneath the mouse then invokes a user-specified
    %     callback for that object, if one is set. Specify these objects 
    %     and their mouse motion callbacks using the MouseMotionHandler add
    %     and put methods as described below. 
    %
    %     All visible MATLAB HG objects can be handled including uipanels,
    %     uicontrols, lines, surface objects etc. 
    %
    %     For a simple demo that just alters the mouse pointer depending on
    %     what is beneath and sets rotate3d on and off in a context-dependent
    %     way, see the static demo method which can be run at the MATLAB
    %     prompt by calling:
    %                       >> MouseMotionHandler.demo();
    %
    %     -----------------------------------------------------------------
    %     Key points:
    %
    %     MouseMotionHandler add or put calls can be made at any point from
    %     your code, so if a function creates a new MATLAB object, the
    %     callbacks for that object can be set in the same function. You do
    %     not need to update separate button motion m-files for the figure
    %     - aiding code readability and easing maintainence.
    %
    %     MouseMotionHandler methods  discriminate between mouse entry,
    %     movement within, and exit from an object
    %
    %     You can add callbacks specific to an object, or groups of objects,
    %     specified by their HG handles, Tags or Types.
    %
    %     MouseMotionHandler has no affect on other callbacks (e.g.
    %     ButtonDownFcn) or on the use of MouseEntered or MouseExited callbacks
    %     on Java objects. These can be set in parallel with a MouseMotionHandler.
    %
    %     MouseMotionHandler works alongside the standard MATLAB
    %     FigureToolManager. You can pan/zoom/rotate graphics as usual.
    %
    %     The handle passed as input to user-specified callbacks will be
    %     that of the object below the mouse. EventData will be passed
    %     unchanged to the user-callback (it's presently always empty for
    %     window button motion callbacks anyway - R2010b).
    %     -----------------------------------------------------------------
    %
    %     Example
    %     obj=MouseMotionHandler(hFig);
    %     obj=MouseMotionHandler(hFig, string);
    %     obj=MouseMotionHandler(hFig, @fcn);
    %     obj=MouseMotionHandler(hFig, {@fcn, arg1, arg2,...});
    %     
    %     These initialise a mouse motion handler for the figure with handle hFig.
    %     The remaining optional arguments are those that you might place in the
    %     figure's WindowButtonMotionFcn property:
    %             [1] a string that will be evaluated when the mouse moves within
    %                 the figure
    %             [2] a function handle. The function will be called with the
    %                   standard MATLAB syntax, i.e. Callback(hObject, Eventdata)
    %             [3] A cell array with a function handle in element 1 and
    %                 optional arguments in elements 2 onward. The callback will
    %                 be called as Callback(hObject, Eventdata, arg1, arg2,....)
    %
    %     There is no requirement to set a callback for the figure.
    %     Callbacks may still be set for child objects of the figure after
    %     the all to MouseMotionHandler.
    %
    %     The mouse motion handler effectively extends WindowButtonMotionFcn
    %     functionality to all HG components that are children of hFig.
    %     Add callbacks related to an object by calling:
    %                   obj.add(hObj, details);                  
    %     or using the equivalent static method
    %                   MouseMotionHandler.put(hFig, objecthandle, details);                  
    %     Here, hFig is the figure handle as before and 'details' is the string,
    %     function handle or cell array detailing the callback as above.
    %     hObj is the handle, or a vector of handles, for the HG object(s)
    %     you want to target.
    %     Alternatively, set callbacks for groups of objects using their Tag
    %     or Type properties.
    %               obj.add(string, details);
    %               MouseMotionHandler.put(hFig, string, details);
    %     Thus
    %                   obj.add(hObj, {@MyFunction, arg1, arg2});
    %     invokes MyFunction when the mouse moves over hObj while
    %                   obj.add('line', {@MyFunction, arg1, arg2, arg3});
    %     invokes MyFunction when the mouse moves over any line in the parent
    %     figure. Note, that when setting the callbacks by Tag or Type, the
    %     objects need not exist at the time of the add or put call.
    %
    %     When processing objects, the MouseMotionHandler first checks to see
    %     if a callback is set for the specific object by its handle. If not,
    %     it checks against the Tag and, if that fails against, the Type.
    %     If no callback is set by any criterion, the MouseMotionHandler
    %     invokes its DefaultAction (if set), as described below.
    %
    %     Exit callbacks
    %     The callbacks above are called when the mouse enters or is moved
    %     over an object. You can also set a callback that will be run once
    %     when the mouse exits an object. These callbacks follow the same syntax
    %     as above and are added using addExit or putExit, e.g.
    %                   obj.add(hObj, {@MyFunction, arg1, arg2});
    %                   MouseMotionHandler.putExit(hFig, string, details);
    %     NOTE: add/put must be called before addExit/putExit. If a
    %     callback is replaced using add/put, the corresponding exit
    %     callback will be set to empty and must be re-registered by calling
    %     addExit/putExit again.
    %
    %     Mouse Entered, Moved and Exited functionality
    %     You can discriminate mouse entered, mouse moved and mouse exited
    %     calls by calling the MouseMotionHandler isMoved method.
    %     In a main callback (set by add or put) obj.isMoved returns true
    %     if the mouse has moved within an object and false if the mouse 
    %     has entered the object.
    %     In an exit callback (set by addExit ot PutExit) isMoved always
    %     returns false (as expected).
    %               
    %     DefaultAction property
    %     If the mouse is moved but is not over an object for which you have
    %     set up a callback, the DefaultAction will be executed. Set or leave this
    %     empty to have no default action. Examples:
    %               obj.setDefaultAction('setptr(''arrow'')');
    %     or using the static equivalent
    %     MouseMotionHandler.putDefaultAction(hFig, {@MyFunction, arg1, arg2,..);
    %
    %     In general, there will be no need to remove entries from the motion
    %     handle object. To replace a callback, simply call the add/put or 
    %     addExit/pullExit method again.
    %     Entries for invalid handles, e.g. of deleted objects in a figure,
    %     can safely be left alone as their callbacks will never be invoked. To
    %     explicitly remove an entry, call
    %                   obj.remove(objecthandle);
    %                   obj.remove(string);
    %     or the static equivalent
    %                   MouseMotionHandler.pull(hFig, objecthandle or string);
    %                   
    %     To delete the MouseMotionHandler for a figure, use the static erase
    %     method:
    %                   MouseMotionHandler.erase(hFig);
    %
    %     If a figure becomes detached from its MouseMotionHandler, 
    %     e.g. because other code has stolen the WindowButtonMotionFcn,
    %     restore the MouseMotionHandler functionality by calling
    %                   MouseMotionHandler.restore(hFig);
    %
    %     Accessing the MouseMotionHandler
    %     There can be only one MouseMotionHandler object per figure. Check
    %     to see if one is present using
    %            isappdata(hFig, 'MouseMotionHandlerObject');
    %     Access it using
    %            handle=getappdata(hFig, 'MouseMotionHandlerObject');
    %     The static method MouseMotionHandler.getHandler(hFig) can be used
    %     if preferred.
    %
    %     MouseMotionHandler objects are handle objects and are passed by
    %     reference. Changes made to any copy affect all copies including
    %     that in the application data area. 
    %
    %     
    % --------------------------------------------------------------------------
    %
    % Author: Malcolm Lidierth
    % Copyright 2010- The Author and King's College London
    %
    % This code was developed as part of Project Waterloo, which
    % itself is part of the sigTOOL project at King's College London.
    %
    %                   http://sigtool.sourceforge.net/
    % --------------------------------------------------------------------------
    
    
    % 
    %     Notes:
    %         [1] Object handles are converted to key strings using num2str
    %             in an internal hashtable. These keys can not reliably be
    %             converted back to handles due to rounding. 
    %
    %         [2] The static method MouseMotionHandle.FigureCallback is the
    %             callback placed in the WindowButtonMotionFcn property of the
    %             parent figure and coordinates calls to all other
    %             callbacks.
    %
    %         [3] A copy of the MouseMotionHandler object is placed in the
    %             parent figure application data area for use by the static
    %             methods (labeled 'MouseMotionHandlerObject')
    %
    %         [4] Normally, the handler calls hittest to determine the object that is
    %             immediately beneath the mouse. The handle returned may, but in
    %             general will not, be the current object, current axes or
    %             current figure. The gcbo function will always return the
    %             figure handle (because as far as MATLAB is concerned we are
    %             servicing the figure WindowButtonMotionFcn only);
    %             Use the first argument to your callbacks to determine
    %             the object that the mouse is over. This is set to
    %             hittest().
    %
    %         [5] setting the findVisibleOnly flag to false switches the
    %             algorithm used to find objects beneath the cursor.
    %             Instead of hittest(), this uses the MUtilities.findBelow
    %             method (from the FEX). Only objects with a 'Position'
    %             property will be found (e.g.lines will be excluded) but
    %             uipanels, axes etc will be found even if their Visible 
    %             property is set to 'off'.
    %
    %         [6] Much the same behaviour can be accomplished more easily by
    %             using a parent panel with its background set to none and no
    %             border. Use this to parent another panel with its
    %             'Visible' property set to off then have the parent's
    %             callback turn the Visible property of the child to on.
    %.
    %         [7] The static method erase destroys the MouseMotionHandler
    %             globally (it is a handle object).
    %             The static method restore, restores the WindowButtonMotionFcn
    %             for a valid MouseMotionHandler - not one that has been
    %             erased.
    %
    %         [8] Some MATLAB GUIs protect the WindowButtonMotionFcn.
    %             In those cases MouseMotionHandler will not work (at least,
    %             not without some hacking).
    %
    %         [9] Callbacks are activated by mouse movement in the parent
    %             figure. Mouse exit callbacks and the DefaultAction may not
    %             get called if you move the mouse rapidly to another
    %             figure.
    % 
    %        [10] Working with MATLAB's FigureToolManager. The MouseMotionHandler
    %             callback handler checks the uitools.uimodemanager current
    %             mode and, if it is set, returns cleanly without running any
    %             main callbacks.However, if a MouseMotionHandler exit callback
    %             is queued, that will be executed.
    %
    %     This handler is useful for MATLAB objects and graphics which do
    %     not expose button motion callbacks, i.e everything but figures.
    %     For Java objects, it will generally be better to use the underlying
    %     object mouse callbacks.
    
    % Revisions:
    %   11.01.2010  Fix reference to 'f' in demo
    %   15.01.2010  Fix for call==function_handle when not in cell array
    
    properties (SetAccess=private, GetAccess=public)
        ObjectList;
        Args;
        exitArgs;
        DefaultAction;
        Type='MouseMotionHandler';
        Parent;
    end
    
    properties (Access=private)
        findVisibleOnly=true;% see Note [5] above
        currentObject;
        previousObject;
        previousIDX;
    end
    
    
    methods
        
        function obj=MouseMotionHandler(hFig, varargin)
            % Constructor
            % Initialise properties
            if isprop(hFig, 'WindowButtonMotionFcn')
                obj.Parent=hFig;
                obj.ObjectList=java.util.Hashtable();
                obj.Args={};
                if nargin>1
                    obj.add(hFig, varargin{:})
                end
                % Set up the main callback
                set(hFig, 'WindowButtonMotionFcn', {@MouseMotionHandler.FigureCallback, obj});
                setappdata(hFig, 'MouseMotionHandlerObject', obj);
            else
                error('MouseMotionHandler:noWindowButtonMotionFcn', 'Parent object must have a WindowButtonMotionFcn property');
            end
            return
        end
        
        function add(obj, focus_subject, call)
            % Add handle, Tag or Type
            if isnumeric(focus_subject) && ~isscalar(focus_subject)
                for k=1:numel(focus_subject)
                    obj.add(focus_subject(k), call);
                end
                return
            end
            if ishandle(focus_subject)
                focus_subject=num2str(focus_subject);
            end
            obj.Args{end+1}=call;
            obj.exitArgs{numel(obj.Args)}=[];
            obj.ObjectList.put(focus_subject, numel(obj.Args));
            return
        end
        
        function addExit(obj, focus_subject, call)
            % Add mouse exit callback
            if isnumeric(focus_subject) && ~isscalar(focus_subject)
                for k=1:numel(focus_subject)
                    obj.addExit(focus_subject(k), call);
                end
                return
            end
            if ishandle(focus_subject)
                focus_subject=num2str(focus_subject);
            end
            idx=obj.ObjectList.get(focus_subject);
            obj.exitArgs{idx}=call;
            return
        end
        
        function remove(obj, focus_subject)
            % Remove handle, Tag or Type
            if isnumeric(focus_subject) && ~isscalar(focus_subject)
                for k=1:numel(focus_subject)
                    obj.remove(focus_subject(k));
                end
                return
            end
            if ishandle(focus_subject)
                focus_subject=num2str(focus_subject);
            end
            idx=obj.ObjectList.get(focus_subject);
            if ~isempty(idx)
                obj.Args{idx}=[];
                obj.exitArgs{idx}=[];
                obj.ObjectList.remove(focus_subject);
            end
            return
        end
        
        function flag=isMoved(obj)
            % isMoved returns false for mouse entered and exited, and
            % true for mouse moved within an object
            if obj.previousObject==obj.currentObject
                flag=true;
            else
                flag=false;
            end
            return
        end
        
        function setFindVisibleOnly(obj, flag)
            % See Note [5] in above
            switch isempty(which('MUtil.m'))
                case true
                    warning('MouseMotionHandler:findVisibleOnly', 'Can not change findVisibleOnly flag - no MUtilities installed.')
                case false
                   obj.findVisibleOnly=flag;
            end
            return
        end
        
        function flag=getFindVisibleOnly(obj)
            flag=obj.findVisibleOnly;
            return
        end
        
        function setDefaultAction(obj, call)
            obj.DefaultAction=call;
            return
        end
        
    end
    
    
    methods (Static)
        
        % Static methods. Call as MouseMotionHandler.staticMethodName
        
        function obj=getHandler(hFig)
            % Get the handler
            if isappdata(hFig, 'MouseMotionHandlerObject');
                obj=getappdata(hFig, 'MouseMotionHandlerObject');
            else
                obj=[];
            end
            return
        end
            
        
        function put(hFig, focus_subject, call)
            % Static add method
            obj=getappdata(hFig, 'MouseMotionHandlerObject');
            if isnumeric(focus_subject) && ~isscalar(focus_subject)
                for k=1:numel(focus_subject)
                    obj.add(focus_subject(k), call);
                end
                return
            end
            if ishandle(focus_subject)
                focus_subject=num2str(focus_subject);
            end
            obj.Args{end+1}=call;
            obj.exitArgs{numel(obj.Args)}=[];
            obj.ObjectList.put(focus_subject, numel(obj.Args));
            return
        end
        
        function putExit(hFig, focus_subject, call)
            % Static addExit method
            obj=getappdata(hFig, 'MouseMotionHandlerObject');
            if isnumeric(focus_subject) && ~isscalar(focus_subject)
                for k=1:numel(focus_subject)
                    obj.addExit(focus_subject(k), call);
                end
                return
            end
            if ishandle(focus_subject)
                focus_subject=num2str(focus_subject);
            end
            idx=obj.ObjectList.get(focus_subject);
            obj.exitArgs{idx}=call;
            return
        end
        
        function pull(hFig, focus_subject)
            % Static remove method
            obj=getappdata(hFig, 'MouseMotionHandlerObject');
            if isnumeric(focus_subject) && ~isscalar(focus_subject)
                for k=1:numel(focus_subject)
                    obj.add(focus_subject(k), call);
                end
                return
            end
            if ishandle(focus_subject)
                focus_subject=num2str(focus_subject);
            end
            obj=getappdata(hFig, 'MouseMotionHandlerObject');
            idx=obj.ObjectList.get(num2str(focus_subject));
            if ~isempty(idx)
                obj.Args{idx}=[];
                obj.exitArgs{idx}=[];
                obj.ObjectList.remove(focus_subject);
            end
            return
        end
        
        function putDefaultAction(hFig, call)
            % DefaultAction invoked when mouse not over an object that has
            % a pre-defined action
            obj=getappdata(hFig, 'MouseMotionHandlerObject');
            obj.DefaultAction=call;
            return
        end
        
        
        function erase(hFig)
            % Reset the WindowButtonMotionFcn tp [], remove the application
            % data and delete the object (together with all references to
            % it)
            if isappdata(hFig, 'MouseMotionHandlerObject')
                set(hFig, 'WindowButtonMotionFcn', []);
                obj=getappdata(hFig, 'MouseMotionHandlerObject');
                delete(obj);%delete references to obj globally
                rmappdata(hFig, 'MouseMotionHandlerObject');
            else
                warning('MouseMotionHandler:noInstance', 'No MouseMotionHandler assigned to parent. Can not delete');
            end
            return
        end
        
        function restore(hFig)
            % Restores the WindowButtonMotionFcn for the figure
            if isappdata(hFig, 'MouseMotionHandlerObject')
                obj=getappdata(hFig, 'MouseMotionHandlerObject');
                set(hFig, 'WindowButtonMotionFcn', {@MouseMotionHandler.FigureCallback, obj});
            else
                warning('MouseMotionHandler:noInstance', 'No MouseMotionHandler assigned to parent. Can not restore');
            end
            return
        end
        
        function FigureCallback(hFig, EventData, obj)
            % Callback to do the work. Test for match in the hashtable with
            % increasing generality i.e. look for specific HG object first,
            % then search by Tag, and finally  by object Type.

            if isMultipleCall();return;end
            % Find target?
            if obj.findVisibleOnly==true
                h=hittest(hFig);
            else
                h=MUtilities.findBelow(hFig);
                get(h,'Type')
            end
            
            if isempty(h);
                obj.currentObject=[];
                return
            else
                obj.currentObject=h(end);
            end
            
            
            % Have we changed object?
            if ~isempty(obj.previousObject)
                if obj.currentObject~=obj.previousObject
                    % Run exit callback for last object
                    if ~isempty(obj.previousIDX)
                        call=obj.exitArgs{obj.previousIDX};
                        if ~isempty(call)
                            if ischar(call)
                                eval(call)
                            else
                                if numel(call)==1
                                    if ~iscell(call);call={call};end
                                    call{1}(obj.previousObject, EventData);
                                else
                                    call{1}(obj.previousObject, EventData, call{2:end});
                                end
                            end
                        end
                    end
                end
            end
              
            % Work cleanly with standard MATLAB manager - Zoom/Pan etc
            % Note any exit callback will get serviced above. We suppress
            % only the main callbacks
            if isappdata(hFig,'ScribeClearModeCallback')
                MLmanager=getappdata(hFig,'ScribeClearModeCallback');
                mode=MLmanager{2};
                if ~isempty(mode.CurrentMode)
                    return
                end
            end
            
            % Is this object in list?
            idx=obj.ObjectList.get(num2str(obj.currentObject));
            % If not, does its tag match a key?
            if isempty(idx)
                thisTag=get(obj.currentObject, 'Tag');
                if ~isempty(thisTag)
                    idx=obj.ObjectList.get(thisTag);
                end
            end
            % If not, does its type match a key?
            if isempty(idx)
                thisType=get(obj.currentObject, 'Type');
                idx=obj.ObjectList.get(thisType);
            end
            
            % Now run selected callback
            if isempty(idx)
                if ~isempty(obj.DefaultAction)
                    if ischar(obj.DefaultAction)
                        eval(obj.DefaultAction)
                    else
                        call=obj.DefaultAction;
                        if numel(call)==1
                            if ~iscell(call);call={call};end
                            call{1}(obj.currentObject, EventData);
                        else
                            call{1}(obj.currentObject, EventData, call{2:end});
                        end
                    end
                end
                obj.previousObject=obj.currentObject;
                obj.previousIDX=[];
            else
                % Run the callback if we have found a match
                call=obj.Args{idx};
                if ~isempty(call)
                    if ischar(call)
                        eval(call)
                    else
                        if numel(call)==1
                            if ~iscell(call);call={call};end
                            call{1}(obj.currentObject, EventData);
                        else
                            call{1}(obj.currentObject, EventData, call{2:end});
                        end
                    end
                end
                obj.previousObject=obj.currentObject;
                obj.previousIDX=idx;
            end
            return
        end
        
        function m=demo()
            % Simple demo methods that changes the shape/color or the
            % cursor depending on what the cursor is moving over.
            % Static method: call as MouseMotionHandler.demo() from the
            % command line
            % 
            hFig=figure('Name', 'MouseMotionHandler Demo', 'Toolbar', 'figure','Units', 'normalized',...
            'Position',[0.2 0.2 0.6 0.6],'Color', [1 1 .8]);
            hP=uipanel('Parent', hFig, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'BackgroundColor', [1 1 .7]);
            axes('Parent', hP);
            ax1=subplot(1,2,1);
            set(ax1, 'Tag', 'Left axes', 'LineWidth', 5);
            t1=annotation('textbox',[0.1 0.9 0.8 0.05]);
            set(t1, 'String', 'Move the mouse to change the cursor or rotate the globe via the MouseMotionHandler',...
                'HorizontalAlignment', 'center');
            b1=uicontrol('Parent', hFig, 'Style','pushbutton', 'Units', 'normalized', 'Position', [0.3 0.025 0.4 0.05]);
            set(b1, 'String', 'http://sigtool.sourceforge.net/','Callback', 'web(''http://sigtool.sourceforge.net/'',''-browser'')');
            li=line('Parent', ax1, 'XData', (-2*pi:0.125:2*pi), 'YData', sinc(-2*pi:0.125:2*pi), 'Marker', 'o');
            set(li,'linesmoothing', 'on')
            axis('tight');
            % Figure callback : Note this is the MATLAB default so we
            % restore the pointer when leaving the figure. Similarly,
            % changes made to the cursor below will be 'undone' as the
            % mouse moves away from the target. In general, callbacks that
            % have 'global' affects such as changing the cursor need to be
            % undone via the DefaultAction
            m=MouseMotionHandler(hFig, {@f, 'arrow'});
            % Add specified handle ' we'll use the static methods as this
            % will likely be more typical usage
            MouseMotionHandler.put(hFig, hP, {@f, 'fleur'});
            % Add the axes by their tag
            MouseMotionHandler.put(hFig, 'Left axes', {@f, 'crosshair'});
            % Add the line by its type
            MouseMotionHandler.put(hFig, 'line', {@f, 'fullcrosshair'});
            % Add a surface
            ax2=subplot(1,2,2);
            topo=load('topo');
            [x y z]=sphere(45);
            s=surface(x,y,z,'FaceColor','texturemap','CData',topo.topo);
            colormap(topo.topomap1);
            brighten(0.5)
            campos([2 13 10]);
            camlight;
            lighting('gouraud');
            view(-102,36);
            axis('vis3d');
            grid('on');
            % Use the standard class methods here for illustration...
            m.add(ax2,'setptr(1,''closedhand'')');
            m.add(s, 'rotate3d(''on'')');
            % ... and a static one for good measure
            % Note we turn 3D rotation off in an exit callback. This will
            % turn off 3D rotation even when it has been selected from the
            % figure toolbar: exit callbacks are executed even when the 
            % MATLAB FigureToolManager is active.
            MouseMotionHandler.putExit(hFig, s, 'rotate3d(''off'')');
            return
            function f(hObject, EventData, in)
                setptr(ancestor(hObject,'figure'), in)
                return
            end
        end
        
    end
end



function flag=isMultipleCall()
% isMultipleCall checks the stack for multiple calls
% 
% isMultipleCall checks to see if multiple calls are present in the call
% stack to the function from which isMultipleCall was called.
% 
% Example:
% TF=isMultipleCall()
% 
% returns     true  if the stack contains more than one call to the
%                   function that called isMultipleCall
%             false otherwise
%
% See also: dbstack
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

flag=false; 
% Get the stack
s=dbstack();
if numel(s)<=2
    % Stack too short for a multiple call
    return
end
% How many calls to the calling function are in the stack?
names={s(1:end).name};
TF=strcmp(s(2).name,names);
count=sum(TF);
if count>1
    % More than 1
    flag=true; 
end
return
end
    