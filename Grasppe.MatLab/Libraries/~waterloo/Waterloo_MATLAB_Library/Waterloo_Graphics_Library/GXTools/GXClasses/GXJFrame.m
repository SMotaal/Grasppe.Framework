function obj=GXJFrame(target, title, contents, alpha)
% GXJFrame function - creates and returns a javax.swing.JFrame
% 
% Example:
% frame=GXJFrame(target);
% frame=GXJFrame(target, title)
% frame=GXJFrame(target, title, contents)
% frame=GXJFrame(target, title, contents, alpha)
% 
% Where:
%         target      is a MATLAB container used to center the position of the
%                     JFrame
%         title       is the title for the JFrame
%         contents    is a Java Swing container. This will be added to and fill
%                     the JFrame. The size of the JFrame will be set to
%                     contents.getPreferredSize()
%         alpha       if supplied sets the opacity of the JFrame: 0 to 1
%                     (transparent to opaque)
% To use GXJFrame with GImport, create a frame then add it to a GImport instance:
%                     frame=GXJFrame(target);
%                     g=GImport(frame, javaobject, includeFlag);
%
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

if isa(target, 'javahandle_withcallbacks.javax.swing.JFrame')
    % Existing JFrame
    obj=target;
    bounds=target.getBounds();
    x=bounds.getX();
    y=bounds.getY();
else
    % Need to create JFrame
    if nargin<2
        title='';
    end
    obj=handle(javaObjectEDT(javax.swing.JFrame(title)), 'callbackproperties');
    obj.setResizable(true);
    obj.setAlwaysOnTop(true);
    obj.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
    if nargin>0 && ~isempty(target) && target>0 && ishandle(target)
        scp=MUtilities.getFigureWindow(target);
        scp=scp.getBounds();
        x=scp.getX()+scp.getWidth()/2;
        y=scp.getY()+scp.getHeight()/2;
    else
        scp=get(0,'ScreenSize')/2;
        x=scp(3);
        y=scp(4);
    end
end

% Add contents and size JFrame
if nargin==3 && ~isempty(contents)
    sz=contents.getPreferredSize();
    x=x-sz.getWidth()/2;
    y=y-sz.getHeight()/2;
    x=max(x,0);
    y=max(y,0);
    obj.setBounds(java.awt.Rectangle(x,y,sz.getWidth(),sz.getHeight()));
    obj.getContentPane().add(contents);
    contents.revalidate();
    obj.pack();
else
    obj.setBounds(java.awt.Rectangle(x-50,y-50,100,100));
end

% Set it visible
obj.setVisible(true);

% Set transparency
if nargin==4
    try
        % JVM specific for Java 6
        com.sun.awt.AWTUtilities.setWindowOpacity(obj, alpha);
    catch %#ok<CTCH>
        % Java 7 ?
        try
            obj.setOpacity(alpha);
        catch %#ok<CTCH>
        end
    end
end

return
end

