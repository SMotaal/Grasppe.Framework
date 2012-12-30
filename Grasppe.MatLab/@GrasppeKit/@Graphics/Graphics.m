function object = Graphics()
  %OBJECT constructor for the simple.object class
  %
  %   SIMPLEOBJECT = OBJECT(NAME, VALUE) creates an instance of the
  %   simple.object class with the Name property set to NAME and the
  %   Value property set VALUE
  %
  %   SIMPLEOBJECT = OBJECT(NAME) creates an instance of the simple.object
  %   class with the Name property set to NAME. The Value property will be
  %   given the default value of 0.
  %
  %   SIMPLEOBJECT = OBJECT creates an instance of the simple.object class
  %   and executes the simple.object dialog method to open a GUI for editing
  %   the Name and Value properties.
  %
  %   INPUTS:
  %       NAME          : string
  %       VALUE         : double
  %
  %   OUTPUTS:
  %       SIMPLEOBJECT  : simple.object instance
  
  %   Donn Shull
  %   Copyright 2010 L & D Engineering LLC. All Rights Reserved.
  %   $Revision:  $
  %   $Date:  $
  
  [filePath     fileName    ]   = fileparts(mfilename('fullpath'));
  [classPath    className   ]   = fileparts(filePath);
  [packagePath  packageName ]   = fileparts(classPath);
  
  className                     = regexprep(className,    '[+@]', '');
  packageName                   = regexprep(packageName,  '[+@]', '');
  
  
  object                        = eval([packageName '.' className]);
  
  % TODO add java interface
  
%   switch nargin
%     %     case 0
%     %       simpleObject.dialog;
%     case 1
%       object.Root = Grasppe.Graphics.Root.GetRoot;
%     case 2
%   end
  
end
