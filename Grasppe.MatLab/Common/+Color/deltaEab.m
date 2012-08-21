% Calculates ?Eab between CIELab L*a*b* values
%
% [deltaE] = delatEab(sampleLAB, referenceLAB);
%
% where both "sampleLAB" & "referenceLAB" are a 3 x n equally sized 
% arrays of CIELab values and "deltaE" is a 1 x n array of delta Eab values

function [deltaE] = deltaEab(sampleLAB, referenceLAB)

L = 1; a = 2; b = 3;

%try
% if (size(sampleLAB) ~= size(referenceLAB)) % Not matching!
    %deltaE = ( (sampleLAB(1,:)-referenceLAB(1,:)).^2.0 ...
    %    + (sampleLAB(2,:)-referenceLAB(2,:)).^2.0 ...
    %    + (sampleLAB(3,:)-referenceLAB(3,:)).^2.0  ).^(1.0/2.0);
    
    deltaE=sum((sampleLAB-referenceLAB).^2.0,1).^0.5;
    %deltaE = Sum((sampleLAB(1,:)-referenceLAB(1,:)).^(2.0)).^(1/2)
    
% ratio = diag(1./XYZn)*XYZ;
% 
% x1 = ratio > 0.008856;
% fXYZ = ((ratio.^(1/3)).*x1)+((7.787.*ratio+(16/116)).*~x1);
% 
% Lab(L,:) =  116.*(fXYZ(Y,:)-(16/116));
% Lab(a,:) =  500.*(fXYZ(X,:)-fXYZ(Y,:));
% Lab(b,:) =  200.*(fXYZ(Y,:)-fXYZ(Z,:));

end