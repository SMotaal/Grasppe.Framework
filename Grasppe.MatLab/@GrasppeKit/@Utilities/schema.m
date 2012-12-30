

function schema()
  %SCHEMA  simple.object class definition function.
  
  %   Donn Shull
  %   Copyright 2010 L & D Engineering LLC. All Rights Reserved.
  %   $Revision:  $
  %   $Date:  $
  
  [schemaPath   schemaName  ]   = fileparts(mfilename('fullpath'));
  [classPath    className   ]   = fileparts(schemaPath);
  [packagePath  packageName ]   = fileparts(classPath);
  
  className                     = regexprep(className,    '[+@]', '');
  packageName                   = regexprep(packageName,  '[+@]', '');
  
  % package definition
  packageSchema                 = findpackage(packageName);
  
  % class definition
  classSchema                   = schema.class(packageSchema, className);
  
  classSchema.Global            = 'on';
  
  % define class methods
  
  %   % dialog.m method
  %   m = schema.method(classSchema, 'dialog');
  %   s = m.Signature;
  %   s.varargin    = 'off';
  %   s.InputTypes  = {'handle'};
  %   s.OutputTypes = {};
  %
  % disp.m method
%   m = schema.method(classSchema, 'disp');
%   s = m.Signature;
%   s.varargin                    = 'off';
%   s.InputTypes                  = {'handle'};
%   s.OutputTypes                 = {};
  
  if isempty(findtype('start/hold/persists'))
    schema.EnumType('start/hold/persists', {'start', 'hold', 'persists'});
  end
  
  m = schema.method(classSchema, 'DelayedCall', 'Static');    % Name, Description, Signature, Static, FirstArgDispatch
  s = m.Signature;
  s.varargin                    = 'on';
  s.InputTypes                  = {}; %'function_handle', 'double', 'start/hold/persists'
  s.OutputTypes                 = {'handle'};
  
  % add properties to class
%   p = schema.prop(classSchema, 'Root', 'handle');
%   p.AccessFlags.Init = 'on';
%   %schema.prop(classSchema, 'Value', 'double');
  
  % add events to class
%   schema.event(classSchema, 'simpleEvent');
  
  % TODO add java interface
end
