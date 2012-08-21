function [ names values ] = findProperties( handle, regex )
  %FINDPROPS Summary of this function goes here
  %   Detailed explanation goes here
  
  names = flatcat(regexp(fieldnames(get(handle)), regex, 'match'));
  
  if nargout>1
    values = get(handle, names);
  end
  
end

