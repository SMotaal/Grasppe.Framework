function [ deltaE ] = spatialDiffDEab( img1, img2 )
%SPATIALDIFFDEAB Summary of this function goes here
%   filters (blurs) the images to create a more robust metric of visual
%   image difference sensitive to the way we may see color differences we
%   may not see in a complex image.

%% 
% Check for N x M x O
n1 = ndims(img1); n2 = ndims(img2);
% assert(all([n1==n2 n1==3]), 'MATLAB:innerdim', ...
%     ['Both images must have 3 dimensions.\n' ...
%      '  Image 1 is %d dimensions\n' ...
%      '  Image 2 is %d dimensions'], ...
%      n1,n2);

%%
% Check for same size and output an error message if they are not.
s1 = size(img1); s2 = size(img2);
[sX sY sC] = size(img1);

assert(all(s1==s2), 'MATLAB:innerdim', ...
    ['Inner image dimensions must agree.\n' ... '
     '  %d x %d x %d is not equal to %d x %d x %d'], ...
    [s1 s2]);

%%
% Check for N x M x 3
assert(all([s1(n1)==s2(n2) s1(n1)==3]), 'MATLAB:innerdim', ...
    'The last dimension must be the 3 color components.');

Lfilter = fspecial('gaussian',50,2);
afilter = fspecial('gaussian',50,4);
bfilter = fspecial('gaussian',50,8);

% filter(:,:,1) = Lfilter;
% filter(:,:,2) = afilter;
% filter(:,:,3) = bfilter;

img1(:,:,1) = imfilter(img1(:,:,1),Lfilter);
img1(:,:,2) = imfilter(img1(:,:,2),afilter);
img1(:,:,3) = imfilter(img1(:,:,3),bfilter);
img2(:,:,1) = imfilter(img2(:,:,1),Lfilter);
img2(:,:,2) = imfilter(img2(:,:,2),afilter);
img2(:,:,3) = imfilter(img2(:,:,3),bfilter);
%img2 = imfilter(img2,filter);

nLab1 = permute(img1,[3 1 2]); %reshape(img1,sX*sY,3);
nLab2 = permute(img2,[3 1 2]); %reshape(img2,sX*sY,3);

deltaE = ipermute(deltaEab(nLab1,nLab2), [3 1 2]); %',sX,sY,sX);

end