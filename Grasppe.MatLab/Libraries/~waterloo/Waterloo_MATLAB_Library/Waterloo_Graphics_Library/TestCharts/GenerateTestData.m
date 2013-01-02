function GenerateTestData()

fileName=fullfile(char(java.lang.System.getProperty('user.home')),'TestData.xml');
buffer = java.io.BufferedOutputStream(java.io.FileOutputStream(fileName));
encoder=java.beans.XMLEncoder(buffer);
kcl.waterloo.xml.GJEncoder.setContext(encoder);
kcl.waterloo.xml.GJEncoder.addDelegates(encoder);

% y=log(x)
x=0.5:0.5:12;
y=log(x);
encoder.writeObject(x);
encoder.writeObject(y);

x=0.5:0.05:12;
y=log(x);
encoder.writeObject(x);
encoder.writeObject(y);

% y=sin(2*t).*cos(2*t)
t= 0:.035:2*pi;
[a,b]=pol2cart(t,sin(2*t).*cos(2*t));
encoder.writeObject(a);
encoder.writeObject(b);

% y=sin(x)
x = linspace(-2*pi,2*pi,40);
y=sin(x);
encoder.writeObject(x);
encoder.writeObject(y);

% Contour
Z = peaks;
[C,h] = contour(interp2(Z,4));
object=kcl.waterloo.graphics.plots2D.ContourExtra.createFromMatrix(C);
encoder.writeObject(object);

encoder.close();
buffer.close();

return 
end

