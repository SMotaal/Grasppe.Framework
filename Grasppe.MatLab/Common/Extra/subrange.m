function [ sub ] = subrange( array, range )
  %SUBRANGE easier subref for matrix, cells, and structs
  
  sub = array;
   
  if isnumeric(array) || islogical(array) || ischar(array)
    
    if isnumeric(range)
      sub = array(range);
    elseif ischar(range);
      sub = eval(['array(' range ')']);
    end
    
  elseif iscell(array)
    
    if isnumeric(range)
      sub = array(range);
    elseif ischar(range);
      sub = eval(['array(' range ')']);
    elseif iscell(range)
      if iscellstr(range)
        sub = eval(['array{' range{1} '}']);
      else
        sub = array{range{1}};
      end
    end
    
  elseif isstruct(array)
    
    if ischar(range)
      sub = array.(range);
    elseif isnumeric(range)
      sub = array(range);
    end
    
  else
    
    sub = array;
    switch class(array)
    end
    
  end
end

