function [names values] = setOptions(obj, varargin)
  
  [names values] = Grasppe.Prototypes.Utilities.ParseOptions(varargin{:});
  
  for i=1:numel(names)
    try
      obj.privateSet(names{i}, values{i})
    catch err
      try
        if ~isequal(obj.(names{i}), values{i}), obj.(names{i}) = values{i}; end
      catch err
        if ~strcontains(err.identifier, 'noSetMethod')
          try debugStamp(obj.InstanceID, 5); end
          disp(['Could not set ' names{i} ' for ' class(obj) '. ' err.message]);
          try Grasppe.Kit.Utilities.DisplayError(obj, 1, err); end
        end
      end
    end
  end
  
end
