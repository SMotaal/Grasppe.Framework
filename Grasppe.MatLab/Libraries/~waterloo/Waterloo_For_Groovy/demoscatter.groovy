import kcl.waterloo.demo.TestDataManager
import kcl.waterloo.marker.GJMarker
import kcl.waterloo.plot.WPlot
import java.awt.Color
TestDataManager data = new TestDataManager();
def w1=WPlot.scatter('XData': data.x1,
      'YData': data.y1,
      'Marker': GJMarker.Circle(5),
      'Fill': Color.blue)
def w2=WPlot.line('XData': data.x2,
      'YData': data.y2,
       'LineColor': "BLUE")
w1+=w2
for (def k=0;k<data.y1.length;k++)
      data.y1[k]=data.y1[k]*2
for (def k=0;k<data.y2.length;k++)
      data.y2[k]=data.y2[k]*2
def w3=WPlot.scatter('XData': data.x1,
      'YData': data.y1,
      'Marker': GJMarker.Square(5),
      'Fill': Color.green)
def w4=WPlot.line('XData': data.x2,
      'YData': data.y2,
      'LineColor': "GREEN")
w3+=w4
def f=w1.createFrame()
w1.getPlot().getParentGraph() + w3.getPlot()
w1.getPlot().getParentGraph().autoScale()
