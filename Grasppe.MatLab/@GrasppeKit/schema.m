function schema()
  %SCHEMA  simple package definition function.
  
  %   Donn Shull
  %   Copyright 2010 L & D Engineering LLC. All Rights Reserved.
  %   $Revision:  $
  %   $Date:  $
  
  [schemaPath   schemaName  ]   = fileparts(mfilename('fullpath'));
  [packagePath  packageName ]   = fileparts(schemaPath);
  
  packageName                   = regexprep(packageName,  '[+@]', '');
  
  packageSchema                 = schema.package(packageName);
  
  %% Enumerated Types
  if isempty(findtype('start/hold/persists'))
    schema.EnumType('start/hold/persists', {'start', 'hold', 'persists'});
  end

  if isempty(findtype('MATLAB cell'))
    schema.UserType('MATLAB cell', 'MATLAB array',...
      @(x)assert(iscell(x), 'Value must be a valid cell array'));
  end
   
  %% Static Methods
  
  %   createStaticMethod(packageSchema, 'DelayedCall', 'varargin', 'on', ...
  %     'InputTypes',   {'function_handle', 'double', 'start/hold/persists'}, ...
  %     'OutputTypes',  {'handle'});
  %
  %   createStaticMethod(packageSchema, 'ParseOptions', 'varargin', 'on', 'varargout', 'on', ...
  %     'InputTypes',   {}, ...
  %     'OutputTypes',  {'MATLAB cell', 'MATLAB cell', 'bool', 'int'});
  
  % createStaticMethod(packageSchema, 'schema', 
  
  % Universal         MATLAB array, mxArray
  % Numeric Scalars   bool, byte, short, int, long, float, double
  % Numeric Vectors   Nints, NReals
  % Specialized       Numeric	color, point, real point, real point3, rect, real rect
  % Enumeration       on/off
  % Strings           char, string, NStrings, string vector
  % Handle            handle, handle vector, MATLAB callback, GetFunction, SetFunction
  % Java              Any java class recognized by Matlab
end

% function methodSchema = createStaticMethod(ownerSchema, methodName, varargin)
%   
%   [names values]            = ParseOptions(varargin{:});
%   
%   methodSchema              = schema.method(ownerSchema, methodName);
%   
%   methodSignature           = methodSchema.Signature;
%   
%   fields                    = fieldnames(methodSignature);
%   
%   disp(methodSignature);
%   
%   for methodSchema = 1:numel(names)
%     field                   = fields(strncmpi(names{m}, fields));
%     methodSignature(field)  = values{m};
%   end
% end
% 
% 
% function [names values paired pairs] = ParseOptions(varargin)
%   
%   names                 = varargin;
%   extraArgs             = {};
%   
%   %% Parse Lead Structures
%   while (~isempty(names) && isstruct(names{1}))
%     stArgs              = stArgs(names{1});
%     extraArgs           = [extraArgs stArgs]; %#ok<*AGROW>
%     
%     if length(names)>1
%       names = names(2:end);
%     else
%       names = {};
%     end
%     
%   end
%   
%   names = [extraArgs, names];
%   
%   [pairs paired names values ] = pairedArgs(names{:});
%   
%   if nargout==1 && paired && numel(names)>1
%     stArgs              = cell(numel(names)*2,1);
%     
%     stArgs(1:2:end)     = names;
%     stArgs(2:2:end)     = values;
%     
%     names               = struct(stArgs{:});
%   end
%   
% end
% 
% function [ nargs even names values ] = pairedArgs(varargin)
%   %PAIREDARGS number of variable arguments
%   %   Return the number of arguments, if the number of arguments is even,
%   %   the names from every other argument, and the values from every next
%   %   other argument.
%   
%   even    = false;
%   names   = {};
%   values  = {};
%   
%   if length(varargin)==1 && iscell(varargin{1})
%     args  = varargin{1}(:);
%   elseif length(varargin)>1
%     args  = varargin(:);
%   else
%     args  = {};
%   end
%     
%   nargs = numel(args);
%       
%   if nargout > 1
%     even = rem(nargs,2)==0;
%   end
%   
%   if nargout == 3
%     names = args(1:2:end);
%     if (~iscellstr(names))
%       warning('Grasppe:VarArgs:InvalidOutputs', ...
%           ['Invalid number of outputs. Names and values must be parsed together.\n' ...
%           'Consider adding or removing one output to properly parse the names']);      
%     end
%   end
%   
%   if (nargout > 3 && even)
%     names   = cell(1,nargs/2);
%     values  = cell(1,nargs/2);
%     pairs   = 0;
%     voids   = [];
%     
%     for i=1:2:length(args)
%       name  = args{i};
%       value = args(i+1);
%       
%       if (ischar(name) && ~isempty(name))
%         pairs = pairs+1;        
%         names(pairs)  = {name};
%         values(pairs) = value;
%       else
%         voids = [voids i];
%       end
%     end
%     
%     names   = names(1:pairs);
%     values  = values(1:pairs);
%     
%     if (pairs ~= nargs/2)
% %       warning('Grasppe:VarArgs:InvalidNames', ...
% %         ['Invalid names fields [' int2str(voids) ']. These pairs were dropped.']);
%     end
%   end
%   
% end

