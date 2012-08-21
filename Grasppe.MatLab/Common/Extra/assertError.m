function [ result ] = assertError( varargin )
  %ASSERTEXPECTION assert and return MException
  %   Detailed explanation goes here
  
  result = [];
  
  assignin('caller', 'evalArgs', varargin);
  
%   try
    evalin('caller', 'clear err;');
    evalin('caller', 'try, assert(evalArgs{:}), catch err, end;')
    result = evalin('caller', 'err');
%   catch err
%     result = err;
%   end
  
  evalin('caller', 'clear evalArgs;');
  
end

