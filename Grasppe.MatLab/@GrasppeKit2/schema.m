function schema()
  %SCHEMA  simple package definition function.
  
  %   Donn Shull
  %   Copyright 2010 L & D Engineering LLC. All Rights Reserved.
  %   $Revision:  $
  %   $Date:  $
  
  [schemaPath   schemaName  ]   = fileparts(mfilename('fullpath'));
  [packagePath  packageName ]   = fileparts(schemaPath);
  
  packageName                   = regexprep(packageName,  '[+@]', '');
  
  schema.package(packageName);
end
