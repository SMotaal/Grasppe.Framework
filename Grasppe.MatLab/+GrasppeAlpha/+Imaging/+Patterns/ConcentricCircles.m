function [ img range contrast reference] = ConcentricCircles( cycles, reference, contrast, width )
  %CONCENTRICCIRCLES Summary of this function goes here
  %   Detailed explanation goes here
  
  if nargin<1, cycles     =  10.0; end
  if nargin<2, reference  =    50; end
  if nargin<3, contrast   =   100-abs(2*(50-reference)); end
  if nargin<4, width      =   256; end
  
  contrastRange = GrasppeAlpha.Kit.ConRes.ContrastRange;
  
  contrast  = min(contrast, (50-abs(50-reference))* 2);
  
  % contrast  = contrastRange(find(contrastRange <= contrast, 1, 'first'));  
  
  cycles    = abs(cycles);
  reference = (100 - abs(reference)) / 100.0;
  contrast  = abs(contrast) / 100.0;
  
  % diff      = 1 - (abs(reference) + abs(contrast));
  
  % if diff<0, contrast = contrast + diff; end
  
  img = GrasppeAlpha.Imaging.Patterns.SineCircles(cycles, 50, 100, width); 
  img = im2bw(img);
  img = (reference - contrast/2) + (img.*contrast);
  
  % disp([reference contrast mean(image(:)) min(image(:)) max(image(:))]);
  
  range = [reference - contrast/2, reference + contrast/2];
  
  return;
end

