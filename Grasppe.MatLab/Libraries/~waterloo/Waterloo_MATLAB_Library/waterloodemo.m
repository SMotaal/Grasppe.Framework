function tabbedPane=waterloodemo(tabInstance)
% waterloodemo demonstrates features of the Waterloo Swing Library
%
% Example:
%       waterloodemo();
%
% Note this is not the tidiest bit of code. For cleaner examples of how to
% use this library see the docs.
%
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 08/2011
% Copyright The Author & King's College London 2011-
% ---------------------------------------------------------------------

%waterloo(2);
GTool.setTheme('blue');
rand('seed',sum(100*clock));

% Create the figure as modal
fh=findobj('Tag', 'waterloodemotopfigure');
if ~isempty(fh);delete(fh);end;
fh=figure('Tag','waterloodemotopfigure', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]); 

% Create a splitpane (vertical in Waterloo terminology which refers to the
% divider rather than the split as in Swing)
splitpane=GSplitPane(fh, 'vertical');

% Add a uipanel to the left side
splitpane.setComponent(1, uipanel('Background', 'b', 'BorderType', 'none'));

% Add a uipanel to the right side
splitpane.setComponent(2, uipanel('Background', 'w', 'BorderType', 'none'));


%--------------------------------------------
% Stage 1
% This is not best-practice. The Next button will be added to the figure.
% We rely on MATLAB keeping it on top via its uistack. Explicitly
% syncronise opacity to stop the button blinking on Windows 7.
Next=jcontrol(fh, javax.swing.JButton('Next'), 'Position', [0.7 0.05 0.16 0.1], 'MouseClickedCallback', @Stage2);
set(Next.hgcontainer, 'Opaque', 'off');
Next.setOpaque(false);

% Add a GTabbedPane - run the demo in this
if nargin==0
    tabbedPane=GTabContainer(splitpane.getComponent(2), 'top');
    tabInstance=tabbedPane.getObject();
%     tabbedPane=GTabbedPane(splitpane.getComponent(2), 'top');
%     tabInstance=javax.swing.JTabbedPane();
else
    tabbedPane=GTabbedPane(splitpane.getComponent(2), 'top', tabInstance);
end
panel=splitpane.getComponent(1);
splitpane.setProportion(0.2);
set(panel, 'BackgroundColor', GColor.getColor(java.awt.Color.white), 'BorderType', 'etchedin', 'BorderWidth', 2);
j1=jcontrol(panel,javax.swing.JPanel(java.awt.BorderLayout()), 'Position', [0.1 0.66 0.8 0.33]);
j1.setBorder(javax.swing.border.TitledBorder('JTree'));
j1.add(javax.swing.JScrollPane(javax.swing.JTree(),javax.swing.JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,...
    javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS));
subpanel=uipanel('Parent', panel, 'Position', [0.1 0.33 0.8 0.33],'BorderType', 'etchedin', 'BorderWidth', 2, 'BackgroundColor', 'w');
axes('Parent', subpanel);
x = 2007:2011;
y=[2,5,7,9,12];
bar(x,y);
axis tight;
set(gca, 'LineWidth', 1, 'Box', 'off');
set(gca, 'XTickLabel', {'A','B','C','D','E'});
j2=jcontrol(panel, javax.swing.JPanel(), 'Position', [0.1 0.05 0.8 0.25]);
j2.setBorder(javax.swing.border.TitledBorder('Buttons'));
j2.setLayout(java.awt.GridLayout(3,3));
for k=1:9
    j2.add(javax.swing.JButton(num2str(k)));
end


textpanel=uipanel(fh, 'Position', [0.3 0.5 0.5 0.3]);
innertextpanel=jcontrol(textpanel, javax.swing.JPanel(java.awt.BorderLayout()), 'Position', [0 0 1 1]);
innertextpanel.setBorder(javax.swing.border.CompoundBorder(...
    javax.swing.border.BevelBorder(javax.swing.border.BevelBorder.RAISED),...
    javax.swing.border.LineBorder(GColor.getColor('k'), 1, true)));
% Here we use a GColor method to return a java.awt.Color given a
% MATLAB letter code
textbox=innertextpanel.add(javax.swing.JTextPane());
textbox.setMargin(java.awt.Insets(10,10,10,10));

%textbox.setLineWrap(true);
%textbox.setWrapStyleWord(true);
str=sprintf('Wellcome to the Waterloo Swing Library demo. You now have a figure with a SplitPane. On the left is a MATLAB uipanel with a mix of Java and MATLAB elements added to it. On the right is a GTabbedPane that is presently empty.\n\n');
str=sprintf('%sUse the mouse to move the divider.\n\nThis text is displayed in a Swing JTextArea, inside a JPanel inside a MATLAB uipanel. You can add almost any Swing component to a MATLAB figure or panel using the jcontrol class that is part of this library. The "GClass" classes just provide MATLAB wrappers for these jcontrols to make things easier if you do not want to delve into Java.\n\nClick the Next button to get something more interesting', str);
textbox.setText(str);
set(textpanel, 'Position', [0.4 0.3 0.4 0.5], 'Visible', 'on');

    % These callbacks control the stages of the demo
    
    function Stage2(hObject, EventData)
        set(Next, 'MouseClickedCallback', @Stage3);
        set(textpanel, 'Visible', 'off');
        % Move the splitpane divider so the left side takes up 1/5th of the
        % view
        % Add a tab to the tab container
        tabbedPane.addTab('View 1');
        % put in some graphics
        [X,Y,Z] = peaks(30);
        surfc(X,Y,Z, 'Parent', axes('Parent', tabbedPane.getComponentAt(1)));
        colormap hsv;
        axis([-3 3 -3 3 -10 5]);
        str=sprintf('Now we have some graphics in a tab of a GTabContainer. Try moving the divider again.\n\nThis demo uses a GTabContainer. You can also use a GTabbedPane which uses a JTabbedPane or JideTabbedPane underneath\n\nThe GTabContainer is theme sensitive. You can change the theme using GTool.setTheme(...) at the MATLAB command line or on your code. Provided themes include blue/red/orange/green/gray and bluegray. To customise the look, just write your own theme m-file using one of these as a template.\n\nClick Next to see some more');
        textbox.setText(str);
        set(textpanel, 'Position', [0.15 0.1 0.45 0.4], 'Visible', 'on');
        return
    end

    function Stage3(hObject, EventData)
        set(Next, 'MouseClickedCallback', @Stage4);
        set(textpanel, 'Visible', 'off');
        % Add another tab..
        tabbedPane.addTab('View 2');
        % ... and put some graphics in it
        topo=load('topo');
        [x y z]=sphere(45);
        ax=axes('Parent', tabbedPane.getComponentAt(2));

        surface(x,y,z,'Parent', ax, 'FaceColor','texturemap','CData',topo.topo);
        axis tight;
        campos([2 13 10]);
        camlight;
        view(-102,36);
        axis('vis3d');
        str=sprintf('Try clicking on the "View 1" and "View 2" Tabs. The view switches between the panels.\n\nNote that some tabs can be undocked or closed by clicking the arrow or cross on the tab. These options are programmable - but please don''t close any tabs until this demo is complete. \n\nClick Next for more');
        textbox.setText(str);
        set(textpanel, 'Position', [0.15 0.6 0.5 0.25], 'Visible', 'on');

        return
    end

    function Stage4(hObject, EventData)
        set(Next, 'MouseClickedCallback', @Stage5);
        set(textpanel, 'Visible', 'off');
        % Another tab...
        tabbedPane.addTab('View 3');
        if ~isempty(strfind(class(tabbedPane.getObject()), 'TabbedPane'));tabbedPane.setDockable(3, false);end
        clzz=tabInstance.getClass();
        if ischar(clzz)
            nestedTab=GTabContainer(tabbedPane.getComponentAt(3), 'bottom');
        else
            newinst=clzz.getConstructor([]).newInstance([]);
            nestedTab=GTabbedPane(tabbedPane.getComponentAt(3), 'bottom', newinst);
        end
        nestedTab.addTab('SubView A');
        nestedTab.addTab('SubView B');
        
        %j4 = jcontrol(nestedTab.getComponentAt(1), javax.swing.JPanel(), 'Position', [0.01 0.45 0.1 0.16]);
        
        % Populate SubView A
        [X,Y] = meshgrid(-8:.5:8);
        R = sqrt(X.^2 + Y.^2) + eps;
        Z = sin(R)./R;
        axes('parent', nestedTab.getComponentAt(1));
        mesh(X,Y,Z);
        % Populate SubView B
        axes('parent', nestedTab.getComponentAt(2));
        t = 0:pi/10:2*pi;
        [X,Y,Z] = cylinder(2+cos(t));
        surf(X,Y,Z);
        axis square;
        str=sprintf('Now we have nested a GTabContainer inside a view of another. Note that the tabs are at the bottom.\n\nYou can also set these left or right on some OSs when using a GTabbedPane instead of a GTabContainer.\n\nTry clicking on the View and SubViews\n\nClick Next for more');
        textbox.setText(str);
        set(textpanel, 'Position', [0.15 0.7 0.5 0.2], 'Visible', 'on');
        
        
        return
    end

    function Stage5(hObject, EventData)
        set(Next, 'MouseClickedCallback', @Stage6);
        set(textpanel, 'Visible', 'off');
        % Another tab...
        tabbedPane.addTab('View 4');
        if ~isempty(strfind(class(tabbedPane.getObject()), 'TabbedPane'));tabbedPane.setDockable(4, false);end
        axes('parent', tabbedPane.getComponentAt(4),'OuterPosition', [0 0.25 1 0.75]);
        [X,Y] = meshgrid(-2:.2:2);
        Z = X.*exp(-X.^2 - Y.^2);
        [DX,DY] = gradient(Z,.2,.2);
        contour(X,Y,Z);
        hold on;
        quiver(X,Y,DX,DY);
        hold off;
        set(gca, 'LineWidth', 4, 'Box', 'on');
        % Add a new split pane to this tab's component - but make it a
        % GElasticPane and place it at the bottom of its container
        elasticPane=GElasticPane(tabbedPane.getComponentAt(4), 'bottom');
        elasticPane.ZOrder=3;
        axes('parent', elasticPane.getComponent(2));
        [x,y] = meshgrid(-3:.5:3,-3:.1:3);
        z = peaks(x,y);
        ribbon(y,z)
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        str=sprintf('Now we have created another tab and added a split pane to that. But this one is different - its a GElasticPane which returns to its original position after you have moved it and draws over other graphics. Try it out. This is more useful for GUIs, for example to show a folder tree in the left hand panel of this figure.\n\nClick Next for more');
        textbox.setText(str);
        set(textpanel, 'Position', [0.05 0.3 0.4 0.5], 'Visible', 'on');
        setZOrder(innertextpanel,0);
        return
    end

    function Stage6(hObject, EventData)
        set(Next, 'MouseClickedCallback', @Stage7);
        set(textpanel, 'Visible', 'off');
        % Add a GFlyoutPanel to the right of figure
        flyoutPanel=GFlyoutPanel(fh, 'right');
        % Add a Swing JPanel to the uipanel associated with the
        % GFlyoutPanel
        panel=jcontrol(flyoutPanel.getComponent(1), javax.swing.JPanel(), 'Position', [0 0 1 1], 'Background', GColor.getColor('w'), 'Visible', 'off');
        panel.setBorder(javax.swing.border.LineBorder(java.awt.Color.black,1,true));
        panel.setName('FlyoutJPanel');
        panel.setLayout(java.awt.GridLayout(10,1));
        % Put some buttons in the JPanel and have them alter the text in
        % the message box through their callbacks
        for k=1:10
            button=panel.add(javax.swing.JButton(num2str(k)));
            button=handle(button, 'callbackproperties');
            set(button, 'MouseClickedCallback', {@LocalCallback, k});
        end
        str=sprintf('It may look as though nothing has happened, but it has.\n\nMove the mouse over to the right hand side of the figure. A new panel should appear with some buttons. Note the panel disappears when you move the cursor away from it within the figure. Click on a button in the panel, then click Next.\n');
        textbox.setText(str)
        set(textpanel, 'Position', [0.05 0.4 0.5 0.45], 'Visible', 'on');
        function LocalCallback(hObject, EventData, num)
            try
                str=sprintf('%s\nYou  clicked Button %d', char(textbox.getText()),num);
                textbox.setText(str);
            catch
            end
            return
        end
        return
    end

    function Stage7(hObject, EventData)
        % Nothing here but a new message
        set(Next, 'MouseClickedCallback', @Stage8);
        str=sprintf('The buttons you just saw were in a GFlyoutPanel. You can add these to any one or all of the four sides of a figure. The superclass for GFlyoutPanel is GBasicHotSpot. You can put hotspots anywhere in a figure. If SwingX is installed, you can use a GSideBar - essentially just a GFlyoutPanel but one that is animated.\n\n Press Next to continue.');
        textbox.setText(str);
        return
    end

    function Stage8(hObject, EventData)
        % Mundane wait boxMLComponentContainer
        set(textpanel, 'Position', [0.02 0.4 0.25 0.4]);
        gw=GWait();
        set(Next, 'MouseClickedCallback', {@Stage9, gw});
        str=sprintf('Now we have added a GWait panel. This just displays some text and a GIF (that can be animated) until it is closed or programatically deleted.\nYou can set the GIF yourself or use one of several default GIFs from http://www.sevenoaksart.co.uk.\n\nSome of the default GIFs are quite silly!\n\nPress Next to continue.');
        textbox.setText(str);
        return
    end

    function Stage9(hObject, EventData, gw)
        set(Next, 'MouseClickedCallback', @Stage10);
        % Progress Bar
        try 
            delete(gw);
        catch
        end
        gp=GProgressBar(fh, 'This is a Progress Bar', 'This text can also be updated while running');
        gp.setMinimum(0);
        gp.setMaximum(10);
        str=sprintf('More useful is the GProgressBar now showing. The progress bar is programatically controlled and automatically calculates the estimated time remaining. Shortly, MATLAB will start running a loop. Its progress will be shown in the GProgressBar. When the loop finishes the bar will disappear.\n\nPress Next to continue.');
        textbox.setText(str);
        % The constructor issues a start so issue a reset here to let the
        % indterminate bar show up for a while
        gp.reset();
        pause(1);
        gp.start();
        % Note the progess bar display is updated by a timer, not by this loop
        for k=1:10
            gp.Value=k;
            pause(0.25);
        end
        delete(gp);
        return
    end

    function Stage10(hObject, EventData)
        textbox.setText(sprintf('What you see next is context-sensitive\n\nClick next to continue'));
        if ~isempty(strfind(class(tabbedPane.getObject()), 'TabbedPane'))
            set(Next, 'MouseClickedCallback', @Stage11);
        else
            set(Next, 'MouseClickedCallback', @Stage12);
        end
    end

    function Stage11(hObject, EventData)
        set(Next, 'MouseClickedCallback', @Stage12);
        j=javax.swing.JPanel(java.awt.GridLayout(1,10));
        for k=1:10
            button=j.add(javax.swing.JButton(num2str(k)));
            button=handle(button, 'callbackproperties');
            set(button, 'MouseClickedCallback', {@LocalCallback, k});
        end
        if ~isempty(strfind(class(tabbedPane.getObject()), 'TabbedPane'))
            tabbedPane.addTab('View 5', j);
            tabbedPane.setDepth(75);
            tabbedPane.getObject().setBackground(java.awt.Color.white);
            tabbedPane.getObject().setBackgroundAt(4,java.awt.Color.white);
        else
            tabbedPane.addTab('View 5');
        end
        colormap bone;
        axes('Parent', tabbedPane.getComponentAt(5));
        [x,y,z] = cylinder(1:10);
        surfnorm(x,y,z)
        axis([-12 12 -12 12 -0.1 1]);
        set(gca, 'LineWidth', 4, 'Box', 'on');
        str=sprintf('The GTabContainers use a GCardPane to present MATLAB graphics. That is where you see the plots.\n\nThe underlying Java Swing JTabbedPane associated with each GTabbedPane can also be used to house Swing components as shown here. Try clicking on some buttons.\n\nPress Next to continue.');
        set(textpanel, 'Position', [0.25 0.2 0.25 0.45], 'Visible', 'on');
        textbox.setText(str);
        
        function LocalCallback(hObject, Eventdata, num)
            try
                str=sprintf('%s\nYou  clicked Button %d', char(textbox.getText()),num);
                textbox.setText(str);
            catch
            end
            return
        end
        return
    end


    function Stage12(hObject, EventData)
        set(textpanel, 'Position', [0.3 0.2 0.4 0.6], 'Visible', 'on');
        set(Next, 'MouseClickedCallback', @Stage13);
        str=sprintf('You may have noticed that the colors in the figures changed as we ran through the demo. That''s because MATLAB only has one colormap for each figure. Next, we''ll set a new StateChange callback to change the depth of the JTabbedPane and also use it to change the MATLAB colormap so that we can effectively have more than one in a single figure.\n\nPress Next to clear this box and view the graphics.');
        set(tabbedPane.getObject(), 'StateChangedCallback', @LocalStateChange);
        textbox.setText(str);
        function LocalStateChange(hObject, EventData)
            % Note this Java, so idx will be zero-based
            idx=tabbedPane.getSelectedIndex();
            tabbedPane.setDepth(30);
            switch idx
                case 1
                    colormap hsv
                case 2
                    colormap([GColor.getMonochrome('b',64); GColor.getMonochrome([1 .4 0],65)]);
                case 3
                    colormap jet
                case 4
                    colormap copper
                case 5
                    colormap bone
                    if ~isempty(strfind(class(tabbedPane.getObject()), 'TabbedPane'))
                        tabbedPane.setDepth(75);
                    end
            end
            tabbedPane.setSelectedIndex(idx);
            return
        end
    end

    function Stage13(hObject, EventData)
        set(textpanel, 'Position', [0.1 0.1 0.01 0.01],'Visible', 'off');
        set(Next, 'MouseClickedCallback', @Stage14);
        return
    end

    function Stage14(hObject, EventData)
        fh2=figure();
        set(Next, 'MouseClickedCallback', {@Stage15, fh2});
        % Create a GAccordion
        GTool.setTheme('red');
        g=GAccordion(fh2);
        g.setAnimated(false);
        g.addTab('Panel 1');
        g.addTab('Panel 2');
        g.addTab('Panel 3');
        axes('parent', g.getComponentAt(1));
        [x,y] = meshgrid(-3:.5:3,-3:.1:3);
        z = peaks(x,y);
        ribbon(y,z);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        [X,Y,Z] = peaks(30);
        surfc(X,Y,Z, 'Parent', axes('Parent', g.getComponentAt(2)));
        colormap hsv;
        axis([-3 3 -3 3 -10 5]);
        [X,Y] = meshgrid(-8:.5:8);
        R = sqrt(X.^2 + Y.^2) + eps;
        Z = sin(R)./R;
        axes('parent', g.getComponentAt(3));
        mesh(X,Y,Z);
        g.setAnimated(true);
        textbox.setText(sprintf('Now we have a GAccordion with 3 panels in a new figure (It could have been added to the tabbed pane but that''s not a likely use).\nNote that we also switched color theme for this component.\nYou can select the panel by clicking on the banners at the top or use the buttons to undock them, reveal/hide them or close them. Undocked panels are shown in a new figure. You can redock them by clicking the button in that figure.\nNote the Swing Library also has a GTabbedContainer - that requires SwingX and is not included in the demo.\n\nPress Next to continue'));
        set(textpanel, 'Position', [0.8 0.3 0.2 0.65], 'Visible', 'on');
    end

    function Stage15(hObject, EventData, fh2)
        if ishandle(fh2);delete(fh2);end;
        Next.setText('Finish');
        set(Next, 'MouseClickedCallback', @EndStage);
        str=sprintf('The Waterloo Swing Library is fairly new. It will be expanded in the future so, if you find useful, keep an eye on the FEX or on the main website at http://sourceforge.net/projects/waterloo/.\n\nBug reports and feature requests are welcome.\nPlease send them to sigtool@kcl.ac.uk.\n\nPress Finish.');
        textbox.setText(str);
        set(textpanel, 'Visible', 'on');
        set(textpanel,'Position', [0.01 0.2 0.2 0.6]);
        uistack(textpanel, 'top');
        return
    end


    function EndStage(hObject, EventData)
        delete(Next);
        delete(textpanel);
        return
    end

end