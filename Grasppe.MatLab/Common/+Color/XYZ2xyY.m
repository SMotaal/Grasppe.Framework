%% 5.1 The XYZ2xyY function

function [ output_args ] = XYZ2xyY( input_args )
%XYZ2xyY converts XYZ color data to xyY space

XYZ = input_args;

if ((size(XYZ)==3)==[0 1]), XYZ = XYZ'; end;
    
X = XYZ(1,:);
Y = XYZ(2,:);
Z = XYZ(3,:);
sumXYZ = X+Y+Z;
x = X./sumXYZ;
y = Y./sumXYZ;
xyY(1,:) = x;
xyY(2,:) = y;
xyY(3,:) = Y;
output_args = xyY;

end

