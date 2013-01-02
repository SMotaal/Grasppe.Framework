function TestQuiver()

if ispc() 
    if strcmp(java.lang.System.getProperties().get('sun.java2d.noddraw'), 'true') &&...
        strcmp(java.lang.System.getProperties().get('sun.java2d.d3d'),'false')
    java.lang.System.err.println('N.B. You are on Windows and the DirectX graphics pipeline is not enabled so rendering may be slow.')
    end
end

% Set up and create some data
f=GXFigure();
set(f.Parent, 'Units', 'normalized', 'Position', [.2 .2 .6 .6], 'Name', 'TestQuiver');

[X,Y] = meshgrid(-2:.2:2);
Z = X.*exp(-X.^2 - Y.^2);
[DX,DY] = gradient(Z,.2,.2);

gr1=subplot(gxgcf,2,2,1);
q1=quiver(gr1,X,Y,DX,DY, 0.9);;
gr1.getObject().setTitleText('Scale Factor 0.9');
gr1.getObject().getView().autoScale();

gr2=subplot(gxgcf,2,2,2);
arr=kcl.waterloo.plotmodel2D.GJCyclicArrayList();
arr.add(java.awt.Color.red);
arr.add(java.awt.Color.green);
arr.add(java.awt.Color.blue);
q2=quiver(gr2,X,Y,DX,DY, 40, 'Fill', arr, 'LineColor', arr);
gr2.getObject().getView().setAxesBounds(-5, -5, 14, 10);
gr2.getObject().setTitleText('Scale Factor 40: fun but not much use');
gr2.getObject().getView().autoScale();

gr3=subplot(gxgcf,2,2,3);
q3=quiver(gr3, X, Y, DX, DY, 1, 'LineWidth', 1.5);
gr3.getObject().getView().getPlots().get(0).setUseQuad(false);
gr3.getObject().setTitleText('Scale Factor = 1: useQuad = false');
gr3.getObject().getView().autoScale();

gr4=subplot(gxgcf,2,2,4);
q4=quiver(gr4, DX, DY, 0.9 , 'd-c', 'MarkerSize', 1.5);
gr4.getObject().setTitleText('Markers at origins');
gr4.getObject().getView().autoScale();



% disp('Doing save to XML test:')
% disp('Test1.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir(),'Test1.xml'), gr1.getObject().hgcontrol);
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% file=fullfile(tempdir(),'Test1v2.xml');
% gr1.getObject().saveAsXML(file);
% % kcl.waterloo.xml.XMLChecker.check([file '.gz']);
% % disp('+++++');
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% 
% disp('Test2.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir(),'Test2.xml'), gr2.getObject().hgcontrol);
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% file=fullfile(tempdir(),'Test2v2.xml');
% gr2.getObject().saveAsXML(file);
% % kcl.waterloo.xml.XMLChecker.check([file '.gz']);
% % disp('+++++');
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% 
% disp('Test3.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir(),'Test3.xml'), gr3.getObject().getView());
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% 
% disp('Test4.xml');
% kcl.waterloo.xml.GJEncoder.save(fullfile(tempdir(),'Test4.xml'), gr4.getObject().getView().getPlots().get(0));
% if (kcl.waterloo.xml.GJEncoder.getExceptionLog().size()>0); disp(kcl.waterloo.xml.GJEncoder.getExceptionLog());end;
% 
% disp(' ');
end

