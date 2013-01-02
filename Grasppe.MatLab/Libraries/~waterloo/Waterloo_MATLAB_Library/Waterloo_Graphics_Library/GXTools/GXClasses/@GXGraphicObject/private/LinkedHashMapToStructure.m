function s=LinkedHashMapToStructure(map)

BLUE=java.awt.Color.BLUE;

s.BarLayout= [];
s.BarWidth= [];
s.BaseLine= [];
s.BaseValue= [];
s.CData= [];
s.Color=BLUE ;
s.CreateFcn= [];
s.DeleteFcn= [];
s.DisplayName= [];
s.EdgeColor= BLUE;
s.FaceColor= [];
s.HitTest= [];
s.LineWidth= 1;
s.LineSpec= [];
s.LineStyle= [];
s.Marker= [];
s.MarkerEdgeColor= BLUE;
s.MarkerFaceColor= BLUE;
s.MarkerFcn= [];
s.MarkerSize= 5;
s.ShowBaseline= [];
s.SizeData= [];
s.Visible= [];
s.LeftData= [];
s.LData= [];
s.RightData= [];
s.XData= [];
s.UData= [];
s.YData= [];
s.ZData= [];

keys=map.keySet().toArray;
for k=1:numel(keys)
    s.(char(keys(k)))=map.get(keys(k));
end
return
