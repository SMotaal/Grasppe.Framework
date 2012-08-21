% converts CIELab L*a*b* to XYZ tristimulus values
%
% [ XYZ ] = Lab2XYZ( Lab )
%
% where "XYZ" is a 3 x n array of tristimulus values, "XYZn" is a 3 x 1
% vector representing tristimulus values of the illuminant white point (Xn;
% Yn; Zn) and "Lab" is a 3 x n array of L*a*b* value

function [ XYZ ] = Lab2XYZ(Lab, XYZn)
%function [Lab] = XYZ2Lab(XYZ,XYZn)

%	Use relation expressions and dig function and not loops or find function
%	- Compute XYZ to XYZn ratios using ?ratio = diag(1./XYZn)*XYZ;?
%	- Compute f(x) using logical indexing to implement the conditional
%	- Compute the CIELAB values


X = 1; Y = 2; Z = 3;
L = 1; a = 2; b = 3;

k =  903.3;
e = 0.008856;

fY = (Lab(L,:)+16)./116;
fX = Lab(a,:)./500 + fY;
fZ = fY - Lab(b,:)./200;

xR = fX.^3.0;
xN = (116.*fX-16)./k;
x1 = xR>e;
xr = (xR.*x1+xN.*~x1);

yR = fY.^3.0;
yN = Lab(L,:)./k;
y1 = Lab(L,:)>(e*k);
yr = (yR.*y1+yN.*~y1);

zR = fZ.^3.0;
zN = (116.*fZ-16)./k;
z1 = zR>e;
zr = (zR.*z1+zN.*~z1);

XYZ(X,:)= XYZn(X).*xr;
XYZ(Y,:)= XYZn(Y).*yr;
XYZ(Z,:)= XYZn(Z).*zr;

end