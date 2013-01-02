function TestQuiver2()


% Set up and create some data
f=GXFigure();
set(f.Parent, 'Units', 'normalized', 'Position', [.2 .2 .6 .6], 'Name', 'TestQuiver');

[X,Y] = meshgrid(-2:.2:2);
Z = X.*exp(-X.^2 - Y.^2);
[DX,DY] = gradient(Z,.2,.2);

gr1=subplot(gxgcf,2,2,1);
quiver2(gr1,X,Y,DX,DY, 0.9);
gr1.getObject().setTitleText('Scale Factor 0.9');

gr2=subplot(gxgcf,2,2,2);
Color(1)=java.awt.Color.red;
Color(2)=java.awt.Color.green;
Color(3)=java.awt.Color.blue;
q=quiver2(gr2,X,Y,DX,DY, 40, 'Fill', Color, 'LineColor', Color)
gr2.getObject().getView().setAxesBounds(-5, -5, 14, 10);
gr2.getObject().setTitleText('Scale Factor 40: fun but not much use');

gr3=subplot(gxgcf,2,2,3);
quiver2(gr3, X, Y, DX, DY, 0.75, 'LineWidth', 1.5);
gr3.getObject().getView().getPlots().get(0).setUseQuad(false);
gr3.getObject().setTitleText('Scale Factor = Zero: useQuad = false');

gr4=subplot(gxgcf,2,2,4);
quiver2(gr4, DX, DY, 0.9 , 'd-c', 'MarkerSize', 1.5);
gr4.getObject().setTitleText('Markers at origins');


drawnow();

disp('Doing save to XML test:')
disp('Test1.xml');

kcl.waterloo.XMLCoder.GJEncoder.save('Test1.xml', gr1.getObject().hgcontrol);
if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
disp('Test2.xml');

kcl.waterloo.XMLCoder.GJEncoder.save('Test2.xml', gr2.getObject().hgcontrol);
if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
disp('Test3.xml');

kcl.waterloo.XMLCoder.GJEncoder.save('Test3.xml', gr3.getObject().getView());
if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
disp('Test4.xml');

kcl.waterloo.XMLCoder.GJEncoder.save('Test4.xml', gr4.getObject().getView().getPlots().get(0));
if (kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.XMLCoder.GJEncoder.getExceptionLog());end;
end

