

javaclasspath('/Volumes/BOOTCAMP/waterloo/Waterloo_Java_Library/GraphExplorer/dist/GraphExplorer.jar')

//javaclasspath('/Volumes/BOOTCAMP/waterloo/waterlooPlot/out/artifacts/waterlooPlot_//jar/waterlooPlot.jar');

//jimport kcl.waterloo.plot.WPlot
//wb=WPlot.scatter([]);
//p=wb.getPlot();
//p.setXData(1:10);
//p.setYData(1:10);
//wb.createFrame();

//jimport groovy.ui.Console
//wb=Console.new()
//wb.run()

jimport kcl.waterloo.explorer.GraphExplorer
T = jinvoke(GraphExplorer, "createInstance");

