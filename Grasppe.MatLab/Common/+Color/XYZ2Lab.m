% converts XYZ tristimulus values to CIELab L*a*b*
%
% [Lab] = XYZ2Lab(XYZ,XYZn);
%
% where "XYZ" is a 3 x n array of tristimulus values, "XYZn" is a 3 x 1
% vector representing tristimulus values of the illuminant white point (Xn;
% Yn; Zn) and "Lab" is a 3 x n array of L*a*b* value

function [Lab] = XYZ2Lab(XYZ,XYZn)

%	Use relation expressions and dig function and not loops or find function
%	- Compute XYZ to XYZn ratios using ?ratio = diag(1./XYZn)*XYZ;?
%	- Compute f(x) using logical indexing to implement the conditional
%	- Compute the CIELAB values


X = 1; Y = 2; Z = 3;
L = 1; a = 2; b = 3;

ratio = diag(1./XYZn)*XYZ;

x1 = ratio > 0.008856;
fXYZ = ((ratio.^(1/3)).*x1)+((7.787.*ratio+(16/116)).*~x1);

Lab(L,:) =  116.*(fXYZ(Y,:)-(16/116));
Lab(a,:) =  500.*(fXYZ(X,:)-fXYZ(Y,:));
Lab(b,:) =  200.*(fXYZ(Y,:)-fXYZ(Z,:));

end
