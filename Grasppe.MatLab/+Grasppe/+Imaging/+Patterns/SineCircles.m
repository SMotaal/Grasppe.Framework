function [ img range] = SineCircles( cycles, reference, contrast, width )
  %CONCENTRICCIRCLES Summary of this function goes here
  %   Detailed explanation goes here
  
  if nargin<1, cycles     =  10.0; end
  if nargin<2, reference  =    50; end
  if nargin<3, contrast   =   100-2*(50-reference); end
  if nargin<4, width      =   256; end
  
  cycles    = abs(cycles);
  reference      = (100 - abs(reference)) / 100.0;
  contrast  = abs(contrast) / 100.0;
  
  
  img   = YkImage.sinConcentric([width width], cycles, 90, 0.5, 0.5);  %Old phase was 135;
  img   = reference - contrast/2 + img.*contrast;  
  
end

