function plotobj=stem(target,  X, varargin)
% stem method
%         stem(Y)
%         stem(X,Y)
%         stem(...,'fill')
%         stem(...,LineSpec)
%         stem(...,'PropertyName',PropertyValue,...)
%         stem(axes_handle,...)
%         h = stem(...)
%
% Also:
% stem('Parent', GXGraphicObject, 'PropertyName1',propertyvalue1,...)
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
    [target, varargin]=ProcessPairedInputs(target, X, varargin{:});
    X=[];Y=[];
else
    switch nargin
        case 2
            Y=X;
            X=1:numel(Y);
        case 3
            if isnumeric(varargin{1})
                Y=varargin{1};
                varargin=[];
            end
        case 4
            Y=X;
            if isnumeric(varargin{1})
                Y=varargin{1};
            else

                X=1:numel(Y);
            end
            if isLineSpec(varargin{2})
                varargin=horzcat('LineSpec', varargin(2:end));
            else
                isFilled=true;
                varargin=horzcat('LineSpec', varargin(2:end));
            end
        otherwise
            if isnumeric(varargin{1})
                Y=varargin{1};
                varargin=varargin(2:end);
            else
                Y=X;
                X=1:numel(Y);
            end
    end
end

if numel(X)~=numel(Y)
    X=repmat(X,1,numel(Y)/numel(X));
end

args=horzcat({'XData', X(:), 'YData', Y(:)}, varargin);
props=kcl.waterloo.plot.WPlot.parseArgs(args);

if ~isFilled &&  ~props.containsKey('Fill')
    props.put('Fill', []);
elseif props.containsKey('LineColor') &&  ~props.containsKey('Fill')
    props.put('Fill', props.get('LineColor'));
end

plotobj=GXPlot(target, 'scatter', props);
sc=kcl.waterloo.plot.WPlot.stem(props);
plotobj.getObject() + sc.getPlot();




return
end