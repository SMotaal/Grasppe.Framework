%% 5.1 The XYZ2xyY function

function [ output_args ] = xyY2XYZ( input_args )
%XYZ2xyY converts xyY color data to XYZ space


xyY = input_args;

if ((size(xyY)==3)==[0 1]), xyY = xyY'; end;

x = xyY(1,:);
y = xyY(2,:);
Y = xyY(3,:);


XYZ(1,:)  = x .*  Y ./  y;
XYZ(2,:)  = Y;
XYZ(3,:)  = (1-x-y) .*  Y ./  y;

output_args = XYZ;

% XYZ = input_args;
% 
% if ((size(XYZ)==3)==[0 1]), XYZ = XYZ'; end;
%     
% X = XYZ(1,:);
% Y = XYZ(2,:);
% Z = XYZ(3,:);
% sumXYZ = X+Y+Z;
% x = X./sumXYZ;
% y = Y./sumXYZ;
% xyY(1,:) = x;
% xyY(2,:) = y;
% xyY(3,:) = Y;
% output_args = xyY;

end

