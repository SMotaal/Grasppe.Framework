function [ value unit ] = unitValue( strs )
  %UNITVALUE parse unit value strings
  %   Extract the value (and unit) from '%f %s' formatted string or cells.
  
  if ischar(strs)
    strs = {strs};
  end
  
  if nargout < 2
    value = [];
  elseif nargout == 2
    value = {};
    unit  = {};
  end
  
  for str = strs
    try
      uv = textscan(char(str),'%f %s');
      if isnumeric(uv{1}) && ischar(char(uv{2}))
        if nargout <  2
          value(end+1)  = uv{1};
        elseif nargout == 2
          value(end+1)  = uv(1);
          unit(end+1)   = uv{2};
        end
      end
    catch err
      disp(err);
    end
  end
  
  
end

