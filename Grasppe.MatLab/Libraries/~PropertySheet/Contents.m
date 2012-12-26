% User control collection
% Copyright 2008-2009 Levente Hunyadi
%
% Property sheet user control
%   PropertySheet            - A property browser for custom objects.
%   PropertySheetFactory     - Creates property browser instances.
%   MatLabPropertySheet      - MatLab implementation of a property browser for custom objects.
%   SwingPropertySheet       - Java Swing implementation for a property browser for custom objects.
%
% Other user controls
%   ObjectList               - Manages a collection of objects which are constructed from prototypes.
%
% Editor dialogs
%   EditorDialog             - A modal dialog box which encapsulates a single item editor control.
%   MatrixEditorDialog       - An editor instance for changing matrix element values.
%   MatrixEditor             - Presents a matrix in a visually convenient and editable format.
%   PropertyEditor           - A property editor for custom objects.
%
% Examples
%   SampleUI                 - Sample user interface to demonstrate user controls.
%   SampleObject             - Sample object to test data persistence functions and user controls.
%   SampleNestedObject       - Sample nested object to test expandable properties.
%   example_propertysheet    - Sample property sheet.
%   example_jpropertysheet   - Sample property sheet illustrating low-level function usage.
%
% Utility classes
%   Docking                  - Resizes a control while maintaining the docking of child controls.
%   PropertyChangedEventData - Occurs when the value of a PropertySheet item property has changed.
%   PropertySheetDialog      - An editor instance for editing objects.
%   PropertySheetField       - Represents a constrained field of a PropertySheet object.
%   UIControl                - Root class for composite user controls.
%
% Utility functions
%   assertversion            - Check if version is at least the minimum version specified.
%   callererror              - Produce error in the context of the caller function.
%   constructor              - Sets public properties of a MatLab object using a name-value list.
%   convertcomplexdlg        - Prompts for converting a real data type to complex.
%   converterrordlg          - Prompts for converting a value to data type char as a fallback.
%   convertfloatdlg          - Prompts for converting a data type to floating-point double precision.
%   gui_align_vertical       - Align child controls of a parent control vertically.
%   gui_control              - Returns the representative handle graphics control.
%   gui_convertunits         - Converts a rectangle specified in one unit base to another unit base.
%   gui_resize_pad           - Resizes a control maintaining the padding around the control.
%   helpdialog               - Displays a dialog to give help information on an object.
%   helptext                 - Returns help text associated with an object.
%   is_public_property       - True if the property designates a public, accessible property.
%   isMatrix                 - True if the specified value represents a matrix.
%   javaclass                - Return java.lang.Class instance for MatLab type.
%   javamatrix               - Java instance suitable to pass for (scalar or matrix) editing.
%   javastartup              - Check Java version and static classpath.
%   matlabArray              - Return MatLab equivalent for Java matrix or array.
%   newinstance              - New instance of specified class.
%   position2size            - Extracts size information from handle graphics position vector.
%   prettyexception          - Pretty-print exception and stack trace.
%   prototypeclasses         - A cell array of classes that can be instantiated with empty constructor.
%   public_properties        - Public properties of a MatLab object.
%   selectobjecttype         - Prompts to choose the object class.
%   StringEditorDialog       - An editor instance of editing strings.
%   strjoin                  - Concatenates a cell array of strings.
