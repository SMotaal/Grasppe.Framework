classdef GSplitSet < GTool
    % GSpltSet class. A wrapper class that supports multiple GSplitPanes in a
    % single container.
    % Example
    %       x=GSplitSet(parent, n, orientation);
    %             parent    is the MATLAB parent container
    %             n         the number of divisions (there will be n-1
    %                       dividers)
    %             orientation   string, 'vertical' or 'horizontal'
    % For any GSplitSet instance, the GSplitPanes are orientated in a single
    % direction. Complex patterns can be created by using multiple GSplitSets
    % Example:
    %       x=GSplitSet(container, 3, 'vertical');
    %       y=GSplitSet(x.getComponent(1), 2, 'horizontal');
    % Gives:
    %       -----------------------------------------------
    %       |               |               |              |
    %       |               |               |              |
    %       |               |               |              |
    %       |               |               |              |
    %       |---------------|               |              |
    %       |               |               |              |
    %       |               |               |              |
    %       |               |               |              |
    %       |               |               |              |
    %       -----------------------------------------------
    %
    % ...3 vertical columns with the left divided into 2
    % panels separated by a horizontal GSplitPaneDivider.
    %
    % When a divider is moved or the parent is resized a chain of callbacks
    % will be triggered.  Although resizing the window will normally fix these
    % problems GSplitSet works best with relatively few dividers
    %
    % For a square grid, use GGrid
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 03/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    properties
        Components={};
        Dividers=[];
        Orientation='';
        Parent=[];
        Type='GSplitSet'
    end
    
    
    methods
        
        function obj=GSplitSet(target, n, orientation)
            obj.Parent=target;
            v=GSplitPane(target, orientation);
            obj.Orientation=v.Orientation;
            if(n>2)
                den=n;
                switch v.Orientation
                    case {'vertical'}
                        fcn=@(x)(1/x);
                    case 'horizontal'
                        fcn=@(x)(1-1/x);
                end
                v.setProportion(fcn(den));
                obj.Components{1}=v.getComponent(1);
                for k=2:n-1
                    den=den-1;
                    v(k)=GSplitPane(v(k-1).getComponent(2), orientation);
                    v(k).setProportion(fcn(den));
                    obj.Components{k}=v(k).getComponent(1);
                end
                obj.Components{k+1}=v(k).getComponent(2);
            else
                obj.Components{1}=v.getComponent(1);
                obj.Components{2}=v.getComponent(2);
            end
            obj.Dividers=v;
            %set(target, 'ResizeFcn', {@ResizeCallback, obj});
            obj.onCleanup();
            drawnow();
            return
        end
        
        function comp=getComponents(obj)
            comp=obj.Components;
            return
        end
        
        function comp=getComponent(obj, index)
            comp=obj.Components{index};
            return
        end
        
        function setProportion(obj, vec)
            den=numel(obj.Dividers)+1;
            if any(vec<0) || any(vec>1)
                error('GSplitSet:Proportion', 'Valid values for vec elements are 0 to 1');
            end
            switch obj.Orientation
                case {'vertical'}
                    obj.Dividers(1).setProportion(vec(1));
                    fcn=@(x,y)((x-y)/(1-y));
                case 'horizontal'
                    obj.Dividers(1).setProportion(1-vec(1));
                    fcn=@(x,y)(1/((1-y)/(1-x)));
            end
            for k=2:den-1
                obj.Dividers(k).setProportion(fcn(vec(k),vec(k-1)));
            end
            return
        end
        
        function revalidate(obj)
            h=obj.Dividers;
            for k=1:numel(h)
                h(k).revalidate();
            end
            h(1).revalidate();
            return
        end
        
        function val=getParent(obj)
            val=obj.Parent;
            return
        end
            
        
    end
end

function ResizeCallback(hObject, EventData, obj)
if isMultipleCall();return;end
set(hObject, 'ResizeFcn', []);
h=obj.Dividers;
for k=1:numel(h)
    h(k).update();
end
h(1).update();
drawnow();
set(hObject, 'ResizeFcn', {@ResizeCallback, obj});
return
end
