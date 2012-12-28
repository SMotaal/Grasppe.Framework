function metaProperty = createDynamicProperty(obj, schemaProperty)
  %CREATEDYNAMICPROPERTY Dynamically Add Handle Properties
  %   Detailed explanation goes here
  
  try
    metaProperty                = [];
    
    propertyName                = schemaProperty.Name;
    propertyDescription         = schemaProperty.Description;
    propertyDataType            = schemaProperty.DataType; ...
      propertyDataClass         = regexprep(propertyDataType,   '(^GObject|^[a-z]+|Type$)',    '');...
      % disp([obj.ObjectType '::' propertyDataClass]);
    % propertyDefaultValue        = schemaProperty.FactoryValue;
    % propertyGetFunction         = schemaProperty.GetFunction;
    % propertySetFunction         = schemaProperty.SetFunction;
    propertyAccessFlags         = schemaProperty.AccessFlags;
    propertyVisible             = schemaProperty.Visible;
    
    
    % meta.Property & meta.DynamicProperty
    %                    Name: 'ObjectType'
    %             Description: ''          DetailedDescription: ''
    %               GetAccess: 'public'              SetAccess: 'immutable'
    %           GetObservable: 0                 SetObservable: 0
    %               GetMethod: []                    SetMethod: []
    %               Dependent: 0
    %                Constant: 0
    %                Abstract: 0
    %               Transient: 0
    %                  Hidden: 0
    %                AbortSet: 0
    %              HasDefault: 0
    %           DefiningClass: [1x1 meta.class]
    
    
    % schema.Property
    %             Name: 'Alphamap'
    %      Description: ''
    %         DataType: 'figureAlphamapType'
    %     FactoryValue: [1x64 double]
    %          Visible: 'on'
    %      GetFunction: []                         SetFunction: []
    %      AccessFlags: [1x1 struct]
    %
    % schemaProperty.AccessFlags
    %        PublicSet: 'on'         PublicGet: 'on'
    %       PrivateSet: 'on'        PrivateGet: 'on'
    %             Init: 'off'          Default: 'on'
    %            Reset: 'on'         Serialize: 'on'
    %             Copy: 'on'          Listener: 'on'
    %         AbortSet: 'on'
    
    
    
    propertyGetAccess           = isequal(lower(propertyAccessFlags.PublicGet), 'on');
    propertySetAccess           = isequal(lower(propertyAccessFlags.PublicSet), 'on');
    
    if ~propertyGetAccess && ~propertySetAccess, return; end
    
    propertyHidden              = ~isequal(lower(propertyVisible), 'on');
    
    metaPropertyName            = [propertyName];
    
    metaProperty                = obj.findprop(propertyName);
    
    if isscalar(metaProperty) || ~propertySetAccess
      metaPropertyName          = ['Handle' propertyName];
    else
      metaPropertyName          = propertyName;
    end
    
    metaProperty                = obj.addprop(metaPropertyName); % vvv['Handle' propertyName]);
    
    metaProperty.Dependent      = true;
    metaProperty.Transient      = true;
    metaProperty.Hidden         = propertyHidden;
    metaProperty.Description    = [ ...
      '(Dynamic property wrapper for ' obj.ObjectType '.' propertyName '=[' propertyDataType ']) '  ...
      propertyDescription];
    
    if propertyGetAccess % Listening to the metaProperty (only)
      metaProperty.GetMethod      = @(obj)getHandleProperty(obj, schemaProperty, propertyDataClass); %@(obj)get(obj.Object, propertyName);
      metaProperty.GetObservable  = true;
      
      % TODO seletively add PreGet@metaProperty listener (working)
      %
      %         obj.addPropertyListener(obj, metaPropertyName, 'PreGet');
      
    end
    
    if propertySetAccess % Listening to the schemaProperty
      metaProperty.SetMethod      = @(obj, value)setHandleProperty(obj, schemaProperty, value, propertyDataClass);%@(obj, value)set(obj.Object, propertyName, value);%schemaProperty.SetFunction;
      metaProperty.SetObservable  = true;
      
      % TODO seletively add PostSet@schemaProperty listener (working)
      %
      %         propertyID                  = [metaPropertyName 'PostSet'];
      %         if ~isfield(obj.HandlePropertyListeners, propertyID)
      %           obj.HandlePropertyListeners.(propertyID) = {};
      %         end
      %
      %         listeners                   = obj.HandlePropertyListeners.(propertyID);
      %         schemaSetListener           = handle.listener(obj.Object, schemaProperty, 'PropertyPostSet', ...
      %           @(s, e)obj.handleHandlePropertyEvent(metaProperty, e)); %propertyName, eventName, @listener.handlePropertyEvent); ...
      %
      %         listeners(end+1,:)          = {obj, schemaSetListener};
      %
      %         obj.HandlePropertyListeners.(propertyID)   = listeners;
      
    end
  catch err
    debugStamp(err, 1, obj);
  end
end

function value = getHandleProperty(obj, schemaProperty, propertyDataClass)
  propertyName                = schemaProperty.Name;
  %propertyDataType            = schemaProperty.DataType;
  handleValue                 = get(obj.Object, propertyName);
  value                       = convertFromHandleValue(propertyDataClass, handleValue);
end

function setHandleProperty(obj, schemaProperty, value, propertyDataClass)
  propertyName                = schemaProperty.Name;
  handleValue                 = convertToHandleValue(propertyDataClass, value);
  
  set(obj.Object, propertyName, handleValue);%schemaProperty.SetFunction;
end

function value = convertToHandleValue(dataType, value)
  
  switch dataType
    case {'Clipping', 'HitTest', 'IntegerHandle', 'Interruptible', 'Visible', ... % HandleGraphics
        'Selected', 'SelectionHighlight', 'BeingDeleted', ... % HandleGraphics
        'Diary', 'Echo', 'ShowHiddenHandles' ...  % Root
        'DockControls', 'DoubleBuffer', 'InvertHardcopy', 'NumberTitle', 'Resize', ... % Figure
        'Box', ... % axes
        'Editing', ... % text
        }
      value     = convertBooleanToHandleValue(value);
  end
  
  return;
end

function value = convertFromHandleValue(dataType, value)
  
  switch dataType
    case {'Clipping', 'HitTest', 'IntegerHandle', 'Interruptible', 'Visible', ... % HandleGraphics
        'Selected', 'SelectionHighlight', 'BeingDeleted', ... % HandleGraphics
        'Diary', 'Echo', 'ShowHiddenHandles' ...  % Root
        'DockControls', 'DoubleBuffer', 'InvertHardcopy', 'NumberTitle', 'Resize', ... % Figure
        'Box', ... % axes
        'Editing', ... % text
        }
      value     = convertBooleanFromHandleValue(value);
  end
  
  return;
end

function value = convertBooleanFromHandleValue(value)
  %value   = isequal(lower(value), 'on');
  %value   = Grasppe.Enumerations.HandleBoolean(value);
end

function value = convertBooleanToHandleValue(value)
  
  switch class(value)
    case 'Grasppe.Enumerations.HandleBoolean'
      value = char(value);
    case 'logical'
      value = char(Grasppe.Enumerations.HandleBoolean(value));
  end
  
end

%% Root Types
% rootBlackAndWhiteType               BlackAndWhite
% rootCallbackObjectType              CallbackObject
% rootCommandWindowSizeType           CommandWindowSize
% rootCurrentFigureType               CurrentFigure
% rootDiaryType                       Diary
% rootDiaryFileType                   DiaryFile
% rootEchoType                        Echo
% rootErrorMessageType                ErrorMessage
% rootFixedWidthFontNameType          FixedWidthFontName
% rootFormatType                      Format
% rootFormatSpacingType               FormatSpacing
% rootHideUndocumentedType            HideUndocumented
% rootLanguageType                    Language
% rootMonitorPositionsType            MonitorPositions
% rootMoreType                        More
% rootPointerLocationType             PointerLocation
% rootPointerWindowType               PointerWindow
% rootRecursionLimitType              RecursionLimit
% rootScreenDepthType                 ScreenDepth
% rootScreenPixelsPerInchType         ScreenPixelsPerInch
% rootScreenSizeType                  ScreenSize
% rootShowHiddenHandlesType           ShowHiddenHandles
% rootTerminalHideGraphCommandType    TerminalHideGraphCommand
% rootTerminalOneWindowType           TerminalOneWindow
% rootTerminalDimensionsType          TerminalDimensions
% rootTerminalProtocolType            TerminalProtocol
% rootTerminalShowGraphCommandType    TerminalShowGraphCommand
% rootUnitsType                       Units
% rootAutomaticFileUpdatesType        AutomaticFileUpdates

% GObjectVisibleType                  Visible (root)
%   figureVisibleType
%   axesVisibleType
% GObjectTagType                      Tag (root)
%   figureTagType
% GObjectChildrenType                 Children (root)
%   figureChildrenType
%   axesChildrenType
% GObjectParentType                   Parent (root)
%   figureParentType
%   axesParentType

% GObjectBeingDeletedType             BeingDeleted
% GObjectPixelBoundsType              PixelBounds
% GObjectClippingType                 Clipping
% GObjectBusyActionType               BusyAction
% GObjectHandleVisibilityType         HandleVisibility
% GObjectHelpTopicKeyType             HelpTopicKey
% GObjectHitTestType                  HitTest
% GObjectInterruptibleType            Interruptible
% GObjectSelectedType                 Selected
% GObjectSelectionHighlightType       SelectionHighlight
% GObjectTypeType                     Type
% GObjectUIContextMenuType            UIContextMenu
% GObjectUserDataType                 UserData
% GObjectApplicationDataType          ApplicationData
% GObjectBehaviorType                 Behavior
% GObjectXLimIncludeType              XLimInclude
% GObjectYLimIncludeType              YLimInclude
% GObjectZLimIncludeType              ZLimInclude
% GObjectCLimIncludeType              CLimInclude
% GObjectALimIncludeType              ALimInclude
% GObjectIncludeRendererType          IncludeRenderer

% figureAlphamapType                  Alphamap
% figureBackingStoreType              BackingStore
% figureColorType                     Color
% figureColormapType                  Colormap
% figureCurrentAxesType               CurrentAxes
% figureCurrentCharacterType          CurrentCharacter
% figureCurrentKeyType                CurrentKey
% figureCurrentModifierType           CurrentModifier
% figureCurrentObjectType             CurrentObject
% figureCurrentPointType              CurrentPoint
% figureDithermapType                 Dithermap
% figureDithermapModeType             DithermapMode
% figureDockControlsType              DockControls
% figureDoubleBufferType              DoubleBuffer
% figureFileNameType                  FileName
% figureFixedColorsType               FixedColors
% figureHelpTopicMapType              HelpTopicMap
% figureIntegerHandleType             IntegerHandle
% figureInvertHardcopyType            InvertHardcopy
% figureMenuBarType                   MenuBar
% figureMinColormapType               MinColormap
% figureNameType                      Name
% figureJavaFrameType                 JavaFrame
% figureNextPlotType                  NextPlot
% figureNumberTitleType               NumberTitle
% figurePaperUnitsType                PaperUnits
% figurePaperOrientationType          PaperOrientation
% figurePaperPositionType             PaperPosition
% figurePaperPositionModeType         PaperPositionMode
% figurePaperSizeType                 PaperSize
% figurePaperTypeType                 PaperType
% figurePointerType                   Pointer
% figurePointerShapeCDataType         PointerShapeCData
% figurePointerShapeHotSpotType       PointerShapeHotSpot
% figurePositionType                  Position
% figureOuterPositionType             OuterPosition
% figureActivePositionPropertyType    ActivePositionProperty
% figurePrintTemplateType             PrintTemplate
% figureExportTemplateType            ExportTemplate
% figureRendererType                  Renderer
% figureRendererModeType              RendererMode
% figureResizeType                    Resize
% figureSelectionTypeType             SelectionType
% figureToolBarType                   ToolBar
% figureUnitsType                     Units
% figureWaitStatusType                WaitStatus
% figureWindowStyleType               WindowStyle
% figureXDisplayType                  XDisplay
% figureXVisualType                   XVisual
% figureXVisualModeType               XVisualMode
% figureUseHG2Type                    UseHG2

% axesActivePositionPropertyType      ActivePositionProperty
% axesALimType                        ALim
% axesALimModeType                    ALimMode
% axesAmbientLightColorType           AmbientLightColor
% axesAspectRatioType                 AspectRatio
% axesBoxType                         Box
% axesCameraPositionType              CameraPosition
% axesCameraPositionModeType          CameraPositionMode
% axesCameraTargetType                CameraTarget
% axesCameraTargetModeType            CameraTargetMode
% axesCameraUpVectorType              CameraUpVector
% axesCameraUpVectorModeType          CameraUpVectorMode
% axesCameraViewAngleType             CameraViewAngle
% axesCameraViewAngleModeType         CameraViewAngleMode
% axesCLimType                        CLim
% axesCLimModeType                    CLimMode
% axesColorType                       Color
% axesContentsVisibleType             ContentsVisible
% axesCurrentPointType                CurrentPoint
% axesColorOrderType                  ColorOrder
% axesDataAspectRatioType             DataAspectRatio
% axesDataAspectRatioModeType         DataAspectRatioMode
% axesDrawModeType                    DrawMode
% axesExpFontAngleType                ExpFontAngle
% axesExpFontNameType                 ExpFontName
% axesExpFontSizeType                 ExpFontSize
% axesExpFontStrikeThroughType        ExpFontStrikeThrough
% axesExpFontUnderlineType            ExpFontUnderline
% axesExpFontUnitsType                ExpFontUnits
% axesExpFontWeightType               ExpFontWeight
% axesFontAngleType                   FontAngle
% axesFontNameType                    FontName
% axesFontSizeType                    FontSize
% axesFontStrikeThroughType           FontStrikeThrough
% axesFontUnderlineType               FontUnderline
% axesFontUnitsType                   FontUnits
% axesFontWeightType                  FontWeight
% axesGridLineStyleType               GridLineStyle
% axesLayerType                       Layer
% axesLineStyleOrderType              LineStyleOrder
% axesLineWidthType                   LineWidth
% axesLooseInsetType                  LooseInset
% axesMinorGridLineStyleType          MinorGridLineStyle
% axesNextPlotType                    NextPlot
% axesOuterPositionType               OuterPosition
% axesPlotBoxAspectRatioType          PlotBoxAspectRatio
% axesPlotBoxAspectRatioModeType      PlotBoxAspectRatioMode
% axesProjectionType                  Projection
% axesPositionType                    Position
% axesRenderLimitsType                RenderLimits
% axesTickLengthType                  TickLength
% axesTickDirType                     TickDir
% axesTickDirModeType                 TickDirMode
% axesTightInsetType                  TightInset
% axesTitleType                       Title
% axesUnitsType                       Units
% axesViewType                        View
% axesWarpToFillType                  WarpToFill
% axesWarpToFillModeType              WarpToFillMode
% axesXColorType                      XColor
% axesXDirType                        XDir
% axesXformType                       Xform
% axesx_ViewTransformType             x_ViewTransform
% axesx_ProjectionTransformType       x_ProjectionTransform
% axesx_NormRenderTransformType       x_NormRenderTransform
% axesx_ViewPortTransformType         x_ViewPortTransform
% axesx_RenderTransformType           x_RenderTransform
% axesx_RenderScaleType               x_RenderScale
% axesx_RenderOffsetType              x_RenderOffset
% axesXGridType                       XGrid
% axesXLabelType                      XLabel
% axesXAxisLocationType               XAxisLocation
% axesXLimType                        XLim
% axesXLimModeType                    XLimMode
% axesXMinorGridType                  XMinorGrid
% axesXMinorTickType                  XMinorTick
% axesXMinorTicksType                 XMinorTicks
% axesXScaleType                      XScale
% axesXTickType                       XTick
% axesXTickLabelType                  XTickLabel
% axesXTickLabelsType                 XTickLabels
% axesXTickLabelModeType              XTickLabelMode
% axesXTickModeType                   XTickMode
% axesYColorType                      YColor
% axesYDirType                        YDir
% axesYGridType                       YGrid
% axesYLabelType                      YLabel
% axesYAxisLocationType               YAxisLocation
% axesYLimType                        YLim
% axesYLimModeType                    YLimMode
% axesYMinorGridType                  YMinorGrid
% axesYMinorTickType                  YMinorTick
% axesYMinorTicksType                 YMinorTicks
% axesYScaleType                      YScale
% axesYTickType                       YTick
% axesYTickLabelType                  YTickLabel
% axesYTickLabelsType                 YTickLabels
% axesYTickLabelModeType              YTickLabelMode
% axesYTickModeType                   YTickMode
% axesZColorType                      ZColor
% axesZDirType                        ZDir
% axesZGridType                       ZGrid
% axesZLabelType                      ZLabel
% axesZLimType                        ZLim
% axesZLimModeType                    ZLimMode
% axesZMinorGridType                  ZMinorGrid
% axesZMinorTickType                  ZMinorTick
% axesZMinorTicksType                 ZMinorTicks
% axesZScaleType                      ZScale
% axesZTickType                       ZTick
% axesZTickLabelType                  ZTickLabel
% axesZTickLabelsType                 ZTickLabels
% axesZTickLabelModeType              ZTickLabelMode
% axesZTickModeType                   ZTickMode

