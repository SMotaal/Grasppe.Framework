function plotobj=scatter(target, X, Y, S, C, varargin)
% scatter method for GXGraphicObject objects
% Examples:
% scatter(GXGraphicObject, X,Y,S,C) 
% scatter(GXGraphicObject, X,Y)
% scatter(GXGraphicObject, X,Y,S)
% scatter(...,markertype) 
% scatter(...,'filled') 
% scatter(...,'PropertyName',propertyvalue)
% 
% See also: scatter
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

isFilled=false;
if ischar(target)
   [target, varargin]=ProcessPairedInputs(target, X, Y, S, C, varargin{:});
   X=[];Y=[];S=[];C=[];
else
    
%     if numel(X)~=numel(Y) && ~(isempty(X) || isempty(Y))
%         error('X and Y must be of equal length');
%     end
    
    if nargin>=4
        % Process S and C if supplied
        % If S or C are not used the specified inputs are added to the start of
        % varargin
        if isnumeric(S)
            
            % Marker area in S (points)- convert to radius (pixels) on screen
            if ~isempty(S)
                pt=1;%get(0,'ScreenPixelsPerInch')/72;
                S=sqrt(S)/2*pt;
                varargin=horzcat(varargin, 'SizeData', S);
            end
            
            % Color arguments
            if isnumeric(C)
                if size(C,1)==1 && size(C,2)==3
                    varargin=horzcat(varargin, 'MarkerEdgeColor', C);
                else
                    map=colormap();
                    if size(C,2)==3
                        tcolor(k)=GColor.toJava(map(C(k),:)); %#ok<AGROW>
                        varargin=horzcat(varargin, 'MarkerEdgeColor', tcolor);
                    else
                        Z=C-min(C);
                        Z=Z/(max(Z)/size(map,1)+1);
                        Z=floor(Z)+1;
                        tcolor=map(Z,:);
                        p{1}='MarkerEdgeColor';
                        p{2}=GColor.toJava(tcolor);
                        p{3}='MarkerFaceColor';
                        p{4}=p{2};
                        varargin=horzcat(varargin, p);
                    end
                end
            else
                varargin=horzcat(C, varargin);
            end
        else
            varargin=horzcat(S, C, varargin);
        end
    end
end

try
    
TF=cellfun(@strcmpi, varargin, repmat({'filled'}, size(varargin)));
if any(TF)
    isFilled=true;
    varargin(TF)=[];
end
catch
end

if ~isempty(X)
    varargin=horzcat('XData', X, varargin);
end

if ~isempty(Y)
    varargin=horzcat('YData', Y, varargin);
end

props=kcl.waterloo.plot.WPlot.parseArgs(varargin);
plotobj=GXPlot(target, 'scatter', props);

if isFilled
    obj=plotobj.getObject();
    obj.setFill(props.get('EdgeColor'));
end




return
end