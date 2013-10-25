classdef Inspector < Grasppe.Graphics.GraphicsHandle
  %ROOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    inspectorGrid
    inspectorModel
    inspectorGrid
    inspectorPane
    inspectorPanel
    inspectorPaneJava
    inspectorPaneHandle
    inspectorComponent
    inspectorPlacement = 'East';
    inspectorWidth     = 250;
    inspectorHeight    = [];
  end
  
  
  methods %(Access=protected)
    function obj = Inspector(parent, varargin)
      global debugConstructing;
      
      Grasppe.Graphics.Inspector.InitializeJIDE;
      
      obj             = obj@Grasppe.Graphics.GraphicsHandle('uipanel', [], parent, varargin{:});
      
      if isequal(debugConstructing, true), debugStamp('Constructing', 5, obj); end
      
      if isequal(mfilename('class'), obj.ClassName), obj.initialize(); end
      
      obj.resizeInspector;
    end
  end
  
  methods
    
    function createHandleObject(obj, varargin)
      
      S = warning('off', 'MATLAB:hg:JavaSetHGProperty');
      
      % Find Parent Figure
      
      % Prepare the properties list:                                            % http://undocumentedmatlab.com/blog/advanced-jide-property-grids/
      obj.inspectorList      = java.util.ArrayList();
      
      prop2 = com.jidesoft.grid.DefaultProperty();
      prop2.setName('mycheckbox');
      prop2.setType(javaclass('logical'));
      prop2.setValue(true);
      prop2.setEditorContext(com.jidesoft.grid.BooleanCheckBoxCellEditor.CONTEXT);
      obj.inspectorList.add(prop2);
      
      % Now integers (note the different way to set property values):
      prop3 = com.jidesoft.grid.DefaultProperty();
      javatype = javaclass('int32');
      set(prop3,'Name','myinteger','Type',javatype,'Value',int32(1));
      obj.inspectorList.add(prop3);
      
      prop4 = com.jidesoft.grid.DefaultProperty();
      set(prop4,'Name','myspinner','Type',javatype,'Value',int32(1));
      set(prop4,'EditorContext',com.jidesoft.grid.SpinnerCellEditor.CONTEXT);
      obj.inspectorList.add(prop4);
      
      % Color Cell
      % javatype = java.lang.Class.forName('com.mathworks.hg.types.HGColor', true, java.lang.Thread.currentThread().getContextClassLoader());
      % editor = com.jidesoft.grid.ColorCellEditor();
      % context = com.jidesoft.grid.EditorContext('colorcombobox');
      %
      % prop5 = com.jidesoft.grid.DefaultProperty();
      % set(prop5,'Name','mycolor','Type',javatype,'Value',[1 0 1]);
      % set(prop5,'EditorContext', editor, context); %com.jidesoft.grid.ColorCellEditor.CONTEXT);
      % obj.inspectorList.add(prop5);
      
      %       % Spinner
      %       javatype = javaclass('int32');
      %       value  = int32(0);
      %       minVal = int32(-2);
      %       maxVal = int32(5);
      %       step   = int32(1);
      %       spinner = javax.swing.SpinnerNumberModel(value, minVal, maxVal, step);
      %       editor = com.jidesoft.grid.SpinnerCellEditor(spinner);
      %       context = com.jidesoft.grid.EditorContext('spinnereditor');
      %       com.jidesoft.grid.CellEditorManager.registerEditor(javatype, editor, context);
      %
      %       prop5 = com.jidesoft.grid.DefaultProperty();
      %       set(prop5, 'Name','myspinner', 'Type',javatype, ...
      %         'Value',int32(1), 'EditorContext',context);
      % % [do something useful here...]
      % com.jidesoft.grid.CellEditorManager.unregisterEditor(javatype, context);
      
      % Combobox
      javatype = javaclass('char', 1);
      options = {'spring', 'summer', 'fall', 'winter'};
      editor = com.jidesoft.grid.ListComboBoxCellEditor(options);
      context = com.jidesoft.grid.EditorContext('comboboxeditor');
      com.jidesoft.grid.CellEditorManager.registerEditor(javatype, editor, context);
      
      prop6 = com.jidesoft.grid.DefaultProperty();
      set(prop6, 'Name','season', 'Type',javatype, ...
        'Value','spring', 'EditorContext',context);
      
      % [do something useful here...]
      
      %com.jidesoft.grid.CellEditorManager.unregisterEditor(javatype, context);
      
      obj.inspectorList.add(prop6);
      
      % Nested
      propdimensions = com.jidesoft.grid.DefaultProperty();
      propdimensions.setName('dimensions');
      propdimensions.setEditable(false);
      
      propwidth = com.jidesoft.grid.DefaultProperty();
      propwidth.setName('width');
      propwidth.setType(javaclass('int32'));
      propwidth.setValue(int32(100));
      propdimensions.addChild(propwidth);
      
      propheight = com.jidesoft.grid.DefaultProperty();
      propheight.setName('height');
      propheight.setType(javaclass('int32'));
      propheight.setValue(int32(100));
      propdimensions.addChild(propheight);
      
      obj.inspectorList.add(propdimensions);
      
      % Prepare a properties table containing the list                          % http://undocumentedmatlab.com/blog/advanced-jide-property-grids/
      obj.inspectorModel     = com.jidesoft.grid.PropertyTableModel(obj.inspectorList);
      
      obj.inspectorModel.expandAll();
      
      obj.inspectorGrid      = com.jidesoft.grid.PropertyTable(obj.inspectorModel);
      obj.inspectorPane      = com.jidesoft.grid.PropertyPane(obj.inspectorGrid);
      
      % Display the properties pane onscreen                                    % http://undocumentedmatlab.com/blog/advanced-jide-property-grids/
      obj.inspectorPanel     = uipanel(obj.ParentComponent.Handle, 'BorderWidth', 0);
      
      [hjPane hcPane]         = javacomponent(obj.inspectorPane, [0 0 200 200], obj.inspectorPanel);
      
      set(hcPane, 'ResizeFcn', @(varargin)obj.resizeInspector(varargin));
      
      obj.inspectorPaneHandle = hcPane;
      obj.inspectorPaneJava   = hjPane;
      
      obj.Object              = obj.inspectorPaneHandle;
      
      try
        obj.resizeInspector;
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
      end
      
      warning(S);
    end
    
    function onResize(obj, src, evt)
      obj.resizeInspector
    end
    
    function resizeInspector(obj, varargin)
      inspectorPlacement      = lower(obj.inspectorPlacement);
      inspectorWidth          = obj.inspectorWidth;
      inspectorHeight         = obj.inspectorHeight;
      
      parentPosition          = getpixelposition(obj.ParentComponent.Object);
      
      newPosition             = [0 0 0 0];    % [left bottom width height]
      
      
      switch(inspectorPlacement)
        case {'east', 'west'}
          if ~isscalar(inspectorWidth), inspectorWidth = 250; end
          
          if isequal('east', inspectorPlacement)
            newLeft           = parentPosition(3)-inspectorWidth;
          else
            newLeft           = 0;
          end
          
          newPosition         = [ ...
            newLeft ...
            0 ...
            inspectorWidth ...
            parentPosition(4)+3 ];
        case {'north', 'south'}
          if ~isscalar(inspectorHeight), inspectorHeight = 250; end
          
          if isequal('north', inspectorPlacement)
            newBottom         = parentPosition(4)-inspectorHeight;
          else
            newBottom         = 0;
          end
          
          newPosition         = [ ...
            0 ...
            newBottom ...
            parentPosition(3) ...
            inspectorHeight];
      end
      
      newPosition             = newPosition;
      set(obj.inspectorPanel, 'Units', 'pixels',   'Position', newPosition);
      set(obj.inspectorPanel, 'Units', 'normalized');
      set(obj.inspectorPaneHandle,                'Position', [ 5 5 newPosition(3)-7 newPosition(4)-10]); % 'Units', 'pixels',
      %       %set(obj.inspectorPane, 'Position', [0 0 newPosition([3 4])]); %'Units', 'pixels',
      %       obj.inspectorComponent.setSize(newPosition(3), newPosition(4));
      %       obj.inspectorComponent.setLocation(0,0);
    end
    
    
    function onDelete(obj, src, evt)
      try delete(obj.inspectorPaneJava); end
    end
    
    %   try delete(obj.Object); end
    % end
    %
    % function delete(obj)
    %   try delete(obj.Object); end
    % end
    
  end
  
  methods(Static, Hidden)
    obj                     = testFigureObject(hObject);
    
    % function component = GetInspector()
    %
    %   try
    %     component = getappdata(0, 'HandleComponent');
    %     if isa(component, mfilename('class')), return; end
    %   end
    %
    %   component = feval(mfilename('class'));
    % end
    
    function component = CreateComponent(object, parent, varargin)
      component = feval(mfilename('class'), varargin{:});
    end
    
    function component = CreateNewComponent(parent, varargin)
      component = feval(mfilename('class'), varargin{:});
    end
    
    function component = CreateComponentFromObject(object, parent, varargin)
      component = feval(mfilename('class'), varargin{:});
    end
    
    function InitializeJIDE
      com.mathworks.mwswing.MJUtilities.initJIDE;
    end
    
    
    
  end
  
  methods (Access=protected)
    function initialize(obj)
      debugStamp(['Initializing@' obj.ClassName], 5, obj);
      obj.initialize@Grasppe.Graphics.GraphicsHandle;
    end
  end
  
end
