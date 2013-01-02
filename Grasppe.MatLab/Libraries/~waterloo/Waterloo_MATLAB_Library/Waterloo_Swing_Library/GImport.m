classdef GImport < handle
    %     GImport captures a Java-based GUI and adds it to a MATLAB container
    %     With GImport, you can design Java-based GUIs and place them in 
    %     MATLAB figures.
    %     External GUI designers such as those in the Eclipse or NetBeans 
    %     IDEs, instead of MATLAB's GUIDE, can be used.
    %
    %     Imported GUIs can be modified on-the-fly so imported GUIs can be 
    %     populated dynamically within MATLAB. 
    %
    %     Convenience methods are included to support dynamically setting 
    %     common properties across a hierarchy of components, e.g. Fonts and
    %     Background colors and for drag & drop between components.
    %
    %     Methods are also included to support user interaction and to 
    %     control the MATLAB thread via 'Cancel' and 'OK' buttons.
    %
    % GIMPORT IS VERSATILE. FOR A FULL DESCRIPTION OF ITS METHODS AND USE
    % SEE THE PDF DOCUMENTATION INCLUDED IN THE DISTRIBUTION.
    %     
    % Examples:
    %   g=GImport(MATLABcontainer, javaobject);
    %   OR
    %   g=GImport(MATLABcontainer, javaobject, includeFlag);
    %   OR
    %   g=GImport(MATLABcontainer, javaobject, includeFlag, setup);
    %   OR
    %   g=GImport(MATLABcontainer, javaobject, includeFlag, setup, option1, option2,...);
    %   OR
    %   g=GImport(JFrame, javaobject);
    %   OR
    %   g=GImport(JFrame, javaobject, includeFlag);
    %   OR
    %   g=GImport([], javaobject, includeFlag);
    %
    %     Where
    %                      --------------------------------------
    %           MATLABContainer is any MATLAB container capable of housing
    %                           a javacomponent e.g. a figure or uipanel
    %           OR
    %
    %           JFrame          is a javax.swing.JFrame
    %
    %           OR
    %                           the target field is left empty. This can be
    %                           used with an existing GUI that is already
    %                           displayed independently of GImport e.g. in
    %                           a user-created JFrame. This GUI is specified
    %                           as javaobject (see below)
    %                      --------------------------------------
    %
    %           javaobject      is any Java container with a GUI e.g. a JPanel
    %                      
    %           includeFlag     is TRUE or FALSE (default true).
    %                           
    %                           When FALSE (recommended when designing
    %                           custom GUIs)
    %                           Only objects of components for which
    %                           the Name property is set with a string
    %                           beginning with '$' or '+' will be
    %                           included in the getHandles structure.
    %                           If '$', only the component will be included
    %                           but not its descendants. Use this with
    %                           compound components such as a JComboBox
    %                           which is made of several underlying
    %                           components.
    %                           If '+', the component and its descendants
    %                           will be included. Use this with containers
    %                           like JPanels where all the sub-components
    %                           are required.
    %                           When GUIs are custom-designed for use with
    %                           GImport, this can greatly simplify further
    %                           use of the structure returned by getHandles.
    %
    %                           When TRUE,
    %                           All java objects are included in the structure
    %                           returned by getHandles (see below). The
    %                           structure can therefore be cumbersome and will
    %                           include all features such as null
    %                           contentpanes. Use this with GUIs that were
    %                           not custom-designed for use with GImport.
    %                           Any GUI should be supported with this
    %                           option which is therefore the default.
    %
    %                Note that includeFlag affects only the structure
    %                returned by getHandles. It does not affect the import
    %                process and the handles returned by the getComponents
    %                method will not be affected.
    %                
    %           setup           If present, specifies code to invoke
    %                           after the Java object has been displayed - but
    %                           before any layout managers are replaced
    %                           and while the object is drawn at the
    %                           dimensions specified in the constructor code. 
    %                           The setup process is run before GImport
    %                           has processed the Java hierarchy so it is
    %                           left to the user to ensure that
    %                           the setup code is thread-safe and uses the
    %                           EDT if required (which is likely).
    %                           If setup is a string it can be:
    %                               [1] a valid Java method for the Java
    %                               Object e.g. 'repaint'. 
    %                               [2] a MATLAB function which will be
    %                               called with javaobject as its input.
    %                           If setup is a function handle, it will be
    %                            called with javaobject as its input
    %                           If setup is a cell array, the first element
    %                           should be a function handle. This will be
    %                           called with the javaobject as its first
    %                           input with elements 2:end of the cell array
    %                           as any further arguments to the function.                         
    %                           
    %           options         Options are strings and include:
    %                           'guisize'
    %                               On construction, the GUI will take the
    %                               size of the designed GUI rather than
    %                               the MATLAB container
    %                           'hide'
    %                               The GUI will not be made visible.
    %                               Invoke the show() method to display it.
    %                               (Useful when resizing/repositioning
    %                               GUIs after instantiation).
    %                           'center' or 'centre'
    %                               Positions the MATLAB container so that
    %                               it is central in its parent
    %                           'noresize'
    %                               Does not install a resize callback for
    %                               the imported component
    %                           'nolayout'
    %                               Suppresses active management of all
    %                               layouts and does not install a resize
    %                               callback for the imported component.
    %                               Useful if you have already installed
    %                               MATLAB-friendly layouts at the design
    %                               stage
    %
    %   GImport is versatile. For a full description of its methods and use
    %   see the PDF documentation included in the distribution.
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    %
    % Author: Malcolm Lidierth 12/11
    % Copyright The Author & King's College London 2011-
    % ---------------------------------------------------------------------
    
    % Revisions
    %   11.01.2012 Added support for GXJFrames
    %   09.03.2012 Added support for empty target (=independent GUIs)

    
    properties (SetAccess=private, GetAccess=public, Hidden=false)
       Parent;
       Object;
    end
    
    properties (SetAccess=private, GetAccess=public, Hidden=true)
        guihandles;
        handlelist={};
        guivalues;
        originalBounds;
        includeAll;
        N;
        ActiveCallbackList={'ComponentResizedCallback'};
        linkedObjects={};
    end
    
    
    methods
        
        function obj=GImport(target, jObject, includeFlag, fcn, varargin)
            % Constructor
            if nargin<3
                obj.includeAll=true;
            else
                obj.includeAll=includeFlag;
            end
            % Reset counter
            getLabel(0);
            
            if isempty(target)
                obj.guihandles=getChildren(obj, jObject, obj.includeAll); 
            elseif ~isa(target, 'javahandle_withcallbacks.javax.swing.JFrame')
                
                % Force target to the preferred size of jObject
                obj.Parent=target;
                set(target, 'Units', 'pixels');
                posp=get(target, 'Position');
                originalSize=jObject.getPreferredSize();
                if originalSize.getWidth()>0 && originalSize.getHeight()>0
                    set(target, 'Position', [posp(1) posp(2) originalSize.getWidth() originalSize.getHeight()]);
                else
                    jObject.setPreferredSize(java.awt.Dimension(posp(3), posp(4)));
                end
                % Add the object
                
                obj.Object=jcontrol(target, jObject, 'Position', [0 0 1 1]);
                
                
                % Invoke any set-up code specified by the user
                if nargin>=4 && ~isempty(fcn)
                    if ischar(fcn) && ismethod(obj.Object.hgcontrol, fcn)
                        % Java method specified
                        obj.Object.hgcontrol.(fcn); %#ok<VUNUS>
                    elseif ischar(fcn)
                        % MATLAB function as string - convert to handle
                        % (must be in scope)
                        fcn=strfunc(fcn);
                    end
                    if iscell(fcn)
                        % Cell
                        if numel(fcn)>1
                            % Array with extra arguments
                            fcn{1}(obj.Object, fcn{2:end});
                        else
                            % Just the handle
                            fcn{1}(obj.Object);
                        end
                    elseif isa(fcn, 'function_handle')
                        % Function handle on input
                        fcn(obj.Object);
                    end
                end
                
                % Create the handle list and install resize behaviour
                drawnow();
                obj.hide();
                if ~any(strcmpi(varargin, 'nolayout'))
                    % Manage layouts...
                    setupLayout(jObject);
                    obj.guihandles=getChildren(obj, jObject, obj.includeAll);
                    obj.originalBounds=jObject.getBounds();
                else
                    % ... or not
                    obj.guihandles=getChildren(obj, jObject, obj.includeAll);
                end
                
                if ~any(strcmpi(varargin, 'noresize')) && ~any(strcmpi(varargin, 'nolayout'))
                    %set(obj.Parent, 'ResizeFcn', {@ContainerResize, obj});
                    set(obj.Object, 'ComponentResizedCallback', {@LocalResizeFcn, obj});
                elseif any(strcmpi(varargin, 'noresize'))
                    set(obj.Object.hgcontainer, 'ResizeFcn', {@Stationary});
                    set(obj.Object.hgcontainer, 'Units', 'pixels');
                end
                
                % Done
                set(target, 'DeleteFcn', {@onCleanup, obj});
                obj.N=getLabel([]);
                
                % Process optional arguments
                % guisize
                if nargin<5 || ~any(strcmpi(varargin, 'guisize'))
                    setpixelposition(target, posp);
                elseif originalSize.getWidth()>0 && originalSize.getHeight()>0
                    setpixelposition(target, [posp(1) posp(2) originalSize.getWidth() originalSize.getHeight()]);
                end
                
                if nargin>=5
                    
                    if ~any(strcmpi(varargin, 'hide'))
                        % Hide
                        obj.show();
                    end
                    
                    if any(strcmpi(varargin, 'center')) || any(strcmpi(varargin, 'centre'))
                        % Center
                        obj.setCentral();
                    end
                    
                else
                    
                    obj.show();
                    
                end
                
                set(target, 'Units', 'normalized');
                
                % If we have a Cancel and/or OK button at the top level,
                % set these up by default
                if isfield(obj.guihandles, 'Cancel') &&...
                        obj.guihandles.Cancel.getClass().equals(javax.swing.JButton().getClass());
                    obj.setQueryOnCancel(obj.guihandles.Cancel);
                end
                
                if isfield(obj.guihandles, 'OK') &&...
                        obj.guihandles.OK.getClass().equals(javax.swing.JButton().getClass());
                    obj.setOK(obj.guihandles.OK);
                end
                drawnow();
                
            else
                % JFrame target
                if nargin<3;obj.includeAll=true;end
                obj.Object=GXJFrame(target,'',jObject);
                obj.guihandles=getChildren(obj, jObject, obj.includeAll);
            end
            return
        end
        
        function o=getObject(obj)
            % getObject returns the top component in the hierarchy for
            % this instance
            % Example:
            %       o=getObject(obj);
            o=obj.Object;
            return
        end
        
        function p=getParent(obj)
            % getParent returns the handle for the MATLAB container for
            % this instance
            % Example:
            %       p=getParent(obj);
            p=obj.Parent;
            return
        end
        
        function list=getComponents(obj)
            % getHandleList returns a complete vector of JComponent handles
            % Example:
            %       list=obj.getHandlesList();
            list=obj.handlelist(2:5:end)';
            return
        end
            
        function s=getHandles(obj)
            % getHandles returns a list of component handles
            % in a hierarchical structure
            % Example:
            %       list=obj.getHandlesList();
            % The first field of the structure is always the parent Java
            % component specified at construction. Remaining fields are
            % sorted into alphabetical order.
            s=orderHandleStructure(obj.guihandles);
            return
        end
        
        function [list, idxout]=find(obj, searchitem, property)
            % find method
            %
            % find returns:
            % handle(s) given a field name descriptor string
            % OR
            % the handle(s) for instances with properties matching a specified value
            % OR
            % the handle(s) given a Java class
            % OR
            % the field name descriptor given a handle.
            %
            % Example
            %       list=obj.find(string)
            % returns the handle (or handles) for which string describes the
            % assigned fieldname in the structure returned by getHandles.
            % Alternatively
            %       list=obj.find(clzz)
            % returns a list of handles for items of the specified Java
            % class, e.g. obj.find(javax.swing.JButton().getClass())
            % While
            %       path=obj.find(jObject)
            % returns the the path of the specified object in the
            % structure returned by getHandles as a cell array of
            % strings. 
            
            % NB [path, idx]=obj.find(jObject); is used internally only
            % and returns the index of jObject in obj.handlelist
            
            idxout=[];
            if nargin==2 && ischar(searchitem)
                % Find items(s) with this field name in the getHandles
                % structure
                idx=strcmp(obj.handlelist(1:5:end), searchitem);
                [dumvar, idx]=find(idx); %#ok<ASGLU>
                idx=(idx-1)*5+2;
                list=obj.handlelist(idx);
            elseif nargin==3 && ~islogical(property)
                switch lower(property)
                    case 'fieldname'
                        searchitem=char(searchitem);
                        list=obj.find(searchitem);
                    case 'bordertitle'
                        state=warning('off','GImport:invoke');
                        list=obj.handlelist(2:5:end);
                        results=GImport.run(list,'getBorder');
                        results=results(~cellfun('isempty', results));
                        results=GImport.run(results,'getTitle');
                        warning(state.state,'GImport:invoke');
                        TF=cellfun(@isequal, results, repmat({searchitem}, size(results)));
                        list=list(TF);
                    otherwise
                        state=warning('off','GImport:invoke');
                        if islogical(searchitem)
                            results=GImport.run(obj.handlelist(2:5:end),['is', property]);
                        else
                            results=GImport.run(obj.handlelist(2:5:end),['get', property]);
                        end
                        warning(state.state,'GImport:invoke');
                        TF=cellfun(@isequal, results, repmat({searchitem}, size(results)));
                        list=obj.handlelist(2:5:end);
                        list=list(TF);
                end
            elseif isa(searchitem, 'java.lang.Class')
                if nargin==2 || (nargin==3 && property==false)
                    % Find instance(s) of this class
                    clzzlist=cellfun(@getClass, obj.handlelist(2:5:end), 'UniformOutput', false);
                    TF=cellfun(@isequal, clzzlist, repmat({searchitem}, size(clzzlist)));
                    idx=find(TF);
                    idxout=(idx-1)*5+2;
                    list=obj.handlelist(idxout);
                elseif nargin==3 && property==true
                    clzzlist=cellfun(@getClass, obj.handlelist(2:5:end), 'UniformOutput', false);
                    TF=cellfun(@isequal, clzzlist, repmat({searchitem}, size(clzzlist)));
                    clzzlist=cellfun(@getSuperclass, clzzlist, 'UniformOutput', false);
                    while ~all(cellfun('isempty',clzzlist))
                        TF2=cellfun(@isequal, clzzlist, repmat({searchitem}, size(clzzlist)));
                        TF=TF | TF2;
                        clzzlist=cellfun(@getSuperclass, clzzlist, 'UniformOutput', false, 'ErrorHandler', @returnEmpty);
                    end
                    list=obj.handlelist(2:5:end);
                    list=list(TF);
                end
            elseif ishandle(searchitem)
                % Find the specified item and return the field name.
                jObj=searchitem;
                list={};
                TF=cellfun(@isequal, obj.handlelist, repmat({jObj}, size(obj.handlelist)));
                idxout=find(TF);
                if ~any(TF)
                    list=[];
                else
                    while ~jObj.equals(obj.handlelist{2})
                        TF=[TF(2:end) false];
                        if any(TF)
                            list{end+1}=obj.handlelist{TF};
                        end
                        jObj=handle(jObj.getParent(),'callbackproperties');
                        TF=cellfun(@isequal, obj.handlelist, repmat({jObj}, size(obj.handlelist)));
                    end
                    list=list(end:-1:1);
                end
            else
                throw(MException('GImport:find', sprintf('Unsupported input of class %s', class(searchitem))));
            end
            list=list(:);
            if numel(list)==1
                list=list{1};
            end
            return
            
            function val=returnEmpty(varargin)
                val=[];
                return
            end
            
        end
        
        function s=getValues(obj)
            % getValues returns a structure mimicking that returned by
            % getHandles but containing the values of the components rather
            % than their handles
            % Example
            %           s=getValues(obj);
            % When the Cancel action is activated, these values are stored
            % in the object instance before the components are deleted
            % and can be retrieved by calling getValues.
            if isvalid(obj)
                if isempty(obj.guihandles)
                    s=obj.guivalues;
                    delete(obj);
                else
                    s=findReturnedValues(obj.getHandles());
                end
            else
                s=[];
            end
            return
        end
        
        function setCallback(obj, jObject, callbackstring, varargin)
            % Adds a callback function to an object
            % Use setCallback instead of setting callbacks directly 
            % when a GImport instance is supplied as an input to the 
            % callback of one of its sub-components. This will prevent
            % leaked references the GImport instance when it is destroyed.
            % Example:
            %    setCallback(obj, jObject, callbackstring, arg0, arg1....)
            %  jObect is a Java component handle from GImport instance obj
            %  callbackstring is the name of the callback e.g. 'MouseClickedCallback'
            %  arg0, arg1, are optional arguments to the callback 
            % setCallback invokes
            %       set(jObject, callbackstring, arg0, arg1...);
            if ~any(cell2mat(strfind(obj.ActiveCallbackList, callbackstring)))
                obj.ActiveCallbackList{end+1}=callbackstring;
            end
            if iscell(jObject)
                jObject=[jObject{:}];
            end
            if iscell(varargin{1})
                set(jObject, callbackstring, varargin{1});
            else
                set(jObject, callbackstring, varargin);
            end
            return
        end
        
        function setCancel(obj, jObject, fcn)
            % setCancel sets up a Cancel component
            % Example:
            %       obj.setCancel(jObject);
            %       obj.setCancel(jObject, fcn);
            % jObject can be any subcomponent of obj, typically a button, 
            % that has a MouseClickedCallback.
            % If fcn is specified it should be the handle of a function that
            % takes care of any deletions required and should be declared as
            %           function fcn(jObject, EventData, obj);
            % The default callback issues a uiresume() call to MATLAB
            if nargin==3
                obj.setCallback(jObject, 'MouseClickedCallback', {fcn, obj})
            else
                obj.setCallback(jObject, 'MouseClickedCallback', {@CancelAction, obj});
            end
            return
            
            function CancelAction(jObject, EventData, obj)
                % Internal function
                if ~isempty(obj.linkedObjects)
                    for k=1:numel(obj.linkedObjects)
                        obj.linkedObjects{k}.delete();
                    end
                end
                obj.delete();
                uiresume();
                return
            end    
        end
        
        
        function setQueryOnCancel(obj, jObject, fcn)
            % setQueryOnCancel sets up a Cancel component
            % Example:
            %       obj.setQueryOnCancel(jObject);
            %       obj.setQueryOnCancel(jObject, fcn);
            % jObject can be any subcomponent of obj, typically a button,
            % that has a MouseClickedCallback.
            % If fcn is specified it should be the handle of a function that
            % takes care of any deletions required and should be declared as
            %           function fcn(jObject, EventData, obj);
            % setQueryOnCancel will display a YES/NO dialog before running
            % the deletion code.
            % The default callback issues a uiresume() call to MATLAB
            %
            if nargin==3
                obj.setCallback(jObject, 'MouseClickedCallback', {fcn, obj})
            else
                obj.setCallback(jObject, 'MouseClickedCallback', {@CancelAction, obj});
            end
            
            return
            
            function CancelAction(jObject, EventData, obj)
                % Internal function
                answer=QueryCancellation(obj.Object.hgcontrol);
                if answer==javax.swing.JOptionPane.YES_OPTION
                    if ~isempty(obj.linkedObjects)
                        for k=1:numel(obj.linkedObjects)
                            obj.linkedObjects{k}.delete();
                        end
                    end
                    obj.delete();
                    uiresume();
                end
                return
            end
        end
        
        function varargout=setOK(obj, jObject, fcn)
            % setOK sets up an OK component
            % Example:
            %       obj.setOK(jObject);
            %       obj.setOK(jObject, fcn);
            % jObject can be any subcomponent of obj, typically a button, 
            % that has a MouseClickedCallback.
            % If fcn is specified it should be the handle of a function that
            % takes care of any deletions as well as returning the values
            % from the GUI in obj. fcn should be declared as
            %           function fcn(jObject, EventData, obj);
            % setOK deleted the GUI and handles in obj, but does not delete
            % obj. The values of any GUI components at the time of deletion
            % will still be available in user code by calling
            % obj.getValues().
            % The default callback issues a uiresume() call to MATLAB
            if nargout>0
                % With no input, calling setOK returns a handle to the
                % internal OKAction callback. The handle can be used to invoke
                % the standard callback at the end of a custom-callback to
                % ensure clean deletion of the GUI.
                varargout{1}=@OKAction;
                return
            end
            if nargin==3
                obj.setCallback(jObect, 'MouseClickedCallback', {fcn, obj})
            else
                obj.setCallback(jObject, 'MouseClickedCallback', {@OKAction, obj});
            end
            return
            
            function OKAction(jObject, EventData, obj)
                % Internal function
                obj.guivalues=obj.getValues();
                obj.guihandles=[];
                set(obj.Parent, 'DeleteFcn', []);
                delete(obj.Parent);
                uiresume();
                return
            end
        end
        
        
        function revalidate(obj)
            % revalidate method
            % Call this if you add components to the hierarchy within
            % MATLAB adn want them included in the active layout
            % management/handles list
            % Example:
            %       obj.revalidate();
            drawnow();
            getLabel(obj.N);
            obj.handlelist=[];
            obj.guihandles=getChildren(obj, obj.Object.hgcontrol, obj.includeAll);
            setupLayout(obj.Object.hgcontrol);
            obj.N=getLabel([]);
            return
        end
        
        
        function varargout=invoke(obj, methodname, varargin)
            % invoke invokes the specified method on all components
            % Example
            %       obj.invoke(methodname, arg0, arg1...)
            % invoke ignores errors if the method does not exist for a
            % component and issues a warning if any other error occurs, e.g. if
            % inappropriate arguments are supplied, in which case a warnings is
            % issued for each component on which the method fails.
            n=1;
            result=cell(numel(obj.handlelist)/5,1);
            for k=2:5:numel(obj.handlelist)
                try
                    result{n}=obj.handlelist{k}.(methodname)(varargin{:});
                catch ex
                    switch ex.identifier
                        case 'MATLAB:Java:InvalidMethod'
                        case 'MATLAB:noSuchMethodOrField'
                        case 'MATLAB:unassignedOutputs'
                        otherwise
                            warning('GImport:invoke', '%s failed on %s with \n"%s"',...
                                methodname, char(obj.handlelist{k}.getClass()), ex.message);
                    end
                    result{n}=[];
                end
                n=n+1;
            end
            varargout{1}=result;
            return
        end
        
        function invokeEDT(obj, methodname, varargin)
            % invokeEDT invokes the specified method on all components
            % Example
            %       obj.invokeEDT(methodname, arg0, arg1...)
            % invokeEDT ignores errors if the method does not exist for a
            % component and issues a warning if any other error occurs, e.g. if
            % inappropriate arguments are supplied, in which case a warnings is
            % issued for each component on which the method fails.
            % methodname is invoked explicitly on the EDT
            for k=2:5:numel(obj.handlelist)
                try
                    javaMethodEDT(methodname, obj.handlelist{k}, varargin{:});
                catch ex
                    switch ex.identifier
                        case 'MATLAB:Java:InvalidMethod'
                        case 'MATLAB:noSuchMethodOrField'
                        otherwise
                            warning('GImport:invokeEDT','%s failed on %s with \n"%s"',...
                                methodname, char(obj.handlelist{k}.getClass()), ex.message);
                    end
                end
            end
            return
        end
        
        function setDragEnabled(obj, varargin)
            % setDragEnabled sets the drag state for all compenents that
            % are capable of providing drag support
            % Example
            %       obj.setDragEnabled(flag)
            % where flag is true or false.
            GImport.putDragEnabled(obj.getComponents(), varargin{:})
            return
        end
        
        
        function delete(obj)
            % delete methods
            % Example
            %        obj.delete()
            if isa(obj.Object, 'javahandle_withcallbacks.javax.swing.JFrame')
                obj.Object.dispose();
            else
                obj.removeCallbacks();
                if ishandle(obj.Parent) && strcmp(get(obj.Parent, 'type'), 'figure')
                    % Do not delete figure - a subsequent uiresume will create one if no
                    % figures exist
                    delete(obj.Object);
                elseif ishandle(obj.Parent)
                    % Delete associated uipanels etc.
                    delete(obj.Parent);
                end
            end
        end
        
        function removeCallbacks(obj)
            % This allows deletion without memory leaks due to references
            % in callbacks
            % Example
            %     obj.removeCallbacks(obj)
            list=obj.ActiveCallbackList;
            if ~isempty(list)
                objectList=obj.getComponents();
                if ~isempty(objectList)
                    objectList=[objectList{:}];
                    TF=GImport.run(objectList, 'isValid');
                    objectList=objectList(logical([TF{:}]));
                    for k=1:numel(list)
                        try
                            set(objectList, list{k}, []);
                        catch
                        end
                    end
                end
            end
            return
        end
        
        
        % Linked object manangement
        function createLink(obj, object)
            if ~any(cellfun(@isequal, obj.linkedObjects, repmat({object}, size(obj.linkedObjects))))
                obj.linkedObjects{end+1}=object;
            end
            return
        end
        
        function removeLink(obj, object)
            TF=cellfun(@isequal, obj.linkedObjects, repmat({object}, size(obj.linkedObjects)));
            if any(TF)
                obj.linkedObjects{TF}=[];
            end
            return
        end
        
        function list=getLinks(obj)
            list=obj.linkedObjects;
            return
        end
        
        % Convenience methods for setting the MATLAB position property
      
        function setPosition(obj, pos, requiredunits)
            if nargin<3
                requiredunits='normalized';
            end
            units=get(obj.Parent, 'Units');
            set(obj.Parent, 'Units', requiredunits);
            set(obj.Parent, 'Position', pos);
            set(obj.Parent, 'Units', units);
            return
        end
        
        function pos=getPosition(obj, requiredunits)
            if nargin<3
                requiredunits='normalized';
            end
            units=get(obj.Parent, 'Units');
            set(obj.Parent, 'Units', requiredunits);
            pos=get(obj.Parent, 'Position');
            set(obj.Parent, 'Units', units);
            return
        end
        
        function setPixelPosition(obj, pos)
            setpixelposition(obj.Parent, pos);
            return
        end
        
        function pos=getPixelPosition(obj)
            pos=getpixelposition(obj.Parent);
            return
        end
        
        function setCentral(obj)
            % TODO: Check 2 monitor support
            p=get(obj.Parent, 'parent');
            if p>0
                ppos=getpixelposition(p);
            else
                ppos=get(0, 'ScreenSize');
            end
            xcenter=ppos(3)/2;
            ycenter=ppos(4)/2;
            pos=getpixelposition(obj.Parent);
            if pos(3)>ppos(3) || pos(4)>ppos(4)
                setpixelposition(obj.Parent, [1 1 ppos(3) ppos(4)]);
            else
                setpixelposition(obj.Parent, [xcenter-pos(3)/2, ycenter-pos(4)/2 pos(3) pos(4)]);
            end
            drawnow()
            return
        end
        
        
        % Convenience methods for combining 2 GUIs and linking them
        function alignToEast(obj, extraObj)
            if ~strcmp(get(obj.Parent, 'type'), 'figure') &&...
                    ~strcmp(get(extraObj.Parent, 'type'), 'figure') &&...
                    get(obj.Parent,'parent')==get(extraObj.Parent,'parent')
                obj.hide();
                extraObj.hide();
                pos1=getpixelposition(obj.Parent);
                pos2=getpixelposition(extraObj.Parent);
                %pos1(1)=max(1, pos1(1)-xoffset);
                setpixelposition(obj.Parent, pos1);
                ppos=getpixelposition(get(obj.Parent,'parent'));
                if pos1(1)+pos1(3)+pos2(3)+1>ppos(3)
                    pos2(3)=ppos(3)-pos1(1)-pos1(3)-1;
                end
                setpixelposition(extraObj.Parent, [pos1(1)+pos1(3), pos1(2), pos2(3)+1, pos1(4)]);
                obj.show();
                extraObj.show();
                return
            end
        end
        
        function alignToSouth(obj, extraObj)
            if ~strcmp(get(obj.Parent, 'type'), 'figure') &&...
                    ~strcmp(get(extraObj.Parent, 'type'), 'figure') &&...
                    get(obj.Parent,'parent')==get(extraObj.Parent,'parent')
                obj.hide();
                extraObj.hide();
                pos1=getpixelposition(obj.Parent);
                pos2=getpixelposition(extraObj.Parent);
                % Shift ypos
                yoffset=pos2(4)/2;
                pos1(2)=max(1, pos1(2)+yoffset);
                setpixelposition(obj.Parent, pos1);
                if pos1(1)<1
                    pos1(1)=1;
                end
                setpixelposition(extraObj.Parent, [pos1(1), pos1(2)-pos2(4)-1, pos1(3), pos1(4)]);
                obj.show();
                extraObj.show();
                return
            end
        end
        
        
        
        % Control the visibility
        
        function show(obj)
            set(obj.Object.hgcontainer, 'Visible', 'on');
            return
        end
        
        function hide(obj)
            set(obj.Object.hgcontainer, 'Visible', 'off');
            return
        end
        
    end%[METHODS}
    
    methods(Static)
        
        function setExcludedClassses(in)
            % setExcludedClasssClasses replaces the list of objects
            % whose components will be excluded from active layout management
            % Example
            %       GImport.setExcludedClasses(list)
            % where list is a cell array of java.lang.Class objects
            % Note that any subclasses of the class will also be excluded.
            ExcludedClassManager(in);
            return
        end
        
        function list=getExcludedClasses()
            % getExcludedClasses returns the list of objects % whose
            % components will be excluded from active layout management
            % Example
            %       list=GImport.getExcludedClasses()
            % where list is a cell array of java.lang.Class objects
            % Note that any subclasses of the class will also be excluded.
            list=ExcludedClassManager();
            return
        end
        
        function addExcludedClass(in)
            % addExcludedClass adds a layout to the list of managed
            % layouts
            % Example:
            %       GImport.addExcludedClass(clzz);
            list=ExcludedClassManager();
            for k=1:numel(list)
                if list(k).equals(in)
                    % Already in list
                    return
                end
            end
            list=[list;in];
            ExcludedClassManager(list);
            return
        end
        
        function removeExcludedClass(in)
            % removeExcludedClass removes a layout to the list of managed
            % layouts
            % Example:
            %    GImport.removeExcludedClass(clzz);
            list=ExcludedClassManager();
            for k=1:numel(list)
                if list(k).equals(in)
                    list(k:end-1)=list(k+1:end);
                    list=list(1:end-1);
                    break;
                end
            end
            ExcludedClassManager(list);
            return
        end
        
        function setManagedLayoutList(in)
            % setManagedList replaces the list of actively managed layouts
            % Example
            %       GImport.setManagedLayoutList(list)
            % where list is a cell array of layouts (as strings)
            LayoutListManager(in);
            return
        end
        
        function list=getManagedLayoutList()
            % getManagedList returns the list of actively managed layouts
            % Example
            %       list=GImport.getManagedLayoutList()
            % where list is a cell array of layouts (as strings)
            list=LayoutListManager();
            return
        end
        
        function addManagedLayout(in)
            % addManagedLayout adds a layout to the list of managed
            % layouts
            % Example:
            %       GImport.addManagedLayout('java.awt.FlowLayout');
            list=LayoutListManager();
            list{end+1}=in;
            LayoutListManager(list);
            return
        end
        
        function removeManagedLayout(in)
            % removeManagedLayout removes a layout to the list of managed
            % layouts
            % Example:
            %    GImport.removeManagedLayout('java.awt.FlowLayout');
            list=LayoutListManager();
            TF=strcmp(list,in);
            list(TF)=[];
            LayoutListManager(list);
            return
        end
        
        function val=getValue(jObject)
            % gValue finds the "value" for a Java object
            % Example
            %      GImport.getValue(jObject)
            % returns the "value" of the JComponent jObject.
            try
                val=jObject.getValue();
            catch %#ok<CTCH>
                try
                    val={jObject.getSelectedIndex(), jObject.getSelectedValue()};
                        if ~isempty(str2num(val{2}))
                            val{2}=str2num(val{2});
                        end
                catch %#ok<CTCH>
                    try
                        val={jObject.getSelectedIndex(), jObject.getSelectedItem()};
                        if ~isempty(str2num(val{2}))
                            val{2}=str2num(val{2});
                        end
                    catch %#ok<CTCH>
                        try
                            val=jObject.isSelected();
                        catch %#ok<CTCH>
                            try
                                val=jObject.getSelectionPaths();
                                if numel(val)==1
                                    val=val(1);
                                end
                            catch
                                try
                                    val=jObject.getColor();
                                catch %#ok<CTCH>
                                    try
                                        val=char(jObject.getText());
                                    catch %#ok<CTCH>
                                        val=[];
                                    end
                                end
                            end
                        end
                    end
                end
            end
            % Convert char to numeric values if possible
            if ischar(val)
                n=str2num(val); %#ok<ST2NM>
                if ~isempty(n)
                    val=n;
                end
            end
            return
        end
        
        function varargout=setIcon(icon)
            % setIcon sets the icon for use in the QueryOnCancel panel
            % Example:
            %           GImport.setIcon(icon);
            persistent cancelicon
            if nargin==1
                cancelicon=icon;
            else
                if isempty(cancelicon)
                    cancelicon=javax.swing.ImageIcon();
                end
                varargout{1}=cancelicon;
            end
            return
        end
        
        function icon=getIcon()
            % getIcon returns the icon used in the QueryOnCancel panel
            % Example:
            %           GImport.getIcon();
            icon=GImport.setIcon();
            return
        end
        
        function varargout=run(h, methodname, varargin)
            % run invokes a specified method on a list of components
            % Example
            %       obj.invoke(h, methodname, arg0, arg1...)
            % run ignores errors if the method does not exist for a
            % component and issues a warning if any other error occurs, e.g. if
            % inappropriate arguments are supplied, in which case a warning is
            % issued for each component on which the method fails.
            if iscell(h)
                h=[h{:}];
            end
            result=cell(numel(h),1);
            for k=1:numel(h)
                try
                    result{k}=h(k).(methodname)(varargin{:});
                catch ex
                    switch ex.identifier
                        case 'MATLAB:Java:InvalidMethod'
                        case 'MATLAB:noSuchMethodOrField'
                        case 'MATLAB:unassignedOutputs'
                        otherwise
                            warning('GImport:invoke', '%s failed on %s with \n"%s"',...
                                methodname, char(h(k).getClass()), ex.message);
                    end
                    result{k}=[];
                end
            end
            varargout{1}=result;
            return
        end
        
        function runEDT(h, methodname, varargin)
            % runEDT invokes the specified method on a list of components
            % Example
            %       obj.runEDT(h, methodname, arg0, arg1...)
            % runEDT ignores errors if the method does not exist for a
            % component and issues a warning if any other error occurs, e.g. if
            % inappropriate arguments are supplied, in which case a warnings is
            % issued for each component on which the method fails.
            % methodname is invoked explicitly on the EDT
            if iscell(h)
                h=[h{:}];
            end
            for k=1:numel(h)
                try
                    javaMethodEDT(methodname, h(k), varargin{:});
                catch ex
                    switch ex.identifier
                        case 'MATLAB:Java:InvalidMethod'
                        case 'MATLAB:noSuchMethodOrField'
                        otherwise
                            warning('GImport:invokeEDT','%s failed on %s with \n"%s"',...
                                methodname, char(h(k).getClass()), ex.message);
                    end
                end
            end
            return
        end
        
        function putDragEnabled(h, flag, propertyname)
            % putDragEnabled sets the drag state for component(s)
            % Example
            %       obj.putDragEnabled(h, flag)
            %       obj.putDragEnabled(h, flag, propertyname)
            % where h            is a Java component handle, array of handles or
            %                    cell array of handles
            %       flag         is true or false.
            %       propertyname if specified, is the name of a bound
            %                    property. A TransferHandler will be
            %                    created to allow this property to be drag
            %                    and dropped. If propertyname is 'default',
            %                    a Swing default handler for each
            %                    component will be installed.
            % 
            if iscell(h)
                h=[h{:}];
            end
            if islogical(flag)
                GImport.runEDT(h, 'setDragEnabled', flag);
                if nargin==3
                    if ~strcmpi(propertyname,'default')
                        tf=javax.swing.TransferHandler(propertyname);
                        GImport.runEDT(h, 'setTransferHandler', tf);
                    elseif strcmpi(propertyname,'default')
                        % Restore default behaviour
                        for k=1:numel(h)
                            try
                                % Get a TransferHandler by relection from a new
                                % instance
                                tf=h(k).getClass.newInstance().getTransferHandler();
                            catch ex
                                tf=[];
                            end
                            if ~isempty(tf)
                                javaMethodEDT('setTransferHandler', h(k), tf);
                            end
                        end
                    end
                end
            else
                throw(MException('GImport:setDragEnabled', 'Logical flag expected on input'));
            end
            return
        end
        
        function putDropAction(h, fcn)
            % putDropEnabled enables/disables components for a drop
            % Example:
            %       putDropEnabled(h, flag, fcn)
            % where  h     is a Java component handle, array of handles or
            %              cell array of handles
            %        fcn   is the handle of a function that will be invoked
            %              when a drop is made.
            %        fcn will receive 5 inputs
            %               the handle of the drag source
            %               the handle of the drop target
            %               the last drag event
            %               the drop event
            %               the java.awt.dnd.DropTarget instance
            % The handle of the drag source will be empty if the drag is
            % not from a component that has been drag enabled through
            % setDragEnabled or putDragEnabled.
            if iscell(h)
                h=[h{:}];
            end
            if nargin<2
                % For debug only
                fcn=@defaultDrop;
            end
            for k=1:numel(h)
                try
                    if isempty(fcn)
                        h(k).setDropTarget([]);
                    else
                        try
                        dnd=dndsupport.DNDAssistant();
                        h(k).setDropTarget(dnd);
                        dnd=handle(dnd, 'callbackProperties');
                        set(dnd, 'DropCallback', {@LocalDropCallback, fcn});
                        %set(dnd, 'DragEnterCallback', @LocalDragEnterCallback);
                        catch ex
                            switch ex.identifier
                                case 'MATLAB:undefinedVarOrClass'
                                    warning('GImport:putDropAction', 'Drops are only supported with the Project Waterloo jar file installed.\nputDropAction call ignored.');
                                otherwise
                                    rethrow(ex);
                            end
                        end
                    end
                catch ex
                    switch ex.identifier
                        case 'MATLAB:noSuchMethodOrField'
                        otherwise
                            rethrow(ex);
                    end
                end
            end
            return
        end
    end
    
end

%--------------------------------------------------------------------------
% HELPER FUNCTIONS
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function hStruct=getChildren(obj, jObject, flag, hStruct, fname)
%--------------------------------------------------------------------------
% getChildren recursive search of the java object hierarchy

drawnow();

if nargin<5
    fname=getLabel(jObject, []);
end


thisHandle=handle(javaObjectEDT(jObject), 'callbackproperties');
obj.handlelist{end+1}=fname;
obj.handlelist{end+1}=thisHandle;
obj.handlelist{end+1}=java.awt.Rectangle(thisHandle.getBounds());
obj.handlelist{end+1}=thisHandle.getParent();
if (~isempty(obj.handlelist{end}))
    obj.handlelist{end+1}=obj.handlelist{end}.getInsets();
else
    obj.handlelist{end+1}=[];
end
    
hStruct=struct(fname, thisHandle);

h=jObject.getComponents();
for k=1:numel(h)
    if (h(k).getComponentCount()==0) && isa(h(k), 'java.awt.Component')
        thisHandle=handle(javaObjectEDT(h(k)), 'callbackproperties');
        fname2=getLabel(h(k), hStruct);
        obj.handlelist{end+1}=fname2;
        obj.handlelist{end+1}=thisHandle;
        obj.handlelist{end+1}=java.awt.Rectangle(thisHandle.getBounds());
        obj.handlelist{end+1}=thisHandle.getParent();
        obj.handlelist{end+1}=obj.handlelist{end}.getInsets();
        nm=char(thisHandle.getName());
        if flag==true || (~isempty(nm) && (strcmp(nm(1),'$') || strcmp(nm(1),'+')))
            hStruct.(fname2)=thisHandle;
        end
    else
        fname2=getLabel(h(k), hStruct);
        nm=char(h(k).getName());
        if flag==true || (~isempty(nm) && strcmp(nm(1),'+'))
            hStruct.(fname2)=getChildren(obj, h(k), true, hStruct, fname2);
            if numel(fieldnames(hStruct.(fname2)))==1
                hStruct.(fname2)=hStruct.(fname2).(fname2);
            end
        elseif flag==true || (~isempty(nm) && strcmp(nm(1),'$'))
            hStruct.(fname2)=getChildren(obj, h(k), false, hStruct, fname2);
            if numel(fieldnames(hStruct.(fname2)))==1
                hStruct.(fname2)=hStruct.(fname2).(fname2);
            end
        else
            s=getChildren(obj, h(k), false, hStruct);
            fnames=fieldnames(s);
            if numel(fnames)>1
                for j=2:numel(fnames)
                    hStruct.(fnames{j})=s.(fnames{j});
                end
            end
        end
    end
end
return
end

%--------------------------------------------------------------------------
function setupLayout(jObject, parent)
%--------------------------------------------------------------------------
% setupLayout manages the actively managed layouts
if nargin<2
    parent=jObject.getParent();
end
if isManagedLayout(jObject) && isIncludedComponentsClass(parent)
     %layout=parent.getLayout();
     %if ~isa(layout, 'javax.swing.SpringLayout')
        layout=javax.swing.SpringLayout();
     %end
else
    layout=[];
end
h=jObject.getComponents();
for k=numel(h):-1:1
    if isa(jObject, 'javax.swing.JViewport') ||...
            ~isempty(javax.swing.SwingUtilities.getAncestorOfClass(javax.swing.JViewport().getClass(), jObject))
        return
    else
        if (h(k).getComponentCount()==0) && isa(h(k), 'java.awt.Component')
            if ~isempty(layout)
                putConstraints(h(k), layout);
            end
        else
            if ~isempty(layout)
                putConstraints(h(k), layout);
            end
            setupLayout(h(k), jObject);
        end
    end
end
if ~isempty(layout)
    jObject.setLayout(layout);
end
return
end

%--------------------------------------------------------------------------
function ContainerResize(hObject, EventData, obj)
%--------------------------------------------------------------------------
obj.Object.revalidate();
return
end

%--------------------------------------------------------------------------
function LocalResizeFcn(jObject, EventData, obj)
%--------------------------------------------------------------------------
drawnow();
currentBounds=obj.handlelist{2}.getBounds();
xscale=currentBounds.getWidth()/obj.handlelist{3}.getWidth();
yscale=currentBounds.getHeight()/obj.handlelist{3}.getHeight();
for k=numel(obj.handlelist)-3:-5:2
    parent=obj.handlelist{k+2};
    if ~isempty(parent)
        putConstraints(parent, parent.getLayout(), obj.handlelist{k}, obj.handlelist{k+1},...
            obj.handlelist{k+3}, xscale, yscale);
    end
end
jObject.revalidate();
% jObject.getParent().repaint();
% drawnow();
return
end



%--------------------------------------------------------------------------
function putConstraints(parent, layout, jObject, bounds, originalInsets, xscale, yscale)
%--------------------------------------------------------------------------
% Updates the spring layout
% This could eventually be implemented using Java


if nargin>2 && (bounds.getWidth()==0 || bounds.getHeight()==0)
    return
end

if strcmp(char(class(layout)),'javax.swing.SpringLayout')
    

    if nargin<3
        % Used during set up only
        % With resize all arguments will be supplied on input
        jObject=parent;
        parent=jObject.getParent();
        bounds=jObject.getBounds();
        X=bounds.getX();
        Y=bounds.getY();
        xscale=1;
        yscale=1;
    else
        X=bounds.getX();
        Y=bounds.getY();
        X=X-originalInsets.left;
        Y=Y-originalInsets.top;
    end
    
    pbounds=parent.getBounds();
     
    %Note size is determined by the layout constraints- not object size settings
    if parent.getComponentCount()==1 &&...
            jObject.getPreferredSize().getWidth()<pbounds.getWidth() &&...
            jObject.getPreferredSize().getHeight()<pbounds.getHeight()
        % If we have just one component, and it fits, center it - better appearance e.g.
        % with components surrounding by a titled panel
        layout.removeLayoutComponent(jObject);
        layout.putConstraint(javax.swing.SpringLayout.HORIZONTAL_CENTER, jObject, 0,...
            javax.swing.SpringLayout.HORIZONTAL_CENTER, parent);
        layout.putConstraint(javax.swing.SpringLayout.VERTICAL_CENTER, jObject, 0,...
            javax.swing.SpringLayout.VERTICAL_CENTER, parent);
    else
        % More than one component

        topmargin=Y*yscale;
        height=(bounds.getHeight()*yscale);
        leftmargin=X*xscale;
        width=bounds.getWidth()*xscale;
        
        layout.removeLayoutComponent(jObject);
        layout.putConstraint(javax.swing.SpringLayout.NORTH, jObject, topmargin,...
            javax.swing.SpringLayout.NORTH, parent);
        layout.putConstraint(javax.swing.SpringLayout.WEST, jObject, leftmargin,...
            javax.swing.SpringLayout.WEST, parent);
        
        if strcmp(class(jObject),'javahandle_withcallbacks.javax.swing.JSpinner')
            % Maintain original height
            layout.putConstraint(javax.swing.SpringLayout.EAST, jObject, width,...
                javax.swing.SpringLayout.WEST, jObject);
        else
            layout.putConstraint(javax.swing.SpringLayout.EAST, jObject, width,...
                javax.swing.SpringLayout.WEST, jObject);
            layout.putConstraint(javax.swing.SpringLayout.SOUTH, jObject, height,...
                javax.swing.SpringLayout.NORTH, jObject);
        end
    end
    
    
    try
        jObject.revalidate();
    catch %#ok<CTCH>
    end
    
end
return
end

%--------------------------------------------------------------------------
function flag=isManagedLayout(jObject)
%--------------------------------------------------------------------------
% Determines whether this layout should be replaced with a SpringLayout
layout=jObject.getLayout();
if isempty(layout)
    if ismethod(jObject, 'revalidate')
        flag=true;
    else
        flag=false;
    end
    return
end
clayout=char(class(layout));
if any(strcmp(LayoutListManager(), clayout))
    flag=true;
else
    flag=false;
end
return
end

%--------------------------------------------------------------------------
function flag=isIncludedComponentsClass(jObject)
%--------------------------------------------------------------------------
list=GImport.getExcludedClasses();
flag=true;
inputclzz=jObject.getClass();
for k=1:numel(list)
    clzz=inputclzz;
    str=clzz.toString();
    while ~str.equals(java.lang.String('class javax.swing.JComponent')) &&...
            ~str.equals(java.lang.String('class java.lang.Object'))
        if clzz.equals(list(k))
            flag=false;
            return
        else
            clzz=clzz.getSuperclass();
            str=clzz.toString();
        end
    end
end
end


%--------------------------------------------------------------------------
function ret=LayoutListManager(in)
%--------------------------------------------------------------------------
persistent list;
switch nargin
    case 0
        if isempty(list)
            list=LayoutListManager([]);
        end
        ret=list;
    case 1
        if isempty(in)
            list={'java.awt.FlowLayout';...
                'java.awt.BoxLayout';...
                'java.awt.GridBagLayout';...
                'java.awt.GridLayout';...
                'javax.swing.GroupLayout';...
                'javax.swing.SpringLayout';...
                'com.jgoodies.forms.layout.FormLayout';...
                'org.jdesktop.swingx.HorizontalLayout';...
                'org.jdesktop.swingx.VerticalLayout';...
                'org.netbeans.lib.awtextra.AbsoluteLayout';...
                'org.jdesktop.layout.GroupLayout';...
                'com.intellij.uiDesigner.core.GridLayoutManager';...
                'net.miginfocom.swing.MigLayout'};
            ret=list;
        else
            list=in;
        end
end
return
end

%--------------------------------------------------------------------------
function ret=ExcludedClassManager(in)
%--------------------------------------------------------------------------
persistent list;
switch nargin
    case 0
        if isempty(list)
            list=ExcludedClassManager([]);
        end
        ret=list;
    case 1
        if isempty(in)
            list=[javax.swing.JSplitPane().getClass();...
                javax.swing.JViewport().getClass(),...
                javax.swing.JTabbedPane().getClass()];
            ret=list;
        else
            list=in;
        end
end
return
end

%--------------------------------------------------------------------------
function str=getLabel(jObject, s)
%--------------------------------------------------------------------------
% Finds or creates a field label for use in obj.guihandles
persistent n;
if nargin==1 && isempty(jObject)
    str=n;
    return
end
if nargin==1 && isnumeric(jObject)
    n=jObject;
    return
end
str=char(jObject.getName());
if isempty(str)
    %If empty, try string
    try
        str=char(jObject.getLabel());
    catch
        try
            str=char(jObject.getText());
        catch
            str=[];
        end
    end
end
if isempty(str) || str(1)==32
    % Get the class name
    str=class(jObject);
    idx=strfind(str,'.');
    str=str(idx(end)+1:end);
end
switch lower(str)
    case 'cancel'
        str='$Cancel';
    case 'ok'
        str='$OK';
end
str=MakeFieldName(str);
try
if strcmp(str(1),'$') || strcmp(str(1),'+')
    specialFlag=str(1);
    str=str(2:end);
else
    specialFlag='';
end
catch
    z=1;
end
str=genvarname(str);
if isstruct(s) && isfield(s, str)
    str=[str '_' num2str(n)];
    n=n+1;
end
if ~isempty(specialFlag)
    jObject.setName([specialFlag str]);
else
    jObject.setName(str);
end
return
end

%--------------------------------------------------------------------------
function str=MakeFieldName(str)
%--------------------------------------------------------------------------
% MakeFieldName helper function
% str=MakeFieldName(str)
% removes spaces and anything in brackets from string str the calls
% genvarname to get a valid field name
str=str((~isspace(str)));
idx=strfind(str,'(');
if ~isempty(idx)
    str=str(1:idx-1);
end
return
end

%--------------------------------------------------------------------------
function s=findReturnedValues(s)
%--------------------------------------------------------------------------
% findReturnedValues: recursive routine to find values of all objects
fields=fieldnames(s);
for k=1:numel(fields)
    if isstruct(s.(fields{k}))
        s.(fields{k})=findReturnedValues(s.(fields{k}));
    else
        s.(fields{k})=GImport.getValue(s.(fields{k}));
    end
end
return
end

%--------------------------------------------------------------------------
function s=orderHandleStructure(s)
%--------------------------------------------------------------------------
if isempty(s)
    return
end
fields=fieldnames(s);
for k=2:numel(fields)
    if isstruct(s.(fields{k}))
        s.(fields{k})=orderHandleStructure(s.(fields{k}));
    end
end
[a b]=sort(fields);
perm=[1 b(b~=1).'];
s=orderfields(s, perm);
return
end

%--------------------------------------------------------------------------
function onCleanup(hObj, EventData, obj)
%--------------------------------------------------------------------------
set(hObj, 'DeleteFcn', []);
if isvalid(obj)
    delete(obj);
end
return
end

%--------------------------------------------------------------------------
function answer=QueryCancellation(hObject)
%--------------------------------------------------------------------------
answer=javax.swing.JOptionPane.showConfirmDialog(hObject,...
    javaObjectEDT(javax.swing.JLabel('Do you really want to cancel?')),...
    'Cancel process?',...Item 4
    javax.swing.JOptionPane.YES_NO_OPTION,...
    javax.swing.JOptionPane.QUESTION_MESSAGE,...
    GImport.getIcon());
return
end


%--------------------------------------------------------------------------
function LocalDropCallback(dropTo, dropEvent, fcn)
%--------------------------------------------------------------------------
fcn(dropTo.getComponent(), dropEvent.getSource(), dropEvent);
return
end

%--------------------------------------------------------------------------
function defaultDrop(dropTo, DNDAssistantInstance, dropEvent)
%--------------------------------------------------------------------------
disp(DNDAssistantInstance.getFlavors());
disp(DNDAssistantInstance.getData());
return
end

function Stationary(hObj, EventData)
return
end
