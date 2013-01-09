function obj = CreateGraphicsPrototype(primitive, parent, varargin)
  %CREATEGRAPHICSHANDLE GraphicsHandle Factory
  %   Detailed explanation goes here
  
  if isempty(primitive), return; end
  
  options                   = varargin;
  
  try
    obj                     = getappdata(handle(primitive), 'Prototype');
    if isa(obj, 'Grasppe.Graphics.GraphicsHandle') && isvalid(childComponent), return;  end
  end
  
  if exist('parent', 'var')
    parentHandle            = getHandleGraphicsObject(parent);
    options                 = [options {'Parent', parentHandle}];
  end
  
  if ischar(primitive)
    primitive               = Grasppe.Graphics.GraphicsHandle.CreateHandleGraphicsObject(primitive, options{:}, varargin{:});
    obj                     = Grasppe.Graphics.GraphicsHandle.CreateGraphicsPrototype(primitive);
    return;
  end % elseif ishghandle(primitive), set(primitive, options{:}); % Will not set primitive properties
     
  integerPrimitive          = false;
  try integerPrimitive      = isnumeric(primitive) && any(ishghandle(primitive)); end
  
  handlePrimitive           = false;
  try handlePrimitive       = ~isnumeric(primitive) && any(ishghandle(primitive)); end
  
  if ~integerPrimitive && ~handlePrimitive, throwException('InvalidHandle'); end
  
  obj                       = Grasppe.Graphics.GraphicsHandle.empty(numel(primitive), 0);  
  
  for m = 1:numel(primitive)
    
    try
      prototype             = getappdata(handle(primitive(m)), 'Prototype');
      
      if isa(prototype, 'Grasppe.Graphics.GraphicsHandle') && isvalid(prototype);
        obj(end+1)          = prototype.GraphicsHandleDelegator;
      else
        obj(end+1)          = createGraphicsHandle(handle(primitive(m)), varargin{:});
      end
    catch err
      GrasppeKit.Utilities.DisplayError(obj, 1, err);
    end
  end
  
  obj                       = reshape(obj, size(primitive));
end

function obj = createGraphicsHandle(primitive, varargin)
  
  persistent hgPrototypes uiPrototypes;
  
  
  if isempty(hgPrototypes), hgPrototypes  = struct( ...
      'figure', 'Figure', 'root', 'Root', 'axes', 'Axes'); end
  
  if isempty(uiPrototypes), uiPrototypes  = struct( ...
      'uitoolbar', 'UIToolbar', 'uimenu', 'UIMenu', ...
      'uicontextmenu', 'UIContextMenu'); end
  
  obj                       = [];
  
  primitiveClass            = lower(class(primitive));
  prototypeClass            = 'Grasppe.Graphics.GraphicsHandle';
  
  % try prototypeClass        = ['Grasppe.Graphics.'  hgPrototypes.(primitiveClass)]; end
  % try prototypeClass        = ['Grasppe.Graphics.'  uiPrototypes.(primitiveClass)]; end
  
  if isfield(hgPrototypes, primitiveClass)
    prototypeClass          = ['Grasppe.Graphics.'  hgPrototypes.(primitiveClass)];
  elseif isfield(uiPrototypes, primitiveClass)
    prototypeClass          = ['Grasppe.UI.'        uiPrototypes.(primitiveClass)];
  end
  
  obj                       = feval([prototypeClass '.Create'], primitive, varargin{:});
  
  %   switch primitiveClass
  %     case 'figure'
  %       obj                   = Grasppe.Graphics.Figure.Create(primitive, varargin{:});
  %     case 'axes'
  %       obj                   = Grasppe.Graphics.Axes.Create(primitive, varargin{:});
  %     case 'root'
  %       obj                   = Grasppe.Graphics.Root.Create();
  %     case 'uitoolbar'
  %       obj                   = Grasppe.UI.UIToolbar.Create(primitive, varargin{:});
  %     case 'uimenu'
  %       obj                   = Grasppe.UI.UIMenu.Create(primitive, varargin{:});
  %     case 'uicontextmenu'
  %       obj                   = Grasppe.UI.UIContextMenu.Create(primitive, varargin{:});
  %     otherwise
  %       obj                   = Grasppe.Graphics.GraphicsHandle.Create(primitive);
  %   end
  
end

function obj = getHandleGraphicsObject(obj)
  if isa(obj, mfilename('class')), obj = obj.Object; end
end

function obj = getGraphicsPrototype(obj)
  if ishghandle(obj), obj   = getappdata(obj, 'Prototype'); end    % && isa(obj, mfilename('class'))
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