% sRGB2XYZ that takes as input a 3-by-n matrix of sRGB values and returns a
% 3- by-n matrix of XYZ trisimulus values.

function [ XYZ ] = sRGB2XYZ( sRGB )

import MorieAlpha.ColorToolbox.*;

% illuminant: D65
% XYZw_illD65 = [95.0430; 100.0000; 108.8801];
% 
% xyRGBW = [ ... % source: PoCT 222
% 	0.64    0.3 0.15    0.3127; ...
% 	0.33    0.6 0.06    0.329];
% 
% xRGBW = xyRGBW(1,:);
% yRGBW = xyRGBW(2,:);
% 
% Xrgbw = xRGBW./yRGBW;
% Yrgbw = ones(1,4);
% Zrgbw = (1-xRGBW-yRGBW);
% 
% XYZrgbw = [ Xrgbw; Yrgbw; Zrgbw];
% XYZrgb = XYZrgbw(:,1:3);
% XYZw = XYZrgbw(:,4);
% 
% Srgb = pinv(XYZrgb(:,1:3)).*repmat(XYZw,1,3);
% 
% M = XYZrgb.*Srgb;
% 
% 
% M_illD65 = [ ... % source: brucelindbloom.com
%     0.4124564	0.3575761	0.1804375; ...
%     0.2126729	0.7151522   0.0721750; ...
%     0.0193339   0.1191920   0.9503041];

% invM_illD65 = pinv(M_illD65);

% source:
% http://www.classicmagicstudios.com/sw/Matlab/rgb2xyz.m
% if strcmp(class(sRGB), 'uint8')
%    sRGB = double(sRGB)/255;
% end

imcast = (isscalar(sRGB) == 0);
if imcast, sRGB=im2double(sRGB); end;

invM_illD65 = [ ... % source: brucelindbloom.com
    3.2404542	-1.5371385	-0.4985314; ...
    -0.9692660	1.8760108	0.0415560; ...
    0.0556434	-0.2040259	1.0572252];

M_illD65 = pinv(invM_illD65);

XYZ(1:3,:) = [M_illD65(1:3,1:3) * sRGB(1:3,:)];

end
