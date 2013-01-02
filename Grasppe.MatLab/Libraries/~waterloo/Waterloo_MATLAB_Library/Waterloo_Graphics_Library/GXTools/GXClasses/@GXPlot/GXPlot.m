classdef GXPlot < GXGraphicObject 
% GXPlot graph. Provides high-quality, anti-aliased 2D graphics in MATLAB
% using the Project Waterloo Graphics Library.
%
% GXPlot is called from the various methods for individual plot types
% (line, scatter etc.) and provides a common wrapper class for the plots.
% This MATLAB wrapper is used instead of the WPlot Groovy wrapper.
%
% In that case the call takes the form
%       obj=GXPlot(Target, Style, Map)
%           where Target is the handle or reference to the object will
%                   parent the plot
%                 Style is a string describing the plot style e.g.
%                   'scatter'
%                 Map is a java.util.LinkedHashMap typically supplied as
%                   output from a call to kcl.waterloo.plot.WPlot.parseArgs
%
%                 contour
%                 errorbar
%                 feather
%                 line
%                 quiver
%                 scatter
%                 stairs
%                 stem
%
% GXPlot can also be invoked directly if the appropriate parameter
% name/values are supplied as input. 
%       obj=GXPlot(Target, Style, PropName1, PropValue1,....)
% The call to WPlot.parseArgs will then be made within the Groovy code.
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

    
    properties
        Style;
        Type='GXPlot';
        Parent;
    end
    
    
    methods
        
        function obj=GXPlot(varargin)

            target=varargin{1};
            style=varargin{2};
            args=[];
            if nargin>2
                if isjava(varargin{3})
                    % LinkedHashMap 
                    args=varargin{3};
                else
                    % MATLAB style prop/value pairs
                    args=varargin(3:end);
                end
            end

            % Instantiate object
            style(1)=upper(style(1));
            switch lower(style)
                case {'scatter', 'line', 'stairs','stem', 'bar', 'feather', 'errorbar', 'quiver'}
                    % Standard calls with XData & YData. The groovy code
                    % will call the createInstance method
                    x=kcl.waterloo.plot.WPlot.(lower(style))(args);
                    % TODO: Should these be on EDT?
                    obj.Object=x.getPlot();
                case 'cscatter'
                    style='GJComponentPlot';
                    obj.Object=javaObjectEDT(kcl.waterloo.graphics.plots2D.GJComponentPlot.createInstance());
                    if nargin>2
                        obj.setData(args{1},args{2});
                    end  
                case {'contour'}
                    % Contour - filling not presently implemented
                    obj.Object=kcl.waterloo.plot.WPlot.contour([]);
                    obj.Object=obj.Object.getPlot();
                    % Get contours
                    if numel(args)>1
                        % Need to generate a contour matrix
                        if isvector(args{1}) && isvector(args{2})
                            C=contourc(args{:});
                        else
                            tmpF=figure('Visible','off');
                            [C]=contour('Parent', gca, args{:});
                            delete(tmpF);
                        end
                    else
                        if size(args{1},1)==2
                        % The input is a contour matrix
                            C=args{1};
                        else
                            % The input is a data matrix
                            tmpF=figure('Visible','off');
                            [C]=contour('Parent', gca, args{:});
                            delete(tmpF);
                        end
                    end
                    contourObject=kcl.waterloo.graphics.plots2D.ContourExtra.createFromMatrix(C);
                    obj.Object.getDataModel().setExtraObject(contourObject);
                    levels=contourObject.getContourLines();
                    x=zeros(1,levels.size());
                    obj.Object.setXData(x);
                    obj.Object.setYData(x);
%                     % Convert the MATLAB matrix to a friendlier form - each
%                     % element of the cell array newC contains data for one
%                     % contour line corresponding to the levels in 'levels'
%                     [levels newC]=convertContour(C);
%                     % Set up
%                     n=numel(levels);
%                     p=kcl.waterloo.graphics.GJUtilities.makePath2DArray(n);
%                     % Generate a Java Path2D object for each contour
%                     for k=1:n
%                         p(k)=kcl.waterloo.graphics.GJUtilities.makePath2DDouble();
%                         p(k).moveTo(newC{k}(1,1),newC{k}(1,2));
%                         for m=2:size(newC{k},1)
%                             p(k).lineTo(newC{k}(m,1), newC{k}(m,2));
%                         end
%                         if strcmp(style, 'contourf')
%                             %TODO
%                         end
%                     end
%                     % Call GJContour.setData. 
%                     % Levels will be in XData and the Paths for each
%                     % contour are in the marker
%                     obj.setData(levels, p);
%                     obj.ExtraData.ContourMatrix=C;
%                     obj.ExtraData.TextRotation=TextRotation;
                case {'clabel'}
                    obj.Object=javaObjectEDT(kcl.waterloo.graphics.plots2D.GJComponentPlot());
                    h1=clabel(target.ExtraData.ContourMatrix);
                    h2=findobj(h1, 'Type', 'text');
                    carray=kcl.waterloo.graphics.GJUtilities.makeComponentArray(numel(h2));
                    X=zeros(1,numel(h2));
                    Y=zeros(1,numel(h2));
                    for k=1:numel(h2)
                        pos=get(h2(k), 'Position');
                        carray(k)=javaObjectEDT(org.jdesktop.swingx.JXButton(get(h2(k),'String')));
                        X(k)=pos(1);
                        Y(k)=pos(2);
                        carray(k).setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 12));
                        carray(k).setPreferredSize(java.awt.Dimension(50,25));
                    end
                    h2=[];
                    delete(h1);
                    obj.Object.setData(X, Y, carray);
            end
            
            % Add to target object
            if ~isempty(target)
                switch class(target)
                    case 'double'
                        % The parent is a MATLAB HG handle. Find the
                        % relevant GXGraph (only one per HG container
                        % allowed).
                        if ~isappdata(target, 'GXGraphObject')
                            warning('GXPlot:InvalidTarget','Specified target (%d) has no associated GXGraphObject', target);
                            return
                        else
                            parent=getappdata(target, 'GXGraphObject');
                            parent.addPlot(obj);
                            obj.Parent=parent;
                        end

                    case {'GXGraph', 'jcontrol', 'kcl.waterloo.graphics.GJGraph', ...
                            'javahandle_withcallbacks.kcl.waterloo.graphics.GJGraph'}
                        % Parent is a GXGraph object - add this plot to it
                        target.getObject().getView().add(obj.getObject());
                        obj.Parent=target;
                        drawnow();
                    case {'wwrap'}
                        if (isa(target.getObject(), 'kcl.waterloo.graphics.GJGraphContainer'))
                            target.getObject().getView().add(obj.getObject());
                        else
                            target.getObject().add(obj.getObject());
                        end
                        obj.Parent=target;
                        

                    case 'GXPlot'
                        % Parent is another GXPlot object - add this plot
                        % to it. The parent plot may or may not yet be
                        % associated with a GXGraph
                        newplot=obj.getObject();
                        target.getObject().add(newplot);
                        obj.Parent=target;

                end
            end
            obj.Style=style;
            return
        end
        
        function view=getView(obj)
            view=obj.Parent.getView();
            return
        end

        
    end
    
end

function [levels newC]=convertContour(C)
% convertContour - Internal helper for converting MATLAB contour matrices
% Pre-allocate memory for up to 200 contours - levels and newC will grow in
% the loop if more are needed
levels=zeros(1,200);
newC=cell(1,200);
count=0;
k=1;
while k<size(C,2)
    count=count+1;
    levels(count)=C(1,k);
    n=C(2,k);
    newC{count}=zeros(n,2);
    newC{count}(:,1)=C(1, k+1:k+n);
    newC{count}(:,2)=C(2, k+1:k+n);
    k=k+n+1;
end
levels=levels(1:count);
newC=newC(1:count);
return
end

% function theta=getTheta(sintheta,x,y)
% if x>=0 && y>=0
%     theta=asin(sintheta);
% elseif x<=0 && y>=0
%     theta=pi-asin(sintheta);
% elseif x<=0 && y<=0
%     theta=-(pi+asin(sintheta));
% else
%     theta=asin(sintheta);
% end
% return
% end

