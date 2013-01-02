classdef GBar < GTool
    % GBar superclass for wait bars
    % The GBar superclass is not invoked directly but called from its
    % subclasses
    %
    %----------------------------------------------------------------------
    % Part of Project Waterloo and the sigTOOL Project at King's College
    % London.
    % Author: Malcolm Lidierth 03/11
    % Copyright © The Author & King's College London 2011-
    % Email: sigtool (at) kcl.ac.uk
    % ---------------------------------------------------------------------
    
    
    methods
        
        function obj=GBar(target, bordertitle)
            obj.Object=handle(javaObjectEDT(javax.swing.JFrame(bordertitle)), 'callbackproperties');
            obj.Object().setResizable(false);
            obj.Object().setAlwaysOnTop(true);
            obj.Object().setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
            
            set(obj.Object, 'WindowClosingCallback', {@WindowClosingCallback, obj});
            if nargin>0 && ~isempty(target) && target>0
                scp=MUtilities.getFigureWindow(target);
                scp=scp.getBounds();
                x=scp.getX()+scp.getWidth()/2;
                y=scp.getY()+scp.getHeight()/2;
            else
                scp=get(0,'ScreenSize')/2;
                x=scp(3);
                y=scp(4);
            end
            
            obj.Object.setBounds(java.awt.Rectangle(x-125,y-50,1,1));
            obj.Components{1}=obj.Object.getContentPane().add(javax.swing.JPanel());
            obj.Components{1}.setPreferredSize(java.awt.Dimension(250,75));
            obj.Components{1}.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.CENTER));
            obj.Object.pack();
            obj.Object.setVisible(true);
            return
        end
        
        function img=setIcon(obj, img)
            % setIcon sets the icon for the bar
            if nargin<2 || isempty(img)
                x=rand(1,1);
                if x<1/8
                    img=javax.swing.ImageIcon(which('cogs1.gif'));
                elseif x<2/8
                    img=javax.swing.ImageIcon(which('cogs2.gif'));
                elseif x<3/8
                    img=javax.swing.ImageIcon(which('cogs3.gif'));
                elseif x<4/8
                    img=javax.swing.ImageIcon(which('booksmall.gif'));
                elseif x<5/8
                    img=javax.swing.ImageIcon(which('type1.gif'));
                elseif x<6/8
                    img=javax.swing.ImageIcon(which('rings.gif'));
                elseif x<7/8
                    img=javax.swing.ImageIcon(which('windmillblue2.gif'));
                else
                    img=javax.swing.ImageIcon(which('falseteeth.gif'));
                end
                obj.Components{2}.setToolTipText('Artwork from http://www.sevenoaksart.co.uk/');
            elseif ischar(img)
                img=javax.swing.ImageIcon(which(img));
            end
            obj.Components{2}.setIcon(img);
            return
        end
        
        function setTitle(obj, str)
            % setTitle sets the title
            obj.Components{1}.setTitle(str);
            return
        end
        
        function close(obj)
            delete(obj);
            return
        end
        

        function delete(obj)
            obj.Object.dispose();
            return
        end
        
    end
    
end

function WindowClosingCallback(hObject, EventData, obj)
if isvalid(obj)
    delete(obj);
end
return
end