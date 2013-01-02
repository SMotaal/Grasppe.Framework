function primitive = CreateHandleGraphicsObject(primitive, varargin)
  %CREATEHANDLEGRAPHICSOBJECT Create MatLab Graphics Handles
  %   Detailed explanation goes here  
  
  if ischar(primitive)
    primitive               = handle(createHandleGraphicsObject(primitive, varargin{:}));
  elseif ishghandle(primitive) % elseif ishghandle(primitive), set(primitive, options{:}); % Will not set primitive properties
    primitive               = handle(primitive);
    set(primitive, varargin{:});
  else
    throwException('InvalidHandle');
  end

end

function primitive = createHandleGraphicsObject(type, varargin)
  switch lower(type)
    case 'root'
      primitive             = handle(0);
      %     case {'figure', 'axes'}
      %       primitive             = feval(lower(type), varargin{:})
    otherwise
      primitive             = feval(lower(type), varargin{:});
  end
end


function throwException(id, varargin)
  exception = [];
  switch lower(id)
    case 'invalidhandle'
      exception             = Grasppe.Prototypes.matlabException(...
        'MATLAB:guihandles:InvalidInput', 'Grasppe:GraphicsHandle:InvalidHandle');
    otherwise
        exception           = MException(id, varargin{:});
  end
  
  if isa(exception, 'MException'), throwAsCaller(exception); end
end
