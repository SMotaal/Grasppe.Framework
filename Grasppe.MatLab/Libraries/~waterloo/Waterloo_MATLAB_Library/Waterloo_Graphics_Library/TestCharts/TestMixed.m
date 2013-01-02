function TestMixed()

if ispc() 
    if strcmp(java.lang.System.getProperties().get('sun.java2d.noddraw'), 'true') &&...
        strcmp(java.lang.System.getProperties().get('sun.java2d.d3d'),'false')
    java.lang.System.err.println('N.B. You are on Windows and the DirectX graphics pipeline is not enabled so rendering may be slow.')
    end
end

% Set up and create some data
f=GXFigure();
set(f.Parent, 'Units', 'normalized', 'Position', [.2 .2 .6 .6], 'Name', 'Mixed MATLAB and Waterloo Graphics');


% MATLAB quiver plot. The subplot call here returns a MATLAB axes handle.
[X,Y] = meshgrid(-2:.2:2);
Z = X.*exp(-X.^2 - Y.^2);
[DX,DY] = gradient(Z,.2,.2);
gr1=subplot(2,2,1);
q1=quiver(X,Y,DX,DY, 0.9);
axis('tight')

% Waterloo errorbar plot. The subplot call here includes the GXFigure
% reference in its input list (here we use f from above), so invokes the
% overloaded subplot to return a GXGraph in gr2. We can use gr2 or a copy
% of it retrieved by a call to gxgca.
gr2=subplot(f, 2, 2, 2);
x=0.5:0.5:10;
y=log(x);
a1=errorbar(gxgca, x, y, [], y/3.5,'LineSpec', '-ob');
b1=errorbar(gxgca, x, y*2, [], y/3.5*2,'LineSpec', '-sg');
c1=errorbar(gxgca, x, y*5, [], y/3.5*5,'LineSpec', '-dr');
d1=errorbar(gxgca, x, y*10, [], y/3.5*10,'LineSpec', '-^m');
gr2.getObject().setTitleText('Mode 2');
gr2.getObject().getView().autoScale();

% Waterloo quiver plot. Use gxgcf instead of f.
gr3=subplot(gxgcf,2,2,3);
q3=quiver(gr3, X, Y, DX, DY, 1, 'LineWidth', 1.5);
gr3.getObject().getView().getPlots().get(0).setUseQuad(false);
gr3.getObject().setTitleText('Scale Factor = 1: useQuad = false');
gr3.getObject().getView().autoScale();

% MATLAB surface plot.
subplot(2,2,4);
k= 5;
n = 2^k-1;
[x,y,z] = sphere(n);
c = hadamard(2^k);
surf(x,y,z,c );
colormap([1  1  0; 0  1  1])
axis equal


end

