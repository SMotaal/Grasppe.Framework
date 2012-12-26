function [ img ] = java2im( javaImage )
  %JAVA2IM Summary of this function goes here
  %   Detailed explanation goes here
  
  
  
  % javaImage = x.View.jAnalyzer.getMatLabManager.getTargetWrapper.getTargetManagerModel.getActiveImagePlus.getImage;
  
  javaData = javaImage.getData();
  
  H=javaData.getHeight;
  W=javaData.getWidth;
  C=javaData.getNumDataElements;
  % repackage as a 3D array (MATLAB image format)
  img = uint8(zeros([H,W,C]));
  
  pixelsData = uint8(javaData.getPixels(0,0,W,H,[]));
  
  for i = 1 : H
    base = (i-1)*W*C+1;
    img(i,1:W,:) = deal(reshape(pixelsData(base:(base+C*W-1)),C,W)');
  end
  
% % display image
% imshow(img);
% pixelsData = uint8(javaImage.getData.getPixels(0,0,W,H,[]));
% for i = 1 : H
% base = (i-1)*W*3+1;
% img(i,1:W,:) = deal(reshape(pixelsData(base:(base+3*W-1)),3,W)');
% end
% % display image
% imshow(img);
% img = uint8(zeros([H,W,3]));
% img = uint8(zeros([H,W,1]));
% pixelsData = uint8(javaImage.getData.getPixels(0,0,W,H,[]));
% for i = 1 : H
% base = (i-1)*W+1;
% img(i,1:W,:) = deal(reshape(pixelsData(base:(base+1*W-1)),1,W)');
% end
% imshow(img);  
  
end

