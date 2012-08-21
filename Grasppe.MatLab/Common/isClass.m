function [ result ] = isClass( object, expectedClass )
  %ISVALID Validate class and check size
  %   Detailed explanation goes here
  
%   parser = inputParser;
%   
%   %% Parameters
%   parser.addRequired('object');
%   
%   parser.addRequired('expectedClass', @ischar);
%   
%   parser.parse(object, expectedClass);
%   
%   params = parser.Results;
  
  %% Validation
  result = false;
  try
    result = isa(object, expectedClass);
    
    if ~result
      switch lower(expectedClass)
        case 'object'
          result = isobject(object);
        case 'numeric'
          result = isnumeric(object);
        case 'cellstr'
          result = iscellstr(object);
      end
    end
    
  end
  
end

