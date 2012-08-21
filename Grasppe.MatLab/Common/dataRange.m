function [ range length dataMin dataMax ] = dataRange( data )
  %DATARANGE Data array numerical range
  
  dataMin = nanmin(data(:));
  dataMax = nanmax(data(:));
  length  = 1+dataMax-dataMin;
  range = dataMax:dataMin;
  
end

