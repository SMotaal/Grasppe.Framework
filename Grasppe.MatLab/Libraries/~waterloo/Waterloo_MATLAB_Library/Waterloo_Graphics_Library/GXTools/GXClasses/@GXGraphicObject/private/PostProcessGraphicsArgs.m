function props=PostProcessGraphicsArgs(plotobj, varargin)
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

% if numel(plotobj)>1
%     for k=1:numel(plotobj)
%         PostProcessGraphicsArgs(plotobj(k), varargin{:});
%     end
%     return
% end

props=kcl.waterloo.plot.WPlot.parseArgs(varargin);
kcl.waterloo.plot.WPlot.processArgs(plotobj,props);

%props=LinkedHashMapToStructure(props);
% 
% % for k=1:numel(plotobj)
%    setProps(plotobj, props);
% % end
% 

return
end


function setProps(plotobj, props)
% Line

plotobj.setLineStroke(kcl.waterloo.graphics.GJUtilities.makeStroke(props.LineWidth, props.LineStyle));
plotobj.setLineColor(props.Color);


% Marker

% MarkerEdgeColor
if ~isempty(props.MarkerEdgeColor)
    if isjava(props.MarkerEdgeColor)
        plotobj.setEdgeColor(props.MarkerEdgeColor);
    else
        plotobj.setEdgeColor(GColor.toJava(props.MarkerEdgeColor'));
    end
end

% MarkerEdgeColor is a Paint or Paint[] (and null is supported)
if ~isempty(props.MarkerFaceColor)
    if isjava(props.MarkerFaceColor)
        plotobj.setFill(props.MarkerFaceColor);
    else
        plotobj.setFill(GColor.toJava(props.MarkerFaceColor));
    end
end


if isempty(props.SizeData)
    if ~isempty(props.Marker)
        f=convertMarkerType(props.Marker);
        plotobj.setMarker(f(props.MarkerSize));
    elseif ~isempty(props.MarkerFcn)
        plotobj.setMarker(props.MarkerFcn.call(props.MarkerSize));
    end
else
    if isempty(props.MarkerFcn)
        props.MarkerFcn=kcl.waterloo.plot.WPlot.convertMarkerType('o');
    end
    for k=1:numel(props.SizeData)
        markers(k)=props.MarkerFcn.call(props.SizeData(k)); %#ok<AGROW>
    end
    plotobj.setMarker(markers);
end

% Data
if ~isempty(props.XData);plotobj.setXData(props.XData);end
if ~isempty(props.YData);plotobj.setYData(props.YData);end
if ~isempty(props.ZData);plotobj.setZData(props.ZData);end

try
    if ~isempty(props.LData);plotobj.setBottom(props.LData);end
    if ~isempty(props.UData);plotobj.setTop(props.UData);end
    if ~isempty(props.LeftData);plotobj.setLeft(props.LeftData);end
    if ~isempty(props.RightData);plotobj.setRight(props.RightData);end
catch ex
    switch ex.identifier
        case 'MATLAB:noSuchMethodOrField'
        otherwise
            rethrow(ex);
    end
end

% % CreateFcn
% if ~isempty(CreateFcn)
%     if ischar(CreateFcn)
%         eval(CreateFcn);
%     elseif isa(CreateFcn, 'function_handle')
%         CreateFcn(plotobj);
%     elseif iscell(CreateFcn)
%         if numel(CreateFcn==1)
%             CreateFcn{1}(plotobj);
%         else
%         CreateFcn{1}(plotobj, CreateFcn{2:end});
%         end
%     end
% end


return
end