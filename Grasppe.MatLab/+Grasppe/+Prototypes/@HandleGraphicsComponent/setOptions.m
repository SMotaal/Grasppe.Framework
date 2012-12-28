function [names values] = setOptions(obj, varargin)
  
  import(obj.Imports{:});
  
  [names values paired pairs] = Utilities.ParseOptions(varargin{:});
  
  if (paired)
    for i=1:numel(names)
      
      try
        if ~isscalar(obj.findprop(names{i}))
          obj.DefaultOptions.(names{i}) = values{i};
          continue;
        end
        obj.privateSet(names{i}, values{i})
      catch err
        try
          if ~isequal(obj.(names{i}), values{i}), obj.(names{i}) = values{i}; end
        catch err
          if ~strcontains(err.identifier, 'noSetMethod')
            try debugStamp(obj.ID, 5); end
            disp(['Could not set ' names{i} ' for ' class(obj) '. ' err.message]);
          end
        end
      end
    end
    
  end
  
end
