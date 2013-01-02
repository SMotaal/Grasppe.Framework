classdef GJBasic < hgsetget
    
    properties
        Object=[];
        Parent=[];
        Number=[];
        Created=[];
    end
    
    
    methods
        
        function addTo(obj, parent, varargin)
            if ishghandle(parent)
                obj.Parent=jcontrol(parent, obj.Object, varargin{:});
            else
                obj.Parent=parent.add(obj.Object);
            end
            return
        end
        
    end
end