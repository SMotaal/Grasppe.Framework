function [ parser ] = conditionalParameter( parser, condition, varargin )
  %ADDCONDITIONAL Summary of this function goes here
  %   Detailed explanation goes here
  
  if validCheck(condition,'char')
    condition = evalin('caller', [condition ';']);
  end
  
  if ~validCheck(condition,'logical')
    condition = ~isempty(condition);
  end
  
  if (condition==true)
    parser.addOptional(varargin{:});
  else
    parser.addParamValue(varargin{:});
  end
  
end

