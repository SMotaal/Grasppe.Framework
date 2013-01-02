function plotobj=quiver(target, X, Y, varargin)
%             quiver(x,y,u,v)
%             quiver(u,v)
%             quiver(...,scale)
%             quiver(...,LineSpec)
%             quiver(...,LineSpec,'filled')
%             quiver(...,'PropertyName',PropertyValue,...)
%             quiver(axes_handle,...)
%             h = quiver(...)
%
% Also:
% quiver('Parent', GXGraphicObject, 'PropertyName1',propertyvalue1,...)
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
scale=1;
LineSpec=[];
U=[];
V=[];

if ischar(target)
    [target, varargin]=ProcessPairedInputs(target, X, Y, varargin{:});
    X=[];Y=[];
    % Convert numeric matrices to vectors
    for k=2:2:numel(varargin)
        if isnumeric(varargin{k})
            varargin{k}=varargin{k}(:).';
        end
    end
else
    
    % X and Y defined on input - check for U and V
    if isnumeric(varargin{1}) && isnumeric(varargin{2})
        U=varargin{1};
        V=varargin{2};
        varargin(2)=[];
        varargin(1)=[];
    end
    
    % Check for a "filled" argument and remove it from the list if present
    TF1=cellfun(@(x)(ischar(x) && strcmpi(x,'filled')), varargin);
    if any(TF1)
        isFilled=true;
        varargin(TF1)=[];
    end
    
    % Check for a user-specified scale
    TF1=cellfun(@(x)(isscalar(x) && ~ischar(x)), varargin(1:min(numel(varargin),3)));
    idx=find(TF1,1,'first');
    if any(TF1) 
        if idx==1 || ~ischar(varargin{idx-1}) || strcmpi(varargin{idx-1}, 'scale')
        scale=varargin{idx};
        varargin(idx)=[];    
        end
    end
    
    
    %Check for LineSpec
    TF1=cellfun(@isLineSpec, varargin);
    if (any(TF1))
        LineSpec=varargin{TF1};
        varargin(TF1)=[];
        TF1=cellfun(@strcmpi, varargin, repmat({'linespec'}, size(varargin)));
        varargin(TF1)=[]; 
    end
    
    % If X and Y not supplied, create them
    if isempty(U)
        [r,c]=size(X);
        U=X(:).';
        V=Y(:).';
        X=repmat(1:r, 1, c);
        Y=repmat(1:c, r, 1);
        Y=Y(:)';
    end
    
    % Vectors needed
    X=X(:).';
    Y=Y(:).';
    U=U(:).';
    V=V(:).';
    
    varargin=horzcat({'XData', X, 'YData', Y, 'ExtraData0', U, 'ExtraData1', V, 'Scale', scale, varargin{:}});
    
    if ~isempty(LineSpec)
        varargin=horzcat(varargin, 'LineSpec', LineSpec);
    end
    
end

% Create the quiver plot
props=kcl.waterloo.plot.WPlot.parseArgs(varargin);
if (isFilled && props.containsKey('Fill') && isempty(props.get('Fill')))
    props.put('Fill',props.get('LineColor'));
end
plotobj=GXPlot(target, 'quiver', props);


% If a marker is requested, add this to the origin of each arrow (by adding
% a scatter plot).
if props.containsKey('Marker') || props.containsKey('MarkerFcn') || props.containsKey('LineSpec')
    sc=kcl.waterloo.plot.WPlot.scatter(props);
    plotobj.getObject() + sc.getPlot();
end


return
end