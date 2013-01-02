classdef MUtil
    % MUtil  - MATLAB utilities: a collection of static methods for MATLAB
    %
    % The Java code used within MUtil can be downloaded from
    % https://sourceforge.net/projects/waterloo/
    % Add the jar file to your java class path using javaaddpath
    %
    % MUtil methods are intended to be called via MUtilities rather than
    % directly. The MUtilities class can easily be extended by adding
    % additional superclasses to the classdef.
    %
    % For full documentation see MUtilities.m
    %
    % See also MUtilities, LookAndFeel
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    %
    % Author: Malcolm Lidierth 07/10
    % Copyright © The Author & King's College London 2010-
    % ---------------------------------------------------------------------
    %
    % Changes:
    %   10-08-2010  Prepend MLVersion and JavaVersion with get for
    %               consistency
    
    
    methods (Static)
        
        %HG HANDLE PEER
        
        %------------------------------------------------------------------
        function peer=getPeer(obj)
            % getPeer returns the MATLAB peer of an hghandle object
            % Example:
            % peer=getPeer(obj)
            %       where obj is an hghandle object
            obj=handle(obj);
            if ( ishghandle(obj, 'figure') || ...
                    ishghandle(obj, 'uicontainer') || ...
                    ishghandle(obj, 'uiflowcontainer') || ...
                    ishghandle(obj, 'uigridcontainer'))
                peer = MUtil.getJavaFrame(ancestor(obj,'figure'));
            elseif ishghandle(obj, 'uitoolbar')
                peer = get(obj,'JavaContainer');
                if isempty(peer)
                    drawnow;
                    peer = get(obj,'JavaContainer');
                end
            elseif (ishghandle(obj, 'uisplittool') || ...
                    ishghandle(obj, 'uitogglesplittool'))
                parPeer = get(get(obj,'Parent'),'JavaContainer');
                if isempty(parPeer)
                    drawnow;
                end
                peer = get(obj,'JavaContainer');
            end
        end
        
        % FIGURE RELATED FUNCTIONS
        %------------------------------------------------------------------
        function jf=getJavaFrame(h)
            % getJavaFrame Returns the MATLAB "JavaFrame" for a figure
            % Example:
            % frame=getJavaFrame(h)
            %       where h is a figure handle
            if ishghandle(h)
                switch (h)
                    case 0
                        jf=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                    otherwise
                        % Taken from MATLAB's javacomponent function.
                        [lastWarnMsg lastWarnId] = lastwarn;
                        oldJFWarning=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                        try
                            jf=get(h,'JavaFrame');
                        catch e
                            switch e.identifier
                                otherwise
                                    jf=[];
                            end
                        end
                        warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                        lastwarn(lastWarnMsg, lastWarnId);
                end
            else
                jf=[];
            end
            return
        end
        
        
        %------------------------------------------------------------------
        function target=getFigureWindow(h)
            % getFigureWindow returns the handle of the AWT Window
            % that contains the figure.
            % Example:
            %   target=getFigureWindow(h)
            %               where h is a figure handle
            %
            % Notes:
            % If the visibility of the figure is set to 'off', the
            % figure has no window ancestor and getFigureWindow
            % returns empty.
            % If the figure is docked:
            %   [1] if the the "Figures" window is docked in the MATLAB
            %       desktop, the AWT Window is the MATLAB Main Frame
            %   [2] if the "Figure" window is floating, the AWT Window is
            %       the Multiple Client Window and is common to all docked
            %       figures
            % If the figure is minimised, it has no window. In this case
            % getFigureWindow returns the Figure Panel Container.
            drawnow();
            frame=MUtil.getJavaFrame(h);
            temp=frame.getFigurePanelContainer();
            if temp.isShowing()==true
                target=javax.swing.SwingUtilities.getRoot(temp);
            else
                target=temp;
                warning('MUtils:notShowing', 'handle %g is not presently visible and does not have an AWT Window as an ancestor', h);
            end
            
            return
        end
        
        %------------------------------------------------------------------
        function target=getFigureGlassPane(h)
            % getFigureGlassPane returns the handle of desktop JRootPane
            % that contains the figure.
            % Example:
            %   target=getFigureRootPane(h)
            %               where h is a figure handle
            % Notes:
            % If the figure "Visible" property is set to off,
            % getFigureRootPane returns empty
            temp=MUtil.getFigureClientFrame(h);
            temp=javax.swing.SwingUtilities.getRootPane(temp);
            target=temp.getComponent(0);
            return
        end
        
        %------------------------------------------------------------------
        function target=getFigureRootPane(h)
            % getFigureRootPane returns the handle of desktop JRootPane
            % that contains the figure.
            % Example:
            %   target=getFigureRootPane(h)
            %               where h is a figure handle
            % Notes:
            % If the figure "Visible" property is set to off,
            % getFigureRootPane returns empty
            temp=MUtil.getFigureClientFrame(h);
            target=javax.swing.SwingUtilities.getRootPane(temp);
            return
        end
        
        %------------------------------------------------------------------
        function target=getFigureLayeredPane(h)
            % getLayeredPane returns the handle of null JLayeredPane
            % that contains the figure.
            % Example:
            %   target=getLayeredPane(h)
            %               where h is a figure handle
            % Notes:
            % If the figure "Visible" property is set to off,
            % getFigureLayeredPane returns empty
            frame=MUtil.getJavaFrame(h);
            temp=frame.getFigurePanelContainer();
            target=javax.swing.SwingUtilities.getAncestorNamed('null.layeredPane', temp);
            return
        end
        
        
        %------------------------------------------------------------------
        function target=getFigureClientFrame(h)
            % getFigureClientFrame returns the handle of desktop InternalFrame
            % that contains the figure.
            % Example:
            %   target=getFigureClientFrame(h)
            %               where h is a figure handle
            target=[];
            frame=MUtil.getJavaFrame(h);
            if isempty(frame);return;end;
            temp=frame.getFigurePanelContainer();
            target=javax.swing.SwingUtilities.getAncestorNamed('fClientProxyInternalFrame', temp);
            return
        end
        
        %------------------------------------------------------------------
        function target=getFigureHWLWContainer(h)
            % getFigureHWLWContainer returns the handle of the heavy/lightweight container
            % for the figure.
            % Example:
            %   target=getFigureHWLWContainer(h)
            %               where h is a figure handle
            temp=MUtil.getFigureAxisContainer(h);
            target=javax.swing.SwingUtilities.getAncestorNamed('fFigurePanel', temp);
            return
        end
        
        
        %------------------------------------------------------------------
        function target=getFigureAxisContainer(h)
            % getFigureAxisContainer returns the handle of axis panel
            % in the figure.
            % Example:
            %   target=getFigureAxisContainer(h)
            %               where h is a figure handle
            frame=MUtil.getJavaFrame(h);
            list=frame.getFigurePanelContainer().getComponents();
            target=[];
            for k=1:numel(list)
                if strcmp(char(list(k).getName()), 'fComponentContainer')==true
                    target=list(k);
                    break
                end
            end
            return
        end
        
        
        %------------------------------------------------------------------
        function target=getFigureAxisProxy(h)
            % getFigureAxisProxy returns the handle of axis panel
            % in the figure.
            % Example:
            %   target=getFigureAxisProxy(h)
            %               where h is a figure handle
            frame=MUtil.getJavaFrame(h);
            target=[];
            list=frame.getFigurePanelContainer().getComponents();
            for k=1:numel(list)
                if strcmp(char(list(k).getName()), 'fAxisComponentProxy')==true
                    target=list(k);
                    break
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function target=getToolBarContainer(h)
            % getToolBarContainer returns the handle of toolbar container
            %   target=getToolBarContainer(h)
            %               where h is a figure handle
            target=[];
            client=MUtil.getFigureClientFrame(h);
            if isempty(client);return;end;
            list=client.getComponent(0).getComponent(0).getComponent(0);
            for k=1:numel(list)
                if strcmp(char(list(k).getName()), 'ToolBarContainer')==true
                    target=list(k);
                    break
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function target=getToolBar(h)
            % getToolBarr returns the handle of toolbar
            % in the figure.
            % Example:
            %   target=getToolBar(h)
            %               where h is a figure handle
            target=[];
            toolbar=MUtil.getToolBarContainer(h);
            list=toolbar.getComponents();
            for k=1:numel(list)
                if isa(list(k),'com.mathworks.mwswing.MJToolBar')
                    target=list(k);
                    break
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function target=getSaveFigureButton(h)
            %  Example:
            %               target=getSaveFigureButton(h)
            %  where h is a figure handle
            target=[];
            toolbar=MUtil.getToolBar(h);
            if ~isempty(toolbar)
                if ~isempty(toolbar)
                    list=toolbar.getComponents();
                    for k=1:numel(list)
                        try
                            if list(k).getToolTipText().equals('Save Figure');
                                target=list(k);
                                break
                            end
                        catch
                        end
                    end
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function target=getOpenFileButton(h)
            %  Example:
            %               target=getOpenFileButton(h)
            %  where h is a figure handle
            target=[];
            toolbar=MUtil.getToolBar(h);
            if ~isempty(toolbar)
                list=toolbar.getComponents();
                for k=1:numel(list)
                    try
                        if list(k).getToolTipText().equals('Open File');
                            target=list(k);
                            break
                        end
                    catch
                    end
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function target=getPrintFigureButton(h)
            %  Example:
            %               target=getPrintFigureButton(h)
            %  where h is a figure handle
            target=[];
            toolbar=MUtil.getToolBar(h);
            if ~isempty(toolbar)
            list=toolbar.getComponents();
                for k=1:numel(list)
                    try
                        if list(k).getToolTipText().equals('Print Figure');
                            target=list(k);
                            break
                        end
                    catch
                    end
                end
            end
            return
        end
            
        
        %------------------------------------------------------------------
        function target=getFigureComponentContainer(obj)
            % getFigureComponentContainer returns the handle of the component container
            % for the specified object.
            % Example:
            %   target=getFigureComponentContainer(obj)
            target=javax.swing.SwingUtilities.getAncestorNamed('fComponentContainer', obj);
            return
        end
        
        
        %------------------------------------------------------------------
        % Is functions
        function flag=isFigureDocked(h)
            % isFigureDocked test for docked figure
            % Example:
            % flag=isFigureDocked(h)
            %    returns true if figure h is docked
            if h==0
                flag=false;
                return
            end
            switch get(h, 'WindowStyle')
                case 'docked'
                    flag=true;
                otherwise
                    flag=false;
            end
            return
        end
        
        %------------------------------------------------------------------
        function flag=isDescendingFrom(obj1, obj2)
            % isDescendingFrom test for ancestory
            % Example:
            % flag=isDescendingFrom(object, candidate_ancestor)
            %       returns true if obj1 descends from obj2
            if ishghandle(obj1) && ishghandle(obj2)
                % Both hghandles
                if (obj1~=obj2) && ismember(obj1, findall(obj2))
                    flag=true;
                else
                    flag=false;
                end
            elseif isjava(obj1) && isjava(obj2)
                % Both java
                flag=javax.swing.SwingUtilities(obj1, obj2);
            elseif ishghandle(obj1) && isjava(obj2)
                % java parent of hghandle?
                w=MUtil.getFigureWindow(obj1);
                flag=javax.swing.SwingUtilities(w, obj2);
            elseif isjava(obj1) && ishghandle(obj2)
                % hghandle parent of java?
                peer=MUtil.getPeer(obj2);
                flag=javax.swing.SwingUtilities(obj1, peer);
            else
                flag=NaN;
            end
            return
        end
        
        
        % Figure painting
        %------------------------------------------------------------------
        function setFigureOpaque(h, flag)
            % Sets the Opaque property of a MATLAB figure and its
            % descendants
            % Example:
            % setFigureOpaque(h, flag)
            %   h is the figure handle
            %   flag is true or false
            % All objects in the hierarchy will be affected except for
            % the FigureMenuBar and its descendants.
            if ishghandle(h)
                switch h
                    case 0
                        % Matlab root
                        target=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                    otherwise
                        target=MUtil.getFigureWindow(h);
                end
                MUtil.runRecursivelyOP(target, flag);
            end
            return
        end
        
        
        %------------------------------------------------------------------
        function setFigureOpacity(h, alpha)
            % Sets the opacity (Alpha) of a MATLAB figure or the MATLAB root
            % Example;
            % setFigureOpacity(h, alpha)
            %     h is the figure handle
            %     and alpha is the opacity (0-1)
            if ishghandle(h)
                if MUtil.isFigureDocked(h)
                    return
                else
                    switch h
                        case 0
                            % Matlab root
                            target=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                            alpha=max(alpha, 0.05);
                        otherwise
                            target=MUtil.getFigureWindow(h);
                    end
                    com.sun.awt.AWTUtilities.setWindowOpacity(target, alpha);
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function setFigureFade(h, newAlpha, delay)
            % setFigureFade fades a MATLAB figure in or out
            % i.e. setFigureFade gradually sets the opacity of a MATLAB figure
            % (or the MATLAB root)
            % Example:
            % setFigureOpacityGradual(h, newAlpha, delay)
            %     h is the handle
            %     and newAlpha is the required opacity (0-1)
            %     delay sets the pause (in seconds) between each of twenty
            %     steps towards the new opacity (default 0.015s giving 0.3s
            %     total time).
            %
            % NB setFigureFade halts MATLAB code execution for 20 x delay
            % (s) while the fade is implemented. To achieve asynchrounous
            % fading, use calls to setFigureOpacity in a MATLAB timer
            % object.
            
            if nargin<3
                delay=0.015;
            end
            switch h
                case 0
                    % Matlab root
                    target=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                    newAlpha=max(newAlpha, 0.2);
                otherwise
                    target=MUtil.getFigureWindow(h);
                    if isempty(target)
                        return
                    end
                    figure(h);
            end
            oldAlpha=com.sun.awt.AWTUtilities.getWindowOpacity(target);
            inc=(newAlpha-oldAlpha)/20;
            thisAlpha=oldAlpha;
            for k=1:20
                thisAlpha=thisAlpha+inc;
                % Watch out for IEEE round-off
                if thisAlpha<0
                    thisAlpha=0;
                end
                if thisAlpha>1
                    thisAlpha=1;
                end
                com.sun.awt.AWTUtilities.setWindowOpacity(target, thisAlpha);
                pause(delay);
            end
            return
        end
        
        
        % SCREEN LOCATION FUNCTIONS
        %------------------------------------------------------------------
        function pos=convertPosition(pos, source, reference, hs, hr, h0)
            % convertPosition converts a position between containers
            % Examples:
            % pos=convertPosition(pos, source, reference)
            %    where
            %        pos is a position vector (numel>=2)
            %        source is the handle of the HG object in which pos is expressed
            %        reference is the HG object to provide coordinates within
            % pos=convertPosition(pos, source, reference, hs, hr, h0)
            %        also supplies the handles returned by findall(source),
            %        findall(reference) and findall(0). This prevents
            %        convertPosition calling findall when called multiply,
            %        and can substantially reduces processing time
            if nargin<3
                reference=0;
            end
            
            if nargin<5 || isempty(hr)
                hr=findall(reference);
            end
            if nargin<6 || isempty(h0)
                h0=findall(0);
            end
            
            if ismember(source, hr)
                if reference>0
                    p1=MUtil.getPosition(source, 0, h0);
                    p2=MUtil.getPosition(reference, 0, h0);
                    pos(1)=pos(1)+p1(1)-p2(1);
                    pos(2)=pos(2)+p1(2)-p2(2);
                else
                    pos=MUtil.getPosition(source, 0, h0);
                end
                return
            end
            
            if nargin<4 || isempty(hs)
                hs=findall(source);
            end
            
            
            if ismember(reference, hs)
                p1=MUtil.getPosition(reference, 0, h0);
                if source>0
                    p2=MUtil.getPosition(source,0, h0);
                else
                    p2=[1 1];
                end
                pos(1)=pos(1)-p1(1)+p2(1);
                pos(2)=pos(2)-p1(2)+p2(2);
                return
            else
                p1=MUtil.getPosition(source, 0, h0);
                p2=MUtil.getPosition(reference, 0, h0);
                pos(1)=pos(1)+p1(1)-p2(1)-1;
                pos(2)=pos(2)+p1(2)-p2(2)-1;
                return
            end
        end
        
        %------------------------------------------------------------------
        function [out, pos]=findBelow(x,y, figlist)
            % findBelow returns the handles of all objects below a particular pixel
            % position
            %
            % Examples:
            % h=findBelow()         returns all handles below the current cursor position
            % h=findBelow(figs)     as above, but restricts the search to the figure(s)
            %                       whose handle(s) are specified in figs
            %
            % h=findBelow(x,y)      returns all handles below the pixel position specified
            %                         as x,y.
            % h=findBelow(x,y,figs) as above, but restricts the search to the figure(s)
            %                         whose handle(s) are specified in figs
            %
            %       x,y are relative to the MATLAB root with 0,0 as the lower
            %       left corner
            
            out=[];
            
            figs=get(0, 'Children');
            
            if nargin==0
                pos=get(0, 'PointerLocation');
                figlist=[];
            elseif nargin==1
                figlist=x;
                pos=get(0, 'PointerLocation');
            elseif nargin==2
                pos=[x, y];
                figlist=[];
            else
                pos=[x,y];
            end
            
            TF=zeros(1, numel(figs));
            for k=1:numel(figs)
                figpos=hgconvertunits(figs(k), get(figs(k), 'Position'), get(figs(k),'Units'), 'pixels', 0);
                TF(k)=pinrect(pos, figpos);
            end
            figs=figs(TF==1);
            
            if ~isempty(figlist)
                figs=figs(ismember(figs, figlist));
            end
            
            for k=1:numel(figs)
                h=findall(figs(k));
                objectlist=findall(0);
                for n=1:numel(h)
                    try
                        switch get(h(n), 'Type')
                            otherwise
                                try
                                    hpos=MUtil.getPosition(h(n), 0, objectlist);
                                    TF=pinrect(pos, hpos);
                                    if TF==1
                                        out(end+1)=h(n); %#ok<AGROW>
                                    end
                                catch %#ok<CTCH>
                                end
                        end
                    catch %#ok<CTCH>
                    end
                end
            end
            out=out(:);
            return
            
            function bool = pinrect(pts,rect)
                TF1=pts(1)>=rect(1) & pts(1)<=rect(1)+rect(3);
                TF2=pts(2)>=rect(2) & pts(2)<=rect(2)+rect(4);
                bool=TF1 & TF2;
                return
            end
            
        end
        
        %------------------------------------------------------------------
        function pos=getPosition(obj, reference, objectlist)
            % getPosition returns the position vector for one object referenced to another
            %
            % Example
            % pos=getPosition(obj, reference)
            % pos=getPosition(obj, reference, objectlist)
            %
            % Output      pos           is a position vector in pixels
            % Inputs      obj           is the object whos position will be returned
            %             reference     is the reference container
            %             objectlist    if supplied, is a list of all the objects in
            %                           reference. If objectlist is not specified, it
            %                           will default to findall(reference). With
            %                           repeated calls to getPosition, this can be
            %                           slow. In this case supplying
            %                           objectlist(=findall(reference)) as an input can
            %                           greatly speed processing.
            %
            %             obj and reference may each be
            %                   [1] a handle to an HG graphics object
            %                   [2] a jcontrol object
            %                       or
            %                   [3] a uicomponent
            %
            % Output pos is the position vector (in pixels) that would be returned by
            %           set(obj, 'Units', 'Pixels');
            %           pos=get(obj,'Position');
            % if obj were a child of reference
            %
            % pos may be a 2, 3 or 4 element vector depending on the type of obj
            %
            % NB. All scanned objects (except the root) must have Units and Position
            % properties
            %
            
            
            if nargin<2
                reference=0;
            end
            
            
            if isa(obj, 'jcontrol')
                % Jcontrol object
                obj=obj.hghandle;
            elseif isa(obj, 'hgjavacomponent') && isprop(obj, 'MatlabHGContainer')
                % Yair Altman's uicomponent object
                obj=get(obj, 'MatlabHGContainer');
            end
            
            if isa(reference, 'jcontrol')
                % Jcontrol object
                reference=reference.uipanel;
            elseif isa(reference, 'hgjavacomponent') && isprop(reference, 'MatlabHGContainer')
                % Yair Altman's uicomponent object
                reference=get(reference, 'MatlabHGContainer');
            end
            
            if nargin<3 || isempty(objectlist)
                objectlist=findall(reference);
            end
            
            if ~isscalar(obj)
                % Not expected
                pos=[];
                return
            elseif obj==reference
                % Trivial - identical obj & reference
                objunits=get(obj, 'Units');
                set(obj, 'Units', 'pixels');
                pos=get(obj, 'Position');
                set(obj, 'Units', objunits);
                pos(1)=1;
                pos(2)=1;
                return
            elseif ~ismember(obj, objectlist)
                % Reference is not an ancestor of obj
                % Get positions on screen and return difference
                pos1=MUtil.getPosition(obj, 0);
                pos2=MUtil.getPosition(reference, 0);
                pos=pos1;
                pos(1)=pos1(1)-pos2(1);
                pos(2)=pos1(2)-pos2(2);
                return
            else
                % Reference is an ancestor of obj
                % Find position reference to parent of obj...
                objunits=get(obj, 'Units');
                set(obj, 'Units', 'pixels');
                if obj>0
                    pos=get(obj, 'Position');
                else
                    pos=[1 1];
                end
                set(obj, 'Units', objunits);
                % ...then loop through ancestors until we get to the specified
                % reference
                while get(obj, 'Parent')>0
                    obj=get(obj, 'Parent');
                    if obj==reference
                        break
                    end
                    objunits=get(obj, 'Units');
                    set(obj, 'Units', 'pixels');
                    pos2=get(obj, 'Position');
                    set(obj, 'Units', objunits);
                    pos(1)=pos(1)+pos2(1);
                    pos(2)=pos(2)+pos2(2);
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function varargout=getCentre(obj)
            % getCentre returns the x,y coordinates of the centre of an object relative
            % to a figure
            %
            % getCentre(obj)
            % pos=getCentre(obj)
            %       return the 2 element position vector of the centre of
            %       obj relative to its parent figure
            % OR
            % [x,y]=getCentre(obj)
            % x and y are returns the values as scalars
            %
            % Returned values are in normalized figure units for use with the Matlab
            % annotation functions
            
            fh=ancestor(obj, 'figure');
            pos=MUtil.getPosition(obj, fh);
            
            % In pixels
            x=pos(1)+pos(3)/2-1;
            y=pos(2)+pos(4)/2-1;
            
            % Dim
            units=get(fh, 'Units');
            set(fh, 'Units', 'pixels');
            pos=get(fh, 'Position');
            set(fh, 'Units', units);
            
            % Normalize units for return values
            x=x/pos(3);
            y=y/pos(4);
            
            if nargout==2
                varargout{1}=x;
                varargout{2}=y;
            else
                varargout{1}=[x,y];
            end
            
            return
        end
        
        function pos=convertToJava(varargin)
            % convertToJava returns a screen position/size in Java coordinates
            % Examples:
            % pos=convertToJava()
            % pos=convertToJava(pos)
            % pos=convertToJava(x,y, [[w], [h]])
            %    With no input, convertToJava returns the value
            %    for the current point from the MATLAB root properties.
            %    Otherwise, supply a position/size vector (numel>=2), or:
            %    an x,y pair; x,y,w triplet or x,y,w,h rectangle
            %
            % Returns a java.awt.Point or java.awt.Rectangle object
            % corrected for the Java coordinate system i.e., (0,0) top left
            % instead of the MATLAB system of (1,1) bottom left. Where
            % height is unspecified, it is set to 0.
            switch nargin
                case 0
                    pos=get(0, 'PointerLocation');
                case 1
                    pos=varargin{1};
                case {2,3,4}
                    pos(1)=varargin{1};
                    pos(2)=varargin{2};
                    if nargin>=3
                        pos(3)=varargin{3};
                    end
                    if nargin>=4
                        pos(4)=varargin{4};
                    end
            end
            % TODO: Put in dual monitor support
            sz=get(0, 'ScreenSize');
            pos(1)=pos(1)-1;
            pos(2)=sz(4)-pos(2)-1;
            if numel(pos)==3
                pos(4)=0;
            end
            switch numel(pos)
                case 2
                    pos=java.awt.Point(pos(1), pos(2));
                case 4
                    pos=java.awt.Rectangle(pos(1), pos(2), pos(3), pos(4));
            end
            return
        end
        
        function pos=convertToMATLAB(varargin)
            % convertToMATLAB returns a screen position/size in MATLAB coordinates
            % Examples:
            % pos=convertToMATLAB()
            % pos=convertToMATLAB(java.awt.Point)
            % pos=convertToMATLAB(java.awt.Rectangle)
            %    With no input, convertToJava returns the value
            %    for the current point from the MATLAB root properties.
            %    Otherwise, supply an AWT Point or Rectangle object as
            %    input
            %
            % Returns a MATLAB coordinate vector
            % corrected for the MATLAB coordinate system i.e., (1,1) bottom left
            % instead of the Java system of (0,0) top left.
            switch nargin
                case 0
                    % Trivial use - here only for symmetry with convertToJava
                    pos=get(0, 'PointerLocation');
                    return
                case 1
                    obj=varargin{1};
            end
            % TODO: Put in dual monitor support
            pos(1)=obj.getX()+1;
            pos(2)=obj.getY();
            if isa(obj, 'java.awt.Rectangle')
                pos(3)=obj.getWidth();
                pos(4)=obj.getHeight();
            end
            sz=get(0, 'ScreenSize');
            pos(2)=sz(4)-pos(2);
            return
        end
        
        function obj=getDeepestComponentAt(varargin)
            % getDeepestComponentAt returns the deepest Java component at a point
            % Examples:
            % obj=getDeepestComponentAt()
            % obj=getDeepestComponentAt(pos)
            % obj=getDeepestComponentAt(x,y)
            % obj=getDeepestComponentAt(java.awt.Point)
            %    With no input, getDeepestComponentAt uses the value
            %    for the current point from the MATLAB root properties.
            %    Otherwise, supply an MATLAB position vector, AWT Point
            %    or Rectangle object as input
            % FOR TUTORIAL INFO SEE
            % http://download.oracle.com/docs/cd/E17409_01/javase/tutorial/uiswing/components/rootpane.html
            switch nargin
                case 0
                    pos=get(0, 'PointerLocation');
                    pos=MUtil.convertToJava(pos);
                case 1
                    if isjava(varargin{1})
                        pos=varargin{1};
                    else
                        pos=(varargin{1});
                    end
                case 2
                    pos=MUtil.convertToJava(varargin{1}, varargin{2});
            end
            peer=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
            obj=javax.swing.SwingUtilities.getDeepestComponentAt(peer, pos.getX(), pos.getY());
        end
        
        
        
        % System
        function v=getMLVersion()
            % Returns the MATLAB version as a 4-element double vector
            % Example:
            % v=getMLVersion();
            % With MATLAB 7.10.0.499, this would return [7, 10, 0, 499];
            % This provides a backwards compatible way to support version-
            % dependent conditional statements in code (verLessThan is not
            % available in early MATLAB versions).
            v=version();
            v=getParts(v);
            return
            function parts = getParts(V)
                % getParts internal helper function
                parts = sscanf(V, '%d.%d.%d.%d')';
                if length(parts)<3
                    parts(3)=0;
                    parts(4)=0;
                end
                if length(parts)<4
                    parts(4)=0;
                end
            end
        end
        
        function v=getJavaVersion()
            % Returns the JRE version as a 4-element double vector
            % Example:
            % v=getJavaVersion();
            % With JRE 1.6.0 release 20, this would return [1, 6, 0, 20];
            v=version('-java');
            v=getParts(v);
            return
            function parts=getParts(V)
                % getParts internal helper function
                V=strrep(V, '_', ' ');
                V=strrep(V, '-', ' ');
                parts=sscanf(V, 'Java %d.%d.%d %d')';
            end
        end
        
        
        % Internal functions - currently public but that may change
        function runRecursivelyOP(target, value)
            % runRecursivelyOP. Internal helper function
            value=logical(value);
            if isa(target, 'com.mathworks.hg.peer.FigureMenuBar')
                return
            end
            try
                switch(value)
                    case true
                        set(target, 'Opaque', true);% 'on' deprecated: when?
                    case false
                        set(target, 'Opaque', false);%'off'
                end
            catch e1
                switch e1.identifier
                    case 'MATLAB:hg:propswch:FindObjFailed'
                        if isa(target, 'java.awt.Window')
                            try
                                com.sun.awt.AWTUtilities.setWindowOpaque(target, value);
                            catch e2
                                switch e2.identifier
                                    case 'MATLAB:Java:GenericException'
                                        disp(target);
                                    otherwise
                                        rethrow(e2);
                                end
                            end
                        end
                end
            end
            try
                n=target.getComponentCount();
                if n>0
                    for k=0:n-1
                        MUtil.runRecursivelyOP(target.getComponent(k), value);
                    end
                end
            catch e3
                switch e3.identifier
                    case 'MATLAB:noSuchMethodOrField'
                        comp=target.getComponentAt(0,0);
                        if ~isempty(comp) && isa(comp, 'java.awt.Canvas')
                            %OK
                        else
                            rethrow(e3);
                        end
                    otherwise
                        rethrow(e3);
                end
            end
        end
    end % end methods
    
end % end classdef