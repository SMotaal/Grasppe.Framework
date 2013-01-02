classdef GXGraph < GXGraphicObject
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
    properties
        Type;
        Parent;
    end
    
    methods
        
        % Constructor
        function obj=GXGraph(target, graphicObject)
            
            if nargin==0
                return
            end
                
            if nargin==2 && isa(graphicObject, 'kcl.waterloo.graphics.GJGraphContainer')
                % This is for use in deserializing kclfig files.
                % Not intended for general use.
                obj.Object=jcontrol(target, graphicObject, 'Position', [0 0 1 1]);
                obj.Parent=target;
                return;
            end
            
            if nargin<2
                graphicObject=kcl.waterloo.graphics.GJGraph.createInstance();
            end
            
            obj.Object=jcontrol(target, kcl.waterloo.graphics.GJGraphContainer.createInstance(graphicObject),...
                'Position',[0 0 1 1]);

            % Refer View to EDT for all calls
            javaObjectEDT(obj.Object.getView());
            
            obj.Type='GXGraph';
            if strcmpi(get(target,'Type'), 'figure')
                set(target, 'Toolbar', 'none');
            end
            obj.Parent=target;
            
%             obj.Object.removeComponentListener();
%             set(obj.Object.hgcontainer, 'ResizeFcn', {@LocalResize, obj.Object.hgcontrol});
%             set(target, 'DeleteFcn', {@LocalDelete, obj});
            
            h2=get(target, 'UserData');
            if ~isempty(h2)
                h2{1}.CurrentAxes=obj; %#ok<NASGU>
                set(gca, 'UserData', {obj})
            end
            
            % TODO: Check why I included this in the first place!
%             if isempty(get(target, 'UserData'))
%                GXFigure(target);
%             end
            
            h3=get(target, 'UserData');
            
            if ~isempty(h3) && isempty(h3{1}.Components)
                h3{1}.Components=java.util.LinkedHashMap();
                h3{1}.Components.put(1, gca);
                h3{1}.CurrentAxes=gca; %#ok<NASGU>
            end
            
            set(gca, 'UserData', {obj});
            
            return
        end
        
        function out=getView(obj)
            out=obj.getObject().getView();
            return
        end
        
        function TF=isa(obj, className)
            if ischar(className) && strcmpi(className, 'GXGraph')
                TF=true;
            else
                TF=builtin('isa', obj, className);
            end
            return
        end
        
        function autoScale(obj)
            % autoScale flushed the EDT, then calls the graph autoScale
            % method
            %  
            drawnow();
            obj.Object.getView().autoScale();
        end
        
        

        
    end
    
end

function LocalDelete(hObj, EventData, obj)

set(obj.Parent, 'DeleteFcn',[]);
delete(obj);
return
end

function LocalResize(hObject, EventData, container)
container.revalidate();
container.repaint();
return
end


