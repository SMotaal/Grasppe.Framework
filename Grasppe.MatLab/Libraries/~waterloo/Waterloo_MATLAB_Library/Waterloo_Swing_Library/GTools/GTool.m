classdef GTool < hgsetget
    % GTool superclass
    
    properties (SetAccess=private, GetAccess=public)
        PseudoPackage='GTool';
    end
    
    properties (SetAccess=protected, GetAccess=protected);
        Object=[];
    end
    
    methods
        
        function parent=getParent(obj)
            parent=obj.Parent;
            return
        end
        
        function comp=getComponents(obj)
            % getComponents returns all components associated with the object
            % Example:
            %     comp=getComponents();
            comp=obj.Components;
            return
        end
        
        function varargout=getComponent(obj, index1, index2)
            % getComponent returns the component(s) associated with the object
            % Examples:
            %     comp=getComponent(n1);
            %     comp=getComponent([n1, n2,...]);
            %     comp=getComponent(r,c);
            %     comp=getComponent(str);
            % where
            % n1,n2 are the linear indices into obj.Components
            % OR
            % r,c are the subindices when obj.Components is a 2-D cell
            % array
            % OR
            % str is the title or name of the component
            %
            % The output, comp, will be a cell array if multiple outputs
            % are required
            %
            varargout{1}=[];
            switch nargin
                case 2
                    if ischar(index1)
                        for k=1:numel(obj.Components)
                            try
                                if strcmp(index1, char(obj.Components{k}.getTitle()))
                                    varargout{1}=obj.Components{k};
                                end
                            catch e1 %#ok<NASGU>
                                if strcmp(index1, char(obj.Components{k}.getName()))
                                    varargout{1}=obj.Components{k};
                                end
                            end
                        end
                    elseif numel(index1)>1
                        varargout{1}=obj.Components(index1);
                    else
                        [varargout{1:max(1,nargout)}]=obj.Components{index1};
                    end
                case 3
                    varargout{1}=obj.Components{index1,index2};
            end
            return
        end
        
        function n=getComponentCount(obj)
            % getComponentCount
            % Example:
            %    n=obj.getComponentCount()
            % Returns the number of components in obj.Components
            n=numel(obj.Components);
            return
        end
        
        function setComponent(divider, index, component)
            % setComponent
            % Example:
            % obj.setComponent(index, component)
            if index>1
                divider.Components{index}=component;
            end
            return
        end
        
        function hobj=getObject(obj)
            hobj=obj.Object;
            return
        end
        
        
        function onCleanup(obj)
            % onCleanup coordinates clean deletion of a GTool object.
            % onCleanup should normally be called from the object
            % constructor.
            % Example:
            %       obj.onCleanup()
            fhandle=ancestor(obj.Parent, 'figure');
            list=getappdata(fhandle, 'GToolHandleList');
            if isempty(list)
                list={obj};
            else
                % Check whether obj is already in the list
                for k=1:numel(list)
                    if list{k}==obj
                        return
                    end
                end
                list{end+1}=obj;
            end
            setappdata(fhandle, 'GToolHandleList', list);
            if strcmpi(get(obj.Parent, 'Type'), 'figure')
                set(obj.Parent, 'DeleteFcn', @GTool.cleanupContainer);
            end
            return
        end
        
        
        function delete(obj)
            % delete methods
            % Example
            %        delete(obj)
            obj.removeCallbacks();
        end
        
        function removeCallbacks(obj)
            % removeCallbacks cleanly removes references to GTool objects in callbacks.
            % This allows deletion without memory leaks due to those references
            % Example
            %     removeCallbacks(obj)
            Callbacks=GTool.getDefault('GTool.ClearCallbacks');
            if isvalid(obj)
                if ~isempty(obj.Object)
                    try
                        this=obj.Object.hgcontrol;
                    catch e
                        this=obj.Object;
                    end
                    for k=1:numel(Callbacks)
                        try
                            set(this, Callbacks{k}, []);
                        catch %#ok<CTCH>
                        end
                    end
                end
            end
            return
        end
        
        function clzz=getClass(obj)
            clzz=class(obj);
            return
        end
        
        function color=getBackground(obj)
            try
                color=get(obj, 'BackgroundColor');
            catch e
                switch e.identifier
                    case 'MATLAB:class:InvalidProperty'
                        color=get(obj, 'Color');
                    otherwise
                        color='w';
                end
            end
            return
        end
        
    end
    
    methods (Static)
        %---------------------------------------------
        % These are the GTool class specific functions
        %---------------------------------------------
        function cleanupContainer(hFig, EventData) %#ok<INUSD>
            list=getappdata(ancestor(hFig, 'figure'), 'GToolHandleList');
            if isempty(list)
                return
            else
                if strcmp(get(hFig, 'Type'), 'figure')==false
                    clist=findall(hFig);
                    mlist={};
                    for k=1:numel(list)
                        if isvalid(list{k}) && ismember(list{k}.Parent, clist)
                            mlist{k}=list{k}; %#ok<AGROW>
                        end
                    end
                    list=mlist;
                end
                for k=1:numel(list)
                    if ishghandle(list{k}) || (isobject(list{k}) && isvalid(list{k}))
                        delete(list{k});
                    end
                end
            end
            return
        end
        
        
        function val=getDefault(key)
            % getDefault returns the value for a specified key
            val=GTool.setDefault(key);
            if ischar(val) && val(1)=='@'
                val=eval(val(2:end));
            end
            return
        end
        
        function val=getDefaults()
            % getDefaults returns the default hash table
            val=GTool.setDefault();
            return
        end
        
        function assignDefaults(hash)
            % assignDefaults assigns a hash table for the defaults
            % If hash==[], resets use of the startup defaults
            GTool.setDefault(hash);
        end
        
        
        function varargout=setTheme(theme)
            % setTheme
            % Note: Only works with kcl.jar installed
            % Not yet released
            persistent Theme;
            if nargout==1
                varargout{1}=Theme;
                return
            end
            if strcmpi(theme, 'default') || isempty(theme)
                Defaults=java.util.Hashtable();
                StartupDefaults(Defaults);
                GTool.setDefault(Defaults);
                Theme=[];
                return
            end
            Theme=theme;
            f=str2func(['theme_' theme]);
            f();
            return
        end
        
        function theme=getTheme()
            theme=GTool.setTheme();
            return
        end
    end
    
    
    %---------------------------------------------
    % Below are the general-pupose static functions
    %---------------------------------------------
    
    methods (Static, Access=protected)
        
        
        
        function Switch(previousComponent, newObj)
            % Switch animates the transition between two components
            % NOTE: This has effects on visibility of the components
            % Example:
            %     GTool.Switch(currentObject, newObject);
            %         currentObject will have its Visibility set to 'off'
            %         newObject will have its Visibility set to 'on'
            set(previousComponent, 'Visible', 'off');
            GTool.Fade(newObj, 'nowait', -0.2);
            return
        end
        
        
        function [t, ax]=Fade(obj, option, inc)
            % Fade animates the transition to a component
            % NOTE: Fade affects the visibility of objects
            % Fade places a patch over a MATLAB container and animates its
            % FaceAlpha value
            % Examples:
            %     [t, ax]=GTool.Fade(obj, option, inc)
            %         obj is a MATLAB container
            %         option is string, use 'wait' to suspend execution until
            %             the animation is complete
            %         inc positive values cause FaceAlpha to increase
            %             negative values cause FaceAlpha to decrease
            %             The time taken for the animation will depend on the
            %             absolute value of inc
            %     Output t is the MATLAB timer object. If no output is
            %     requested, the timer will be deleted at the end of the
            %     animation
            %     Output ax, is a list of axes handles created by Roll. If this
            %     output is not requested, the axes will be deleted when the
            %     animation completes.
            
            %drawnow();
            ax=zeros(size(obj));
            ptch=zeros(size(obj));
            if inc>0
                startalpha=0;
            else
                startalpha=1;
            end
            for k=1:numel(ax)
                ax(k)=axes('Parent', obj(k), 'Position', [0 0 1 1], 'XLim', [0 1], 'YLim', [0 1],'Tag', 'GTool:TempAxes');
                axis(ax(k), 'off');
                color='w';%GTool.getBackground(obj(k));
                ptch(k)=patch('Parent', ax(k), 'XData', [0 0 1 1], 'YData', [0 1 1 0], 'FaceColor', color, 'FaceAlpha', startalpha);
            end
            axis(ax, 'off');
            set(obj, 'Visible', 'on');
            t=timer('TimerFcn', {@LocalTimer2, ptch, inc}, 'ExecutionMode','fixedSpacing',...
                'Period', GTool.getDefault('Timer.Interval'), 'Tag', 'GTool:Timer');
            start(t);
            if nargin>=2 && ischar(option) && strcmpi(option, 'wait')
                timeout(t, ax);
            end
            return
            
            function LocalTimer2(tobj, EventData, ptch, inc) %#ok<INUSL>
                alpha=get(ptch(1), 'FaceAlpha')+inc;
                if alpha>1
                    alpha=1;
                elseif alpha<0
                    alpha=0;
                end
                set(ptch, 'FaceAlpha', alpha);
                refresh();
                if alpha>=1 || alpha<=0
                    stop(tobj);
                    delete(tobj);
                    h=get(ptch, 'Parent');
                    if iscell(h);h=cell2mat(h);end
                    delete(h);
                end
                return
            end
        end
        
        
    end
    
    methods(Static, Access=private)
        
        function varargout=setDefault(key, value)
            % setDefault manages the defaults
            persistent Defaults
            if isempty(Defaults)
                Defaults=java.util.Hashtable();
                StartupDefaults(Defaults);
            end
            switch nargin
                case 2
                    Defaults.put(key, value);
                case 1
                    switch class(key)
                        case 'char'
                            varargout{1}=Defaults.get(key);
                        otherwise
                            Defaults=key;
                    end
                case 0
                    varargout{1}=Defaults;
            end
            return
        end
        
        
    end
end

function StartupDefaults(Defaults)
% NB Can not have MATLAB function handle in Java hashtable
% Use '@' in strings to force evaluation on access through getDefault

% Get required MATLAB defaults
color=get(0,'DefaultFigureColor');

GTool.getDefaults().put('Waterloo.JavaAvailable', false);

% Create the GTool defaults
Defaults.put('Divider.Border','@javax.swing.border.LineBorder(java.awt.Color.BLACK,1,true)');
Defaults.put('Divider.Fill', '@GColor.getColor(''MATLAB_lightGray'')');
Defaults.put('Divider.VerticalText','<html>&#8226<br>&#8226<br>&#8226</html>');
Defaults.put('Divider.HorizontalText','<html>&#8226&nbsp&#8226&nbsp&#8226</html>');
Defaults.put('Divider.LockedText','<html>&#8226</html>');
Defaults.put('Divider.Width', 0.275);
Defaults.put('Divider.Animated', true);

Defaults.put('Divider.SplitPaneContainer', 'javax.swing.JPanel');
Defaults.put('Divider.SplitPaneVerticalText','<html>&#8226<br>&#8226<br>&#8226</html>');
Defaults.put('Divider.SplitPaneHorizontalText','<html>&#8226&nbsp&#8226&nbsp&#8226</html>');

Defaults.put('Accordion.Panel', '@javax.swing.JPanel()');
Defaults.put('Accordion.InnerPanel', '@javax.swing.JPanel()');
Defaults.put('Accordion.BannerBackground',javax.swing.UIManager().get('Panel.background'));
Defaults.put('Accordion.InnerBannerBackground',javax.swing.UIManager().get('Panel.background'));
Defaults.put('Accordion.TextColor','@java.awt.Color.darkGray');

Defaults.put('TabDisplay.Panel','@javax.swing.JPanel()');
Defaults.put('TabDisplay.Background',javax.swing.UIManager().get('Panel.background'));
Defaults.put('TabDisplay.TextColor','@java.awt.Color.darkGray');
Defaults.put('TabDisplay.SelectionColor','@java.awt.Color.yellow');
Defaults.put('TabDisplay.Icon.UNDOCK',javax.swing.ImageIcon(which('undock.png')));
Defaults.put('TabDisplay.Icon.CLOSE',javax.swing.ImageIcon(which('close.png')));

Defaults.put('GCardPane.MATLABBackground', 'w');
Defaults.put('GCardPane.Animated', false);

Defaults.put('LookAndFeelPanel', '@javax.swing.UIManager.getLookAndFeel()');

Defaults.put('ElasticPane.Animated', true);
Defaults.put('Timer.Interval', 0.05);

Defaults.put('Icon.DOWNARROW',javax.swing.ImageIcon(which('down.png')));
Defaults.put('Icon.UPARROW',javax.swing.ImageIcon(which('up.png')));
Defaults.put('Icon.DOCK',javax.swing.ImageIcon(which('dock.png')));
Defaults.put('Icon.UNDOCK',javax.swing.ImageIcon(which('undock.png')));
Defaults.put('Icon.CLOSE',javax.swing.ImageIcon(which('close.png')));
Defaults.put('Icon.MOVELEFT',javax.swing.ImageIcon(which('moveleft.png')));
Defaults.put('Icon.MOVERIGHT',javax.swing.ImageIcon(which('moveright.png')));
Defaults.put('Icon.MOVEUP',javax.swing.ImageIcon(which('moveup.png')));
Defaults.put('Icon.MOVEDOWN',javax.swing.ImageIcon(which('movedown.png')));

Defaults.put('GTool.ClearCallbacks',{'MouseEnteredCallback',...
    'MouseExitedCallback',...
    'MouseDraggedCallback',...
    'MouseMovedCallback',...
    'MouseReleasedCallback',...
    'StateChangedCallback',...
    'ActionPerformedCallback'});

return
end

function timeout(t, ax)
% Forces a MATLAB thread lock while the timer executes.
% Limit this to 2s using tic/toc to prevent complete locking on error
% and use a pause to let Java painting/event handling etc continue during
% the wait.
t1=tic();
while isvalid(t)
    elapsedTime=toc(t1);
    if elapsedTime>2
        if isvalid(t)
            % NB re-test for valid t, may have been deleted since previous test
            % e.g. in debug mode
            stop(t);
            delete(t);
            delete(ax);
        end
        break;
    else
        %pause(0.01);
    end
end
end

