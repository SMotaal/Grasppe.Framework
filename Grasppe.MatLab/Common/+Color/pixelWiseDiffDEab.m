function [ deltaE ] = pixelWiseDiffDEab( img1, img2 )
%PIXELWISEDIFFDEAB Summary of this function goes here
%   Detailed explanation goes here


% Write a function to create a pixel-wise color difference map between two
% CIELAB images using the ?E*ab color difference metric. Name your function
% pixelWiseDiffDEab, it should take as input two m-by-n-by 3 matrices of
% CIELAB images and output a m-by-n matrix of ?E*ab values.

% Check for N x M x O
n1 = ndims(img1); n2 = ndims(img2);
% assert(all([n1==n2 n1==3]), 'MATLAB:innerdim', ...
%     ['Both images must have 3 dimensions.\n' ...
%      '  Image 1 is %d dimensions\n' ...
%      '  Image 2 is %d dimensions'], ...
%      n1,n2);

% Check for same size and output an error message if they are not.
s1 = size(img1); s2 = size(img2);
[sX sY sC] = size(img1);

assert(all(s1==s2), 'MATLAB:innerdim', ...
    ['Inner image dimensions must agree.\n' ... '
     '  %d x %d x %d is not equal to %d x %d x %d'], ...
    [s1 s2]);

% Check for N x M x 3
assert(all([s1(n1)==s2(n2) s1(n1)==3]), 'MATLAB:innerdim', ...
    'The last dimension must be the 3 color components.');

nLab1 = permute(img1,[3 1 2]); %reshape(img1,sX*sY,3);
nLab2 = permute(img2,[3 1 2]); %reshape(img2,sX*sY,3);

deltaE = ipermute(deltaEab(nLab1,nLab2), [3 1 2]); %',sX,sY,sX);

end

