function [ base ] = extendException(base, identifier, varargin )
  %EXTENDEXCEPTION create extended MException from base
  
  if ~validCheck('identifier','char')
    identifier = base.identifier;
  end
  
  if validCheck('varargin{1}','char')
    message = [base.message ' ' varargin{1}];
  else
    message = base.message;
  end
  
  if numel(varargin)>1
    args = {identifier, message, varargin{2:end}};
  else
    args = {identifier, message};
  end
  
  base = MException(args{:});
  
end

