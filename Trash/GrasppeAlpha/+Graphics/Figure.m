classdef Figure < Grasppe.Graphics.GraphicsHandleComponent ...
    & Grasppe.Core.KeyEventHandler & Grasppe.Core.MouseEventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  
  properties (Transient, Hidden)
    FigureProperties = {
      'Color',        'Axes Background',  'Plot Style',     'color',    '';   ...
      ...
      'WindowTitle',  'Plot Title',       'Plot Labels',    'string',   '';   ...
      };
    
    FigureHandleProperties = { ...
      {'WindowTitle', 'Name'}, 'Renderer', {'Toolbar', 'ToolBar'}, {'Menubar', 'MenuBar'}, 'WindowStyle', ...
      'Color', 'Units'};
    
    %FigureHandleFunctions  = {{'CloseFunction', 'CloseRequestFcn'}};
    
    FigureHandleFunctions = { ...
      {'CloseFunction', 'CloseRequestFcn'}, {'ResizeFunction', 'ResizeFcn'}, ...
      {'KeyPressFunction', 'WindowKeyPressFcn'}, {'KeyReleaseFunction', 'WindowKeyReleaseFcn'}, ...
      {'MouseDownFunction', 'WindowButtonDownFcn'}, {'MouseUpFunction', 'WindowButtonUpFcn'}, ...
      {'MouseMotionFunction', 'WindowButtonMotionFcn'}, {'MouseWheelFunction', 'WindowScrollWheelFcn'}};
    
    ComponentType = 'figure';
    
    
    
  end
  
  events
    Close
    Resize
  end
  
  properties (Dependent)
    JFrame
    JContentPane
    HGClient
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Color
    WindowTitle
    Toolbar, Menubar
    WindowStyle
    Renderer
    Units
  end
  
  methods
    function obj = Figure(varargin)
      obj = obj@Grasppe.Graphics.GraphicsHandleComponent(varargin{:});
    end
    
  end
  
  methods (Hidden=true)
    function OnClose(obj, source, event)
      % disp(event);
      %obj.handleSet('WindowStyle
      %       style = obj.WindowStyle;
      event.Consumed = true;
      obj.hide; %IsVisible = 'off';
      %       if strcmp(style, 'docked') obj.WindowStyle = 'normal'; end
      %       obj.handleSet('Visible', 'off');
      %       if strcmp(style, 'docked') obj.WindowStyle = 'docked'; end
      %       obj.handleSet('Visible', 'off');
    end
    
    function OnResize(obj, source, event)
      % disp('Resized Figure');
    end
    
    function show(obj)
      figure(obj.Handle);
      obj.IsVisible = 'on';
      obj.handleSet('Visible', 'on');
    end
    
    function hide(obj)
      figure(obj.Handle);
      obj.IsVisible = 'off';
      obj.handleSet('Visible', 'off');
    end
    
    function present(obj)
      try
        scrDevices  = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment.getScreenDevices;
        srcIdx = min(2, numel(scrDevices));
        scrBounds   = scrDevices(srcIdx).getDefaultConfiguration.getBounds;
        
        %obj.HGClient.showClientHidden;
        
        set(obj.Handle, 'Visible', 'on');
        
        drawnow expose update;
        
        obj.HGClient.getWindow.setBounds(scrBounds);
        %obj.HGClient.getWindow.setMaximized(true);
        %         set(obj.Handle, 'Visible', 'on');
        drawnow expose update;
        
        %obj.HGClient.getWindow.show;
        obj.JFrame.setMaximized(true);
        
        drawnow expose update;
      catch err
        debugStamp(err, 1);
      end
    end
    
  end
  
  methods
    function jFrame = get.JFrame(obj)
      jFrame    = get(handle(obj.Handle), 'JavaFrame');
    end
    
    function hgClient = get.HGClient(obj)
      hgClient  = obj.JFrame.fHG1Client;
    end
    
    function jPane = get.JContentPane(obj)
      jPane     = obj.HGClient.getContentPane;
    end
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      
      obj.createComponent@Grasppe.Graphics.GraphicsHandleComponent();
      
    end
    
    
    function createHandleObject(obj)
      
      frameOptions    = {'RendererMode', 'auto', 'Position', get(0,'Screensize'), 'Visible', 'off', 'NumberTitle', 'off'};
      
      obj.Handle      = figure(frameOptions{:}); %'Visible', 'off', );
      
      addlistener(obj.Handle, 'RendererMode', 'PreSet',   @obj.callbackEvent); %Grasppe.Core.EventData.
      addlistener(obj.Handle, 'RendererMode', 'PostSet',  @obj.callbackEvent); %Grasppe.Core.EventData.
      
    end
    
    function decorateComponent(obj)
    end
    
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      WindowTitle   = 'Printing Uniformity Plot';
      %       BaseTitle     = 'Printing Uniformity';
      Color         = 'white';
      %Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'normal';
      Renderer      = 'zbuffer';
      
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

