function green()
Defaults=GTool.getDefaults();
javaloaded=java.lang.System.getProperty('Waterloo.JavaLoaded');
if isempty(javaloaded)
    Defaults.put('Accordion.Panel', '@javax.swing.JPanel()');
    Defaults.put('Accordion.InnerBannerBackground','@java.awt.Color(0,0,0,0)');
    Defaults.put('Accordion.BannerBackground', '@GColor.getColor(''darkGreen'')');
    Defaults.put('Accordion.TextColor', '@GColor.getColor(''MATLAB_lightGray'')');
    
    Defaults.put('TabDisplay.Panel','@javax.swing.JPanel()');
    Defaults.put('TabDisplay.Background', '@GColor.getColor(''darkGreen'')');
    Defaults.put('TabDisplay.TextColor', '@GColor.getColor(''MATLAB_lightGray'')');

else
    Defaults.put('Accordion.Panel', '@kcl.waterloo.widget.GJGradientPanel()');
    Defaults.put('Accordion.InnerBannerBackground','@java.awt.Color(0,0,0,0)');
    Defaults.put('Accordion.BannerBackground', '@java.awt.GradientPaint(0,0,GColor.getColor(''darkGreen''),1,1,GColor.getColor(''lightGreen''),true)');
    Defaults.put('Accordion.TextColor', '@GColor.getColor(''MATLAB_lightGray'')');
    
    Defaults.put('TabDisplay.Panel', '@kcl.waterloo.widget.GJGradientPanel()');
    Defaults.put('TabDisplay.Background', '@java.awt.GradientPaint(0,0,GColor.getColor(''darkGreen''),1,1,GColor.getColor(''lightGreen''),true)');
    Defaults.put('TabDisplay.TextColor', '@GColor.getColor(''MATLAB_lightGray'')');
    

end


Defaults.put('TabDisplay.Icon.UNDOCK',javax.swing.ImageIcon(which('undock_gray.png')));
Defaults.put('TabDisplay.Icon.CLOSE',javax.swing.ImageIcon(which('close_gray.png')));

return
end