function [ checks ] = strcontains( varargin )
  %STRFOUND Summary of this function goes here
  %   Detailed explanation goes here
  
  checks = ~isempty(strfind(varargin{:}));
end

