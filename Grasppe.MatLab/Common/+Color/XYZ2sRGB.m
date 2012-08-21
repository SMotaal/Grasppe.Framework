function [ sRGB ] = XYZ2sRGB( XYZ )
%XYZ2SRGB Summary of this function goes here
%   sRGB2XYZ that takes as input a 3-by-n matrix of sRGB values and returns
%   a 3- by-n matrix of XYZ trisimulus values.


imcast = (isscalar(XYZ) == 0);
if imcast, XYZ=XYZ./100; end;

invM_illD65 = [ ... % source: brucelindbloom.com
    3.2404542	-1.5371385	-0.4985314; ...
    -0.9692660	1.8760108	0.0415560; ...
    0.0556434	-0.2040259	1.0572252];


sRGB(1:3,:) = max([invM_illD65(1:3,1:3) * XYZ(1:3,:)],0);

end

