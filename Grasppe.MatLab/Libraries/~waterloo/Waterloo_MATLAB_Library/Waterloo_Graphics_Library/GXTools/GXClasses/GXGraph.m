classdef GXGraph < GXBasicGraph
    
    properties
        Type;
        Parent;
    end
    
    methods
        
        % Constructor
        function obj=GXGraph(target)
            obj=obj@GXBasicGraph();
            obj.Object=jcontrol(target, kcl.waterloo.graphics.GJGraphContainer(),...
                'Position',[0 0 1 1]);
            javaObjectEDT(obj.Object.View);
            obj.Type='GXGraph';
            setappdata(target, 'GXGraphObject', obj);
            if strcmpi(get(target,'Type'), 'figure')
                set(target, 'Toolbar', 'none');
            end
            obj.Parent=target;
            return
        end
        
        % MATLAB style graphics calls
        
        function h=plot(obj, varargin)
            h=line(obj, varargin{:});
            return
        end
        
        function h=line(obj, varargin)
            h=GXPlot(obj, 'line', varargin{:});
            return
        end
        
        function h=scatter(obj, varargin)
            h=GXPlot(obj, 'scatter', varargin{:});
            return
        end
        
    end
    
end

