function dispdbg( varargin )
  %DISPDBG Summary of this function goes here
  %   Detailed explanation goes here
  
  debugging = false;
  
  try
    debugging = evalin('caller', 'debugging'); 
  catch
    assignin('caller', 'debugging', false);
  end
  
  if ~isequal(debugging, true), return; end
  
  disp(varargin{:});
  
end

