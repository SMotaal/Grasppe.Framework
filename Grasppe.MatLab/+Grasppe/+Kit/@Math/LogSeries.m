function [ rexp ] = LogSeries( a, b, c )
  %LOGSERIES Summary of this function goes here
  %   Detailed explanation goes here
  
  a1 = min(a,b);
  b1 = max(a,b);
  
  r = b1 - a1;
  
  rlog = log(r)/(c-2);
  
  r2 = [0:c-2] * rlog;
  
  rexp = exp(r2);
  
  rexp = a1 + [0 exp(r2)];
  
  if a>b, rexp = fliplr(rexp); end
  
end
