function t = tocdbg( varargin )
  %TOCDBG Summary of this function goes here
  %   Detailed explanation goes here
  
  debugging = false;
  
  try
    debugging = evalin('caller', 'debugging'); 
  catch
    assignin('caller', 'debugging', false);
  end
  
  if ~isequal(debugging, true), return; end
  
  if nargout == 1
    t = toc(varargin{:});
  else
    toc(varargin{:});
  end
  
end

