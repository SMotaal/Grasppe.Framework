function args= processGraphicsArgs(varargin)

args={};
counter=0;
for k=1:numel(varargin)
    counter=counter+1;
    switch varargin{k}
        case 'BarLayout'
        case 'BarWidth'
        case 'BaseLine'
        case 'BaseValue'
        case 'CData'
        case 'Color'
        case 'CreateFcn'
        case 'DeleteFcn'
        case 'DisplayName'
        case 'EdgeColor'
        case 'FaceColor'
        case 'HitTest'
        case 'LineWidth'
        case 'LineStyle'
        case 'Marker'
        case 'MarkerEdgeColor'
        case 'MarkerFaceColor'
        case 'MarkerSize'
        case 'ShowBaseLine'
        case 'SizeData'
        case 'Visible'
        case 'XData'
        case 'YData'
        case 'ZData'
        otherwise
            counter=count-1;
    end
end

