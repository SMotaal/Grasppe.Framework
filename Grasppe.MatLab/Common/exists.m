function [ result ] = exists( var )
%EXISTS Summary of this function goes here
%   Detailed explanation goes here
result = evalin('caller',['exist(''' var ''', ''var'')']); % exist(var,'var');
end

