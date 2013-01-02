classdef GBasicCardGroup < GTool
    % GBasicCardGroup a supercless for GCardPane, GTabbedPane and
    % GAccordions etc.

    
    properties (SetAccess=protected, GetAccess=public)
        Components;
        Parent=[];
        Type=[mfilename() ':subclass'];
        Animated=false;
    end
    
    methods

        function setAnimated(obj, flag)
            % setAnimated switches between animation/no animation
            % Example
            %     obj.setAnimated(true);
            %     obj.setAnimated(false);
            obj.Animated=logical(flag);
            return
        end
        
        function val=isAnimated(obj)
            % isAnimated returns the animation flag
            % Example
            %     flag=obj.isAnimated();
            val=obj.Animated;
            return
        end
        

    end
    
end