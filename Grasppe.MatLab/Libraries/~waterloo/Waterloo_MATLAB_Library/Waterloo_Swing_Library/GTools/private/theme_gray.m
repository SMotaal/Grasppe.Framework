function gray()
Defaults=GTool.getDefaults();
javaloaded=java.lang.System.getProperty('Waterloo.JavaLoaded');
if isempty(javaloaded)
    Defaults.put('Accordion.Panel', '@javax.swing.JPanel()');
    Defaults.put('Accordion.InnerBannerBackground','@java.awt.Color(0,0,0,0)');
    Defaults.put('Accordion.BannerBackground', '@GColor.getColor(''MATLAB_darkGray'')');
    Defaults.put('Accordion.TextColor', '@java.awt.Color.black');
    
    Defaults.put('TabDisplay.Panel','@javax.swing.JPanel()');
    Defaults.put('TabDisplay.Background', '@GColor.getColor(''MATLAB_darkGray'')');
    Defaults.put('TabDisplay.TextColor', '@java.awt.Color.black');
    
    Defaults.put('Divider.SplitPaneContainer', '@javax.swing.JPanel()');
    Defaults.put('Divider.Fill', '@GColor.getColor(''MATLAB_darkGray'')');
else
    Defaults.put('Accordion.Panel', '@kcl.waterloo.widget.GJGradientPanel()');
    Defaults.put('Accordion.InnerBannerBackground','@java.awt.Color(0,0,0,0)');
    Defaults.put('Accordion.BannerBackground', '@java.awt.GradientPaint(0,0,GColor.getColor(''MATLAB_darkGray''),1,1,GColor.getColor(''MATLAB_lightGray''),true)');
    Defaults.put('Accordion.TextColor', '@java.awt.Color.black');
    
    Defaults.put('TabDisplay.Panel', '@kcl.waterloo.widget.GJGradientPanel()');
    Defaults.put('TabDisplay.Background', '@java.awt.GradientPaint(0,0,GColor.getColor(''MATLAB_darkGray''),1,1,GColor.getColor(''MATLAB_lightGray''),true)');
    Defaults.put('TabDisplay.TextColor', '@java.awt.Color.black');
    
    Defaults.put('Divider.SplitPaneContainer', '@kcl.waterloo.widget.GJGradientPanel()');
    Defaults.put('Divider.Fill', '@java.awt.GradientPaint(0,0,GColor.getColor(''MATLAB_darkGray''),1,1,GColor.getColor(''w''),true)');
end


Defaults.put('TabDisplay.Icon.UNDOCK',javax.swing.ImageIcon(which('undock.png')));
Defaults.put('TabDisplay.Icon.CLOSE',javax.swing.ImageIcon(which('close.png')));

return
end