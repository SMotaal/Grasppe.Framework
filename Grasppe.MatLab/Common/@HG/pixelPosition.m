function [ position ] = pixelPosition( handle, outer )
  %PIXELPOSITION Summary of this function goes here
  %   Detailed explanation goes here
  
  try
    units = get(handle, 'Units');
    set(handle, 'Units', 'pixels');
    try
      if ~exist('outer', 'var')
        position = get(handle, 'Position');
      elseif isequal(outer, 1)  || isequal(lower(outer), 'outer')
        position = get(handle, 'OuterPosition');
      end
    end
    set(handle, 'Units', units);
  end
  
end
