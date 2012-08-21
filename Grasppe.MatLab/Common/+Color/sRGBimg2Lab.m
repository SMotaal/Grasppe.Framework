function [ Lab ] = sRGBimg2Lab( sRGBimg )
%SRGBIMG2LAB Summary of this function goes here
%   Detailed explanation goes here

% To facilitate quickly loading a sRGB image and converting it to CIELAB,
% write a func- tion called sRGBimg2Lab that takes as input a m-by-n-by-3
% sRGB image and outputs a m-by-n-by-3 CIELAB image.

% First reshape and transpose the image to a list of pixels (3- by-m*n)

[sX, sY, sC] = size(sRGBimg);

nRGB = reshape(sRGBimg,sX*sY,sC)';

% Run the pixel data through sRGB2XYZ

nXYZ = sRGB2XYZ(nRGB);

% Run the data through XYZ2Lab with a white point to convert to CIELAB
% Use the sRGB white point produced by calling sRGB2XYZ with [1;1;1]

XYZn = sRGB2XYZ([1;1;1]);
nLAB = XYZ2Lab(nXYZ,XYZn);

% Finally transpose and reshape the pixel data back to a m-by-n-by-3.

Lab = reshape(nLAB',sX,sY,sC);

end

