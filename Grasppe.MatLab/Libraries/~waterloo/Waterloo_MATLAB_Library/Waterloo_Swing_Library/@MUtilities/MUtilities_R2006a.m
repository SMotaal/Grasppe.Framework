class MUtilities
    % MUtilities  - MATLAB utilities for MATLAB R2006a
    %
    % THIS VERSION IS FOR MATLAB R2006a
    % Full functionality requires that JRE 1.6.10 or later is being used
    % 
    % To use this version, rename the existing MUtilities.m file then rename
    % this file as MUtilities.m
    %
    % The Java code used within MUtil can be downloaded from
    % https://sourceforge.net/projects/waterloo/
    % Add the jar file to your java class path using javaaddpath
    %
    % MUtilities provides MATLAB oriented access to the SwingUtilities in
    % Java and to the new AWTUtilities that will ship with JDK7 (and, for now,
    % are redistributed in the java code included in this download).
    % MUtilities also provides MATLAB code for performing operations
    % similar to those in SwingUtilities on MATLAB HG graphics objects.
    %
    % Call MUtil and LookAndFeel methods through this wrapper.
    %
    % For a full list of methods and access to their help documents, 
    % type "doc MUtilities" at the MATLAB command line.
    %
    % To call a static method, you need to prefix the method name with
    % MUtilities, e.g.:
    %
    % MUtilities.setFigureFade(3, 0.1);% Fade the opacity of figure 3 to
    %                                  % 0.1 using the AWTUtilities methods
    %
    % obj=MUtilities.getDeepestComponentAt(200,200); % get the deepest Java
    %                                                % component at screen location 200,200
    %                                                % via the SwingUtilities method
    %
    % h=MUtilities.findBelow(200,200);% Return the handles of all MATLAB HG
    %                                 % objects below the screen location
    %                                 % 200,200. The vector of handles is
    %                                 % in ancestor-order, with the
    %                                 % 'oldest' component in element 1.
    %                                 % In general, h(end) will be the
    %                                 % component with the lowest Z-order
    %                                 % i.e. the component on top.
    %
    % Note that the Look and Feel methods are experimental. For details see
    % LookAndFeel.m
    %
    % ACKNOWLEDGEMENT:
    % In writing these methods, I have been greatly helped by Yair Altman's
    % findjobj function on Matlab Central and his blog at 
    % http://undocumentedmatlab.com/
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
    % Copyright � The Author & King's College London 2010-
    % ---------------------------------------------------------------------
    %
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
    % Copyright � The Author & King's College London 2010-
    % ---------------------------------------------------------------------
    
    methods (Static=true)

        %HG HANDLE PEER

        %------------------------------------------------------------------
        function peer=getPeer(h)
        % getPeer returns the MATLAB peer of an hghandle object
        % Example:
        % peer=getPeer(obj)
        %       where obj is an hghandle object
        try
            obj=handle(h);
            if ( ishghandle(obj, 'figure') || ...
                    ishghandle(obj, 'uicontainer') || ...
                    ishghandle(obj, 'uiflowcontainer') || ...
                    ishghandle(obj, 'uigridcontainer'))
                peer = MUtilities.getJavaFrame(ancestor(obj,'figure'));
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
        catch
            % MATLAB R2006a and maybe later with ishghandle restricted
            % to one argument
            try
                peer = MUtilities.getJavaFrame(ancestor(h,'figure'));
            catch
                peer = get(h,'JavaContainer');
            end
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
                        jf=get(h,'JavaFrame');
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
            frame=MUtilities.getJavaFrame(h);
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
            temp=MUtilities.getFigureClientFrame(h);
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
            temp=MUtilities.getFigureClientFrame(h);
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
            frame=MUtilities.getJavaFrame(h);
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
            frame=MUtilities.getJavaFrame(h);
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
            temp=MUtilities.getFigureAxisContainer(h);
            target=javax.swing.SwingUtilities.getAncestorNamed('fFigurePanel', temp);
            return
        end
        
        %------------------------------------------------------------------
        function target=getFigureAxisContainer(h)
            % getFigureAxisPanel returns the handle of axis panel
            % in the figure.
            % Example:
            %   target=getFigureAxisPanel(h)
            %               where h is a figure handle
            frame=MUtilities.getJavaFrame(h);
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
            frame=MUtilities.getJavaFrame(h);
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
                w=MUtilities.getFigureWindow(obj1);
                flag=javax.swing.SwingUtilities(w, obj2);
            elseif isjava(obj1) && ishghandle(obj2)
                % hghandle parent of java?
                peer=MUtilities.getPeer(obj2);
                flag=javax.swing.SwingUtilities(obj1, peer);
            else
                flag=NaN;
            end
            return
        end
        

        % Figure painting
        %------------------------------------------------------------------
        function setFigureOpaque(h, flag)
            % Sets the opacity of a MATLAB figure or the MATLAB root
            % All objects in the hierarchy will be set opaque except for
            % the FigureMenuBar and its descendants.
            v=MUtilities.getJavaVersion()
            if v(2)<6
                return
            end
            if ishghandle(h)
                switch h
                    case 0
                        % Matlab root
                        target=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                    otherwise
                        target=MUtilities.getFigureWindow(h);
                end
                MUtilities.runRecursivelyOP(target, flag);
            end
            return
        end
        
        
        %------------------------------------------------------------------
        function setFigureOpacity(h, alpha)
            % Sets the opacity of a MATLAB figure or the MATLAB root
            % Example;
            % setFigureOpacity(h, alpha)
            %     h is the figure handle
            %     and alpha is the opacity (0-1)
            v=MUtilities.getJavaVersion();
            if v(2)<6
                return
            end
            if ishghandle(h)
                if MUtilities.isFigureDocked(h)
                    return
                else
                    switch h
                        case 0
                            % Matlab root
                            target=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                            alpha=max(alpha, 0.05);
                        otherwise
                            target=MUtilities.getFigureWindow(h);
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
            
            v=MUtilities.getJavaVersion()
            if v(2)<6
                return
            end
            
            if nargin<3
                delay=0.015;
            end
            switch h
                case 0
                    % Matlab root
                    target=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
                    newAlpha=max(newAlpha, 0.2);
                otherwise
                    target=MUtilities.getFigureWindow(h);
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
                    p1=MUtilities.getPosition(source, 0, h0);
                    p2=MUtilities.getPosition(reference, 0, h0);
                    pos(1)=pos(1)+p1(1)-p2(1);
                    pos(2)=pos(2)+p1(2)-p2(2);
                else
                    pos=MUtilities.getPosition(source, 0, h0);
                end
                return
            end
            
            if nargin<4 || isempty(hs)
                hs=findall(source);
            end
            
            
            if ismember(reference, hs)
                p1=MUtilities.getPosition(reference, 0, h0);
                p2=MUtilities.getPosition(source,0, h0);
                pos(1)=pos(1)-p1(1)+p2(1);
                pos(2)=pos(2)-p1(2)+p2(2);
                return
            else
                p1=MUtilities.getPosition(source, 0, h0);
                p2=MUtilities.getPosition(reference, 0, h0);
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
                                    hpos=MUtilities.getPosition(h(n), 0, objectlist);
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
                pos1=MUtilities.getPosition(obj, 0);
                pos2=MUtilities.getPosition(reference, 0);
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
            pos=MUtilities.getPosition(obj, fh);
            
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
                    pos=MUtilities.convertToJava(pos);
                case 1
                    if isjava(varargin{1})
                        pos=varargin{1};
                    else
                        pos=(varargin{1});
                    end
                case 2
                    pos=MUtilities.convertToJava(varargin{1}, varargin{2});
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
            % v=JavaVersion();
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
                        set(target, 'Opaque', 'on');
                    case false
                        set(target, 'Opaque', 'off');
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
                        MUtilities.runRecursivelyOP(target.getComponent(k), value);
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
    
    %------------------------------------------------------------------
        function installLookAndFeels()
            % installLookAndFeels installs the L&Fs supported by Project
            % Waterloo
            m=javax.swing.UIManager();
            m.installLookAndFeel('The JGoodies Plastic3D Look and Feel', 'com.jgoodies.looks.plastic.Plastic3DLookAndFeel');
            m.installLookAndFeel('The JGoodies Plastic Look and Feel', 'com.jgoodies.looks.plastic.PlasticLookAndFeel');
            %             m.installLookAndFeel('Synthetica', 'de.javasoft.plaf.synthetica.SyntheticaStandardLookAndFeel');
            %             m.installLookAndFeel('JTattoo', 'com.jtattoo.plaf.aluminium.AluminiumLookAndFeel');
            return
        end
        
        %------------------------------------------------------------------
        function f=chooseLookAndFeel()
            % chooseLookAndFeel displays a dialog allowing you to choose
            % from the installed Java Look and Feels
            % This calls the open source DefaultsDisplay code from Sun
            % Microsystems which is included in waterloo.jar:
            % http://www.java2s.com/Code/Java/Swing-JFC/DisplaysthecontentsoftheUIDefaultshashmapforthecurrentlookandfeel.htm
            % WARNING: With some Look and Feels you may see Java
            % exceptions. These are L&F and Platform sensitive.
            %
            switch computer()
                case {'MAC', 'MACI', 'MACI64'}
                    % Not supported on the OS X. Changing the L&F makes
                    % compound objects such as JComboBox unresponsive to low
                    % level events such as mouse clicks, possibly because
                    % there are low-level listeners (?).
                    return
                otherwise
                    %OK
            end

            
            try
                evalin('base', 'MATLABDefaultLookAndFeel');
            catch %#ok<CTCH>
                assignin('base', 'MATLABDefaultLookAndFeel', javax.swing.UIManager.getLookAndFeel());
            end
            
            f=figure();
            j=jcontrol(f, kcl.waterloo.MUtilities.DefaultsDisplay(), 'Position', [0 0 1 1]);
            combo=handle(j.getComponent(0).getComponent(0).getComponent(1), 'callbackproperties');
            apply=handle(j.getComponent(0).getComponent(0).getComponent(2), 'callbackproperties');
            set(combo, 'ActionPerformedCallback', {@Action, j});
            set(apply, 'ActionPerformedCallback', {@Apply, j});
            return
            
            
            function Action(hObj, Ev, j) %#ok<INUSL,INUSD>
                if isMultipleCall()
                    return
                end
                drawnow();
                set(hObj, 'ActionPerformedCallback', []);
                LF=javax.swing.UIManager.getLookAndFeel();
                LookAndFeel.resetLookAndFeel();
                window=javax.swing.SwingUtilities.getRoot(hObj);
                javax.swing.UIManager.setLookAndFeel(LF);
                javax.swing.SwingUtilities.updateComponentTreeUI(window);
                drawnow();
                set(hObj, 'ActionPerformedCallback', {@Action});
                return
            end
            
            
            function Apply(hObj, Ev, j) %#ok<INUSD>
                drawnow();
                LF=javax.swing.UIManager.getLookAndFeel();
                LookAndFeel.setLookAndFeel(LF);
            end
        end
        
        function LF=setLookAndFeel(LF)
            drawnow();
            javax.swing.UIManager.setLookAndFeel(LF);
            com.jidesoft.plaf.LookAndFeelFactory.installJideExtension();
            dt=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
            javax.swing.JFrame.setDefaultLookAndFeelDecorated(true);
            javax.swing.JDialog.setDefaultLookAndFeelDecorated(true);
            switch char(LF.getName())
                case {'The JGoodies Plastic3D Look and Feel', 'The JGoodies Plastic Look and Feel'}
                    LF.setCurrentTheme(LF.getPlasticTheme());
                otherwise
                    
            end
            javax.swing.SwingUtilities.updateComponentTreeUI(dt);
            drawnow();
            disp(LF);
        end
        
        function resetLookAndFeel()
            %             resetLookAndFeel restores the MATLAB default L&F for the current platform
            %             Example:
            %             resetLookAndFeel()
            %             The L&F is restored using a copy of the L&F placed in the base
            %             workspace bt the first call to chooseLookAndFeel. This L&F contains
            %             any changes made by MATLAB to the default keys and should
            %             fully restore the default MATLAB, as opposed to just the platform,
            %             default L&F.
            drawnow();
            LF=evalin('base', 'MATLABDefaultLookAndFeel');
            javax.swing.UIManager.setLookAndFeel(LF);
            dt=com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame();
            javaMethodEDT('updateComponentTreeUI', 'javax.swing.SwingUtilities',dt);
            drawnow();
            return
        end
        
        function varargout=getLookAndFeelKeys(LF)
            %             getLookAndFeelKeys gets or displays the Look and Feel keys
            %             x=getLookAndFeelKeys(LF)
            %                 returns the keys
            %             getLookAndFeelKeys(LF)
            %                 displays the
            %             If LF is unspecified, getLookAndFeelKeys uses the current L&F
            MANAGER=javax.swing.UIManager();
            if nargin==0
                LF=MANAGER.getLookAndFeel();
            end
            def=LF.getDefaults();
            keys=def.keys();
            x={};
            while (keys.hasMoreElements)
                x{end+1,1}=char(keys.nextElement());
                x{end, 2}=MANAGER.get(x{end,1});
            end
            [dum, idx]=sort({x{:,1}}); %#ok<CCAT1>
            if nargout==0
                fh=figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', sprintf('LookAndFeel: L&F Defaults for %s', char(LF.getName())));
                sz=size(x);
                sc=jcontrol(fh, javax.swing.JScrollPane(), 'Position', [0 0 1 1]);
                sc.setViewportView(javax.swing.JTable(sz(1), sz(2)+1));
                t=sc.getViewport().getComponent(0);
                for k=1:sz(2)
                    for m=1:sz(1)
                        if k==1
                            t.setValueAt(int16(m), m-1, 0);
                        end
                        t.setValueAt(x{idx(m),k}, m-1, k);
                    end
                end
            else
                varargout{1}=x;
            end
        end
        
        function updateFigure(h, LF)
            if ismac()
                return
            end
            MANAGER=javax.swing.UIManager();
            window=javax.swing.SwingUtilities.getRoot(MUtilities.getFigureWindow(h));
            oldLF=MANAGER.getLookAndFeel();
            drawnow()
            MANAGER.setLookAndFeel(LF);
            javax.swing.SwingUtilities.updateComponentTreeUI(window);
            drawnow()
            MANAGER.setLookAndFeel(oldLF);
            return
        end
        
        
        
        
        function compareLookAndKeys(LF1, LF2)
            % compareLookAndKeys tabulates the keys of two L&Fs
            % Example:
            % compareLookAndKeys(LF1, LF2)
            %   If LF1 is empty, it defaults to the L&F stored in the base
            %   workspace as MATLABDefaultLookAndFeel OR to the system
            %   default L&F if MATLABDefaultLookAndFeel does not exist
            %   If LF2 is empty, it defaults to the current L&F
            
            MANAGER=javax.swing.UIManager();
            
            if isempty(LF1)
                LF1=evalin('base', 'MATLABDefaultLookAndFeel;');
            end
            if isempty(LF1)
                LF1=MANAGER.getSystemDefaultLookAndFeel();
            end
            MATLABdef=LF1.getDefaults();
            MATLABkeys=MATLABdef.keys();
            
            % Defaults to compare
            if isempty(LF2)
                LF2=MANAGER.getLookAndFeel();
            end
            def=LF2.getDefaults();
            keys=def.keys();
            
            x={};
            while (MATLABkeys.hasMoreElements)
                x{end+1}=char(MATLABkeys.nextElement());
            end
            while (keys.hasMoreElements)
                x{end+1}=char(keys.nextElement());
            end
            x=unique(x);
            [dum, idx]=sort(x);
            fh=figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', sprintf('LookAndFeel: L&F Comparison for %s and %s', char(LF1.getName()), char(LF2.getName())));
            sc=jcontrol(fh, javax.swing.JScrollPane(), 'Position', [0 0 1 1]);
            sc.setViewportView(javax.swing.JTable(length(x), 4));
            t=sc.getViewport().getComponent(0);
            for m=1:length(x)
                t.setValueAt(int16(m), m-1, 0);
                t.setValueAt(x{idx(m)}, m-1, 1);
                try
                    t.setValueAt(MATLABdef.get(x{idx(m)}), m-1, 2);
                catch
                end
                try
                    t.setValueAt(def.get(x{idx(m)}), m-1, 3);
                catch
                end
            end
            return
        end
        
        %------------------------------------------------------------------
        function arr=getLFDefaults(thisLF)
            if nargin==1
                arr=thisLF.getDefaults().toArray();
            else
                MANAGER=javax.swing.UIManager();
                arr=MANAGER.getLookAndFeel().getDefaults().toArray;
            end
            return
        end
        

    
end