function [ numval numexp ] = sciparts( numset, numrat )
  %SCIPARTS Summary of this function goes here
  %   Detailed explanation goes here
  
  n = numel(numset);
  
  numval = zeros(1,n);
  numexp = zeros(1,n);
  
  maxnum = max(numset(:));
  
  if nargin<2
    numrat = 0;

    while maxnum*(10^numrat) >= 10
      numrat = numrat-1;
    end

    while maxnum*(10^numrat) < 1
      numrat = numrat+1;
    end
  end
  
  numrat = numrat*-1;
  
  numval = numset(:) ./ (10^numrat);
  numexp = ones(size(numval)) .* numrat;
  
  if nargout==1
    numout(1:2:n*2) = numval;
    numout(2:2:n*2) = numexp;
    
    numval = numout;
    
    clear numexp;
  end
  
end

