classdef GXPlot < GTool 
% GXPlot graph. Provides high-quality, anti-aliased 2D graphics in MATLAB
% using the Project Waterloo Graphics Library.
%
% GXPlots provide a consistent mechanism for creating good quality graphs.
% A GXPlot has a vector of double precision XData and a vector of YData. In
% addition, a Marker array controls what gets plotted at each each x,y data
% point defined by these vectors. 
%
% Scatter
%     obj=GPlot(target, 'scatter', xvalues, yvalues);
% Stem
%     obj=GPlot(target, 'stem', xvalues, yvalues);
% Line
%     obj=GPlot(target, 'line', xvalues, yvalues);
% Stairs
%     obj=GPlot(target, 'stairs', xvalues, yvalues);
% ErrorBars
%     obj=GPlot(target, 'errorbar', top, bottom, left, right);
% Contour
%     obj=GPlot(target, 'contour', MATLAB_Contour_Matrix);
%     or
%     obj=GPlot(target, 'contour', varargin);
%           where varargin are valid inputs to the MATLAB contour or 
%           contourc function
% Bar
% Feather
% Quiver

    properties
%         XData;
%         YData;
        LinkData=true;
        Style;
        Type='GXPlot';
        Parent;
        ExtraData=[];
    end
    
    
    methods
        
        function obj=GXPlot(varargin)
            
            target=varargin{1};
            style=varargin{2};
            if nargin>2
                args=varargin(3:end);
            end
            
            
            
            % Instantiate object
            style(1)=upper(style(1));
            switch lower(style)
                case {'scatter', 'line', 'stairs','stem', 'bar', 'feather'}
                    % Standard calls with XData & YData
                    constructor=['GJ' style];
                    obj.Object=javaObjectEDT(kcl.waterloo.graphics.plots2D.(constructor)());
                    obj.setData(args{1},args{2});
                case 'errorbar'
                    % Exception - top, bottom, left and right error bars
                    obj.Object=javaObjectEDT(kcl.waterloo.graphics.plots2D.GJErrorBar(args{:}));
                case 'quiver'
                    % Quiver plot. XData and YData are the point locations.
                    % The vectors are drawn with reference to those
                    % locations
                    obj.Object=javaObjectEDT(kcl.waterloo.graphics.plots2D.GJQuiver());
                    X=args{1}(:);
                    Y=args{2}(:);

                    U=args{3}(:);
                    V=args{4}(:);
                    n=numel(X);
                    p=kcl.waterloo.graphics.GJUtilities.makePath2DArray(n);
                    for k=1:n
                        p(k)=kcl.waterloo.graphics.GJUtilities.makePath2DDouble();
                        p(k).moveTo(0,0);
                        p(k).curveTo(0, V(k)/3, 2*U(k)/3, V(k), U(k),V(k));%p(k).lineTo(x,y);
                        arrow=kcl.waterloo.graphics.GJUtilities.makeArrow(U(k),V(k),15);
                        p(k).append(arrow,false);
                    end
                    obj.Object.setData(X,Y,p);
                    obj.Object.setLineColor(java.awt.Color.BLUE);
                    obj.Object.setLineStroke(java.awt.BasicStroke(3));
                case {'contour', 'contourf'}
                    % Contour - filling not presently implemented
                    obj.Object=javaObjectEDT(kcl.waterloo.graphics.plots2D.GJContour());
                    TextRotation=[];
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
                    % Convert the MATLAB matrix to a friendlier form - each
                    % element of the cell array newC contains data for one
                    % contour line corresponding to the levels in 'levels'
                    [levels newC]=convertContour(C);
                    % Set up
                    n=numel(levels);
                    p=kcl.waterloo.graphics.GJUtilities.makePath2DArray(n);
                    % Generate a Java Path2D object for each contour
                    for k=1:n
                        p(k)=kcl.waterloo.graphics.GJUtilities.makePath2DDouble();
                        p(k).moveTo(newC{k}(1,1),newC{k}(1,2));
                        for m=2:size(newC{k},1)
                            p(k).lineTo(newC{k}(m,1), newC{k}(m,2));
                        end
                        if strcmp(style, 'contourf')
                            %TODO
                        end
                    end
                    % Call GJContour.setData. 
                    % Levels will be in XData and the Paths for each
                    % contour are in the marker
                    obj.setData(levels, p);
                    obj.ExtraData.ContourMatrix=C;
                    obj.ExtraData.TextRotation=TextRotation;
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
                    case {'GXGraph', 'GXGraphPane', 'jcontrol',...
                            'javahandle_withcallbacks.kcl.waterloo.graphics.GJGraph', 'javahandle_withcallbacks.kcl.waterloo.graphics.GJGraphPane'}
                        % Parent is a GXGraph object - add this plot to it
                        target.addPlot(obj);
                        obj.Parent=target;
                    case 'GXPlot'
                        % Parent is another GXPlot object - add this plot
                        % to it. The parent plot may or may not yet be
                        % associated with a GXGraph
                        target.addExtra(obj);
                        obj.Parent=target;
                end
            end
            obj.Style=style;
            return
        end
        
        function addExtra(obj, g)
            obj.Object.addExtraPlot(g.getObject());
            return
        end
        
        function setData(obj, X, Y)
            obj.Object.setData(X,Y);
            return
        end
        
        function varargout=getData(obj)
            varargout{1}=obj.Object.getXData();
            if nargout==2
                varargout{2}=obj.Object.getYData();
            end
            return
        end
        
        function repaint(obj)
            obj.Parent.Object.getView().repaint()
            return
        end
        
        % Appearence
        function setMarker(obj, marker)
            obj.Object.setMarker(marker);
            return
        end
        
        function setAlpha(obj, alpha)
            obj.Object.setAlpha(alpha);
            return
        end
        
        function setCompositeMode(obj, mode)
            obj.Object.setCompositeMode(mode);
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

function theta=getTheta(sintheta,x,y)
if x>=0 && y>=0
    theta=asin(sintheta);
elseif x<=0 && y>=0
    theta=pi-asin(sintheta);
elseif x<=0 && y<=0
    theta=-(pi+asin(sintheta));
else
    theta=asin(sintheta);
end
return
end

