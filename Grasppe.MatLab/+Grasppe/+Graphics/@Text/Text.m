classdef Text < Grasppe.Graphics.GraphicsHandle
  %FIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    
  end
  
  events
    % CloseRequest
    % KeyPress
    % KeyRelease
    % Resize
    %     ButtonDown
    %     ButtonMotion
    %     ButtonUp
    %     KeyPress
    %     KeyRelease
    % ScrollWheel
    % ButtonDown
    % Create
    % Delete
  end
  
  
  methods %(Access=protected)
    
    function obj = Text(primitive, varargin)
      global debugConstructing;
      
      handleDefaults              = {}; % 'NumberTitle', 'off', 'ToolBar', 'none', 'Renderer', 'opengl', 'PaperOrientation', 'landscape'};
      
      if ~exist('primitive', 'var') || ischar(primitive) || (isscalar(primitive) && ~ishghandle(primitive))
        primitive                 = 'text';
      end
      
      obj                         = obj@Grasppe.Graphics.GraphicsHandle(primitive, handleDefaults{:}, varargin{:}); % object, parent,
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 5, obj); end
      
      if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
          
    end
  end
  
  methods
    
%     function onResize(obj, src, evt)
%       obj.handleEvent(src, evt);
%     end
%     
%     function onCloseRequest(obj, src, evt)
%       obj.hideFigure;
%       % delete(obj);
%     end
%     
%     function onButtonDown(obj, src, evt)
%       obj.handleEvent(src, evt);
%       disp(evt);
%     end
%     
%     function onKeyPress(obj, src, evt)
%       obj.handleEvent(src, evt);
%       disp(evt);
%     end
%     
%     function onKeyRelease(obj, src, evt)
%       obj.handleEvent(src, evt);
%       disp(evt);
%     end
%     
%     function delete(obj)
%       try delete(obj.Object); end     % Closes figure
%     end
%     
%     function showFigure(obj)
%       try obj.Visible = true; end
%     end
%     
%     function hideFigure(obj)
%       try obj.Visible = false; end
%     end
    
  end
  
  methods(Static)
    function obj = Create(varargin)
      obj           = feval(mfilename('class'), varargin{:});
    end
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Graphics.GraphicsHandle;
    end
  end
  
end
