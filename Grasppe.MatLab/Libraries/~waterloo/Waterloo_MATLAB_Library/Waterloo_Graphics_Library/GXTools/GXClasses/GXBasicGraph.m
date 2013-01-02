classdef GXBasicGraph < GTool
    
    properties
    end
    
    properties (Access=private)
        titlefont=[];
    end
    
    methods
        
        function flag=addPlot(obj, thisPlot)
            flag=obj.Object.getView().addPlot(thisPlot.getObject());
            return
        end

        % MATLAB-style calls
        
%         function h=double(obj)
%             h=obj.Parent;
%             return
%         end
        
        function annotation(obj, varargin)
            obj.createFromMATLABCommand('annotation', varargin{:});
            return
        end
        
        function createFromMATLABCommand(obj, style, varargin)
            %TODO: and make this private for dist?
            return
        end
        
        function refresh(obj)
            % refresh the graph view and update all graphics
            % Example:
            %       refresh(obj);
            % Use refresh to force an update after adding new items such as
            % titles and java components to the view.
            obj.Object.revalidate();
        end
        
        
        % Title
        function setTitle(obj, str)
            if ischar(str)
                obj.Object.setTitle(str);
            end
            return
        end
        
        function str=getTitle(obj)
            str=char(obj.Object.getTitle());
            return
        end
        
        % SubTitle
        function setSubTitle(obj, str)
            if ischar(str)
                obj.Object.setSubTitle(str);
            end
            return
        end
        
        function str=getSubTitle(obj)
            str=char(obj.Object.getSubTitle());
            return
        end
        

        
    end
    
end