classdef GGrid < GTool
    % GGrid convenience wrapper class for multiple GSplitPanes
    % GGrid creates a grid of GSplitPanes
    %
    % Example:
    %       x=GGrid(parent, m, n);
    %           creates a rectangle of GSplitPanes in parent with m rows and
    %           n columns
    %
    % When a divider is moved or the parent is resized a chain of callbacks
    % will be triggered. As m x n increases, you may see some elements
    % improperly sized. Although resizing the window will normally fix these
    % problems GGrid works best with lower m x n.
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    %
    % Author: Malcolm Lidierth 12/10
    % Copyright The Author & King's College London 2011-
    % ---------------------------------------------------------------------
    
    properties
        Components;
        Parent=[];
        Type='GGrid'
    end
    
    
    methods
        
        function obj=GGrid(target, m, n)
            obj.Parent=target;
            set(target, 'Visible', 'off');
            obj.Components{1}=GSplitSet(target, n, 'vertical');
            set(target, 'Visible', 'on');
            for k=1:n
                GSplitSet(obj.Components{1}.Components{k}, m, 'horizontal');
            end
            
        return
        end
        
        function comp=getComponent(obj,k)
            comp=obj.Components{k};
            return
        end
        
    end
    
end