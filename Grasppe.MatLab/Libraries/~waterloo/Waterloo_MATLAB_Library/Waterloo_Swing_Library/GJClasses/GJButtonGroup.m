classdef GJButtonGroup < GJBasic & hgsetget
    
    
    
    methods
    function obj=GJButtonGroup(m, n, buttonwidth, buttonheight)
        obj.Object=javax.swing.JPanel();
        thisLayout=java.awt.GridLayout(m,n);
        obj.Object.setLayout(thisLayout);
        if nargin==4
        obj.Object.setPreferredSize(java.awt.Dimension(buttonwidth*m, buttonheight*n));
        end
        for k=1:m*n
            thisButton=obj.Object.add(javax.swing.JButton(sprintf('%d', k)));
            if nargin==4
            thisButton.setPreferredSize(java.awt.Dimension(buttonwidth, buttonheight));
            end
        end
        obj.Created=now();
    end
    end
    
    
    
end