classdef GXFigure < hgsetget
% GXFigure provides a MATLAB OOP wrapper for Project Waterloo graphics.
% Examples:
%   f=GXFigure()
%   f=GXFigure(n)
% create MATLAB figures that can host both MATLAB and Waterloo Java-based
% graphics.
% 


    properties
        Parent;
        CurrentAxes=[];
    end
    

    properties (Hidden=true)
        % For a GXFigure, components will contain a java.util.LinkedHashMap
        % that maintains a crossreference between the subplot number and the
        % handle. Subplot numbers of NaN, indicate that a subplot was added
        % with user-specified coordinates rather than being added to the
        % standard grid.
        Components;
    end
    
    methods
        
        function obj=GXFigure(n)
            if nargin<1
                obj.Parent=figure();
            else
               obj.Parent=figure(n);
            end
            set(obj.Parent, 'Color', 'w');
            set(obj.Parent, 'UserData', {obj});
            obj.setupMenu();
            obj.Components=java.util.LinkedHashMap(); 
        end
        
        function setupMenu(obj)
            % setupMenu changes the callbacks for selected MATLAB figure
            % uicontrols to provide support for Waterloo graphics.
            
            % Change the File->Save menu action
            drawnow();
            h=findall(obj.Parent, 'Tag', 'figMenuFileSave');
            set(h, 'Callback', {@menuSave, obj.Parent});
            % Change the File->Open menu action
            h=findall(obj.Parent, 'Tag', 'figMenuOpen');
            set(h, 'Callback', @menuOpen)
            
            % Change the File->Save Toolbar button action
            button=MUtilities.getSaveFigureButton(obj.Parent);
            if ~isempty(button)
                button.setEnabled(false);
            end
            button=MUtilities.getOpenFileButton(obj.Parent);
            if ~isempty(button)
                button.setEnabled(false);
            end
        end
        
        function obj=double(obj)
            return
        end
        
        
        function parent=getParent(obj)
            parent=obj.Parent;
            return
        end
        

        function newObj=save(obj, fileName, showProgress)
            % Save function for GXFigures.
            % Note that saving a figure is a destructive process: the
            % existing GXFigure figure and MATLAB figure are deleted 
            % and the saved clone is then opened. The GXFigure instance will
            % change and the MATLAB figure handle may change.
            % Examples:
            %       newObj=save(obj, fileName)
            %       newObj=save(obj, fileName, showProgress)
            % where:
            %       obj         is the GXFigure instance
            %       fileName    is a string specifying the fully qualified
            %                   path
            %       showProgress if true, shows a dialog during the save
            %
            % Returns
            %
            % Save creates a folder (not a file) with .kclfig as an
            % extension.
            % The contents of the folder are a MATLAB .fig file that contains
            % standard MATLAB components and an XML file that serializes
            % the Waterloo graphics components. The XML file is compressed
            % unless
            %       kcl.waterloo.xml.GJEncoder.setCompression(false);
            % has benn called.
            % Compressed XML files have a .xml.gz extension, uncompressed
            % files a .xml extension.
            % 
            % If you save a "file" called myfig, save 
            %  [1] created a myfig.kclfig folder
            %  [2] writes .../myfig.kclfig/myfig.xml (or xml.gz)
            %  [3] writes .../myfig.kclfig/myfig.fig
            %  [4] exports each MATLAB graphics axes set to an image file,
            %  using PNG by default. Use the static imageOutput method to
            %  supply the handle of an image output function if you want to
            %  change this format.
            %
            % The .kclf file has the following structure:
            %       [1] A kcl.waterloo.xml.Separator marks the beginning of
            %       the entry for each graph container and therefore acts
            %       as a separator between them. 
            %       [2] This is followed by a LinkedHashMap that has MATLAB
            %       specific key/value pairs. Presently, this has only one
            %       key, 'Bounds', that is associated with a
            %       Rectangle2D.Double object containing the associated
            %       MATLAB axes position.
            %       [3] This is followed by a LinkedHashMap that has the
            %       standard key value pairs for waterloo graphics objects
            %       [4] This is followed by the graphics object - a GJGraphContainer.
            %
            % .fig file will use the default MAT-file version (v6, v7 or v7.3)
            % set in your MATLAB preferences.
            %
            
            % Can not work with a maximized figure - MATLAB axes positions will be wrong
            % - so ensure maximization is off
            jf=MUtilities.getJavaFrame(obj.Parent);
            if jf.isMaximized()
                jf.setMaximized(false);
                drawnow();
            end
            
            if nargin<3
                showProgress=false;
            end
            [path name ext]=fileparts(fileName);
            folder=[fullfile(path, name) '.kclfig'];
            if ~isdir(folder)
                mkdir(folder);
            else
                delete(fullfile(folder, '*.*'));
            end
            if kcl.waterloo.xml.GJEncoder.getCompression()==true
                ext='.kclf.gz';
            else
                ext='.kclf';
            end
            fileName=[fullfile(folder, name) ext];
            if showProgress
                [a b c]=fileparts(folder);
                pg=GProgressBar(obj.Parent, sprintf('Saving %s',[b c]), 'Writing XML',...
                    javax.swing.ImageIcon(which('booksmall.gif')),-1);
                pg.setQueryOnClose(false);
            else
                pg=[];
            end
            drawnow();
            container=MUtilities.getFigureAxisContainer(obj.Parent);
            compList=container.getComponents();
            arr=java.util.ArrayList();
            idList=nan(size(compList));
            for k=1:numel(compList)
                component=compList(k).getComponent(0);
                pos=getpixelposition(component.getID());
                arr.add(pos);
                idList(k)=component.getID();
                compList(k).remove(component);
                compList(k)=component;
            end
            worker=kcl.waterloo.xml.GJEncoder.createForMATLAB(fileName, compList, arr);
            
            h=findall(obj.Parent', 'Type', 'hgjavacomponent');
            if (~isempty(h))
                delete(h);
            end
            mlfile=[fullfile(folder,name) '.fig'];
            if ~isempty(pg)
                pg.setText('Writing .fig file');
            end
            fprintf('Saving %s\n', mlfile);
            set(obj.Parent, 'UserData',[]);
            
            
            hgsave(obj.Parent, mlfile);
            
            f=GXFigure.imageOutput();
            if ~isempty(f)
                ax=findobj(obj.Parent, 'Type', 'axes');
                for k=1:numel(ax)
                    if ~ismember(ax(k), idList)
                        imfile=[fullfile(folder,['Image' num2str(k)]) '.png'];
                        f(ax(k), imfile);
                    end
                end
            end
            
            
            delete(obj.Parent);
            if ~isempty(pg)
                    pg.setText('Waiting for XML write to complete...');
                end
            % Wait for the SwingWorker to finish
            t=tic();
            while (~worker.isDone())
                if toc(t)>7 && toc(t)<8
                if ~isempty(pg)
                    pg.setText('For complex graphics this may take some time...');
                end
                end
                if toc(t)>30
                    fprintf('Timeout (>30s) waiting for file write of %s', fileName);
                    if ~isempty(pg)
                        delete(pg);
                    end
                    return
                end
            end
            
            if ~isempty(pg)
                pg.setText('Loading clone ...');
            end
            
            newObj=GXFigure.load(mlfile);
            if ~isempty(pg)
                delete(pg);
            end
            return
        end
        

        
        function newObj=saveDialog(obj, str)
            % Shows a file chooser for use when saving. For details see the
            % save method.
            % Example:
            %    newFig=saveDialog(obj, str)
            if nargin==2
                wd=str;
            else
                wd=pwd();
            end
            fc=kcl.waterloo.file.FileChooser.getInstance();
            val=kcl.waterloo.file.FileChooser.createSaveDialog(wd);
            switch val
                case javax.swing.JFileChooser.APPROVE_OPTION
                    selection=char(fc.getSelectedFile().toString());
                    [path, name, ext]=fileparts(selection);
                    if isempty(ext)
                        selection=[selection '.kclfig'];
                    end
                    newObj=obj.save(selection, true);
            end
        end
        

        
    end
    
    methods (Static)
        
        
        function getter=imageOutput(setter)
            % imageOutput - allows customization of image output
            % Static method to provide a funtion handle or anonymous function
            % for output of MATLAB graphics in image format. These images are
            % included in .kclfig folders created by calls to save.
            % Function inputs should be:
            % 1. axes handle
            % 2. file name
            % Examples:
            %       f=GXFigure.imageOutput()% Retrieve present function handle
            %       f1=GXFigure.imageOutput(f2)% Replaces f1 with f2 and
            %                                       returns f1
            persistent func
            if nargin>0 && (isa(setter, 'function_handle') || isempty(setter))
                getter=func;
                func=setter;
            else
                % Note the default is always returned when func is empty - so to
                % suppress output you need to supply a NOP function.
                if isempty(func)
                    func=@(a,b)doImageOutput(a,b);
                end
                getter=func;
            end
            return
        end
        

        function [newFig exceptionLog]=load(fileName)
            % load - loads and creates a GXFigure from file
            % Example:
            %   GXFigure.load(fileName);
            % returns the GXFigure and an ArrayList of strings containing
            % the exception log generated when the file was saved. Note
            % that exceptions will not usually indicate errors.
            newFig=GXFigure(open(fileName));
            [path name ext]=fileparts(fileName);
            xmlFile=[fullfile(path, name) '.kclf'];
            d=dir(xmlFile);
            if isempty(d)
                xmlFile=[xmlFile '.gz'];
            end
            map=kcl.waterloo.xml.GJDecoder.load(xmlFile);
            list=map.get('Graphics');
            ax=findobj(newFig.Parent, 'Tag', 'GXFigure:subplot:createdAxes');
            p=findobj(newFig.Parent, 'Tag', 'GXFigure:subplot:createdPanel');
            if ~isempty(ax);set(ax, 'Units','pixels');end
            if ~isempty(p);set(p, 'Units','pixels');end
            for k=3:3:list.size()
                % NB: This fails when figure is maximized when saved, so
                % save must set maximized off.
                dim=list.get(k-3).get('Bounds');
                pos=[dim.getX() dim.getY() dim.getWidth() dim.getHeight()];
                thisAx=findAxis(ax,pos);
                ud=get(thisAx, 'UserData');
                if isempty(ud)
                    thisAx=axes();
                    thisPanel=get(thisAx, 'parent');
                else
                    thisPanel=ud{2};
                end
                arr(k)=GXGraph(thisPanel, list.get(k-1)); %#ok<AGROW>
                list.get(k-1).setID(thisAx);
                set(thisAx,'UserData',{arr(k) thisPanel});
                list.get(k-1).revalidate();
            end
            if ~isempty(ax);set(ax, 'Units','normalized');end
            if ~isempty(p);set(p, 'Units','normalized');end
            newFig.setupMenu();
            %drawnow();
            for k=3:3:list.size() 
                list.get(k-1).revalidate();
                list.get(k-1).repaint();
            end
            exceptionLog=map.get('ExceptionLog');
            set(newFig, 'CurrentAxes', arr(end));
            
            function thisAxis=findAxis(ax, pos)
                % This works like findobj(ax, 'Position', pos) but includes
                % tolerance for IEEE rounding errors (which turn up occasionally
                % in the two position specs).
                if numel(ax)==1
                    thisAxis=ax;
                    return
                end
                tol=40;
                for idx=1:numel(ax)
                    if abs(sum(get(ax(idx),'Position')-pos))<tol
                        thisAxis=ax(idx);
                        return
                    end
                end
                thisAxis=[];
            end
                
        end
        
        function newObj=openDialog()
            % Shows a file chooser for use when opening a file. For details see the
            % load static method.
            % Example:
            %    newFig=openDialog(obj, str)
            val=kcl.waterloo.file.FileChooser.createOpenDialog();
            switch val
                case javax.swing.JFileChooser.APPROVE_OPTION
                    fc=kcl.waterloo.file.FileChooser.getInstance();
                    selection=char(fc.getSelectedFile().toString());
                    [path, name, ext]=fileparts(selection);
                    if strcmpi(ext, '.kclfig')
                        file=[fullfile(selection, name) '.fig'];
                        newObj=GXFigure.load(file);
                    else
                        try
                            % Non MATLAB Waterloo file - open using
                            % createFrame if method avaliable on returned
                            % object
                            newObj=kcl.waterloo.xml.GJDecoder.load(selection);
                            newObj.createFrame();
                        catch
                        end
                    end
            end
        end
        
    end
    
end

function doImageOutput(ax, file)
f=figure();
pos=getpixelposition(ax);
setpixelposition(f, [1,1, pos(3), pos(4)]);
set(f,'ColorMap', get(ancestor(ax,'figure'),'ColorMap'));
newax=copyobj(ax,f);
set(newax, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
print(f, file,'-dpng');
delete(f);
end

function menuSave(hObject, EventData, obj)
h=get(obj, 'UserData');
h{1}.saveDialog();
return
end

function menuOpen(hObject, EventData)
GXFigure.openDialog();
return
end

