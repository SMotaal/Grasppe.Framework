function annot=annotation(target, style, varargin)
% annotation method for GXGraphicObjects
%
% a=annotation(target, 'line',x,y)
% a=annotation(target, 'arrow',x,y)
% a=annotation(target, 'text',x, y)
% a=annotation(target, 'ellipse', x, y, w, h)
% a=annotation(target, 'rectangle', x, y, w, h)
%
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 08/12
% Copyright The Author & King's College London 2012-
% ---------------------------------------------------------------------

if ischar(target)
    [target args]=ProcessPairedInputs(target, style, varargin{:});
    TF=cellfun(@strcmp, args, repmat({'Style'}, size(args)));
    style=args{find(TF)+1};
else
switch (lower(style))
    case {'line', 'arrow','text'}
        YData=varargin{2};
        XData=varargin{1};
        varargin(2)=[];
        varargin(1)=[];
        if ~isempty(varargin)
            args={'XData', XData, 'YData', YData, varargin{:}};
        else
            args={'XData', XData, 'YData', YData};
        end
    case {'box', 'rectangle', 'ellipse'}
        Height=varargin{4};
        Width=varargin{3};
        YData=varargin{2};
        XData=varargin{1};
        varargin(4)=[];
        varargin(3)=[];
        varargin(2)=[];
        varargin(1)=[];
        if ~isempty(varargin)
            args={'XData', XData, 'YData', YData, 'Width', Width, 'Height', Height, varargin{:}};
        else
            args={'XData', XData, 'YData', YData, 'Width', Width, 'Height', Height};
        end
    case 'shape'
        args={'Shape', varargin{:}};    
end
end


if strcmp(style,'rectangle')
    style='box';
end


annot=kcl.waterloo.plot.WAnnotation.(style)(args);

if isa(target, 'GXGraphicObject')
    target.getObject().add(javaObjectEDT(annot.getAnnotation()));
elseif isjava(target)
    target.add(javaObjectEDT(annot.getAnnotation()));
end

return
end