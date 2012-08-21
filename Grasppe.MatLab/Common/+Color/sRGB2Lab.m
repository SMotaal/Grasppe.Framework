% sRGB2XYZ that takes as input a 3-by-n matrix of sRGB values and returns a
% 3- by-n matrix of XYZ trisimulus values.

function [ Lab ] = sRGB2Lab( sRGB )

%import MorieAlpha.*;

XYZn = Color.sRGB2XYZ([1;1;1]);
Lab = Color.XYZ2Lab(Color.sRGB2XYZ(sRGB),XYZn);

end
