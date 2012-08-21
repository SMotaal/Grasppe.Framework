function [ result ] = resolve( expression, truevalue, falsevalue )
%RESOLVE Summary of this function goes here
%   Detailed explanation goes here

if (expression)
  result = truevalue;
else
  result = falsevalue;
end

end

