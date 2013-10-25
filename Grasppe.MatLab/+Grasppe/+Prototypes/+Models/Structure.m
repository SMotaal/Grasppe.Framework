classdef Structure < Grasppe.Prototypes.Model %& Grasppe.Prototypes.DynamicDelegator
  %STRUCTURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (GetAccess=private, SetAccess=private)
    % map
    struct
  end
  
  %   properties (Dependent)
  %     Map
  %   end
  
  methods
    
    function obj = Structure(varargin)
      
      thisClass                 = mfilename('class');
      
      oneArgument               = numel(varargin)==1;
      oddArguments              = rem(numel(varargin), 2)==1;
      structArgument            = (oneArgument || oddArguments) && (isstruct(varargin{1}) || isa(varargin{1}, thisClass));
      pairedArguments           = ~oneArgument && ~oddArguments || structArgument;
      
      if (structArgument)
        options                 = varargin(2:end);
        st                      = varargin{1};
      else
        options                 = varargin;
        st                      = struct();
      end
      
      obj                       = obj@Grasppe.Prototypes.Model(options{:});
      
      obj.createStructure(st);
      
    end
    
    function st = asStruct(obj)
      thisClass                 = mfilename('class');
      st                        = obj.struct;
      
      if isstruct(st)
        
        fieldNames              = fieldnames(st);
        
        for m = 1:numel(fieldNames)
          fieldName             = fieldNames{m};          
          fieldValue            = {st(:).(fieldName)};
                    
          subStructs            = cellfun(@(c)isa(c, thisClass), fieldValue);
          
          for n = find(subStructs)
            fieldValue{n}       = fieldValue{n}.asStruct();
          end
          
          if numel(fieldValue)==1
            st.(fieldName)      = fieldValue{1};
          else
            [st(:).(fieldName)] = fieldValue{:};
          end          
                    
        end
      end    
      
    end
    
    function createStructure(obj, st)
      thisClass                 = mfilename('class');
      
      if isstruct(st)
        
        fieldNames              = fieldnames(st);
        
        for m = 1:numel(fieldNames)
          fieldName             = fieldNames{m};
          fieldValue            = {st(:).(fieldName)};
                    
          subStructs            = cellfun(@isstruct, fieldValue);
          
          for n = find(subStructs)
            fieldValue{n}       = Grasppe.Prototypes.Models.Structure(fieldValue{n});
          end
          
          if numel(fieldValue)==1
            st.(fieldName)      = fieldValue{1};
          else
            %st(1:end).(fieldName)   = fieldValue{1:end};
            [st(:).(fieldName)] = fieldValue{:};
          end
            
          
        end
        
      elseif isa(st, thisClass)
        st                      = st.struct;
      end
      
      assert(isstruct(st), 'Grasppe:Structure:InvalidStruct');
      
      obj.struct                = st;
    end
        
%     function map = get.map(obj)
%       if isempty(obj.map) || ~isa(obj.map, 'containers.Map')
%         obj.map             = containers.Map;
%       end
%       
%       map                  	= obj.map;
%     end
    
  end
  
  
  %% Overload Behaviour
  
  methods
    
    function varargout = subsref(obj, subs)
      
      if nargout>0, varargout   = cell(1,nargout); else varargout = {}; end
      
      %       thisClass                 = mfilename('class');
      
      reference                 = @(x, s    ) builtin('subsref',  x, s    );
      assign                    = @(x, s, v ) builtin('subsasgn', x, s, v );
      
      try
        subRef                  = subs(1).subs;
        subType                 = subs(1).type;
        
        st                      = reference(obj, substruct('.', 'struct'));
        
        fieldType               = isequal(subType, '.');
        selfMethod              = fieldType && ismethod(obj, subRef);
        selfField               = fieldType && isprop(obj, subRef);
        
        if ~selfMethod && ~selfField
          ref                   = st;
          for s = 1:numel(subs) - 1
            sub                 = subs(s);
            ref                 = subsref(ref, sub);
          end
          
          if nargout==0
            disp(subsref(ref, subs(end)));
          else
            [varargout{:}]  = subsref(ref, subs(end));
          end
          
          return;
        end
                
        %         switch subType
        %           case {'.', '()'}
        %
        %               if nargout==0
        %                 disp(subsref(st, subs))
        %               else
        %                 [varargout{:}]  = subsref(st, subs);
        %               end
        %               return;
        %             end
        %         end
        
      catch err
        % Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        rethrow(err);
      end
      
      if nargout>0
        [varargout{:}]          = reference(obj, subs);
      else
        disp(reference(obj, subs));
      end
      
    end
    
    function isEmpty = isempty(obj)
      isEmpty                   = isempty(obj.struct) || (isstruct(obj.struct) && isempty(fieldnames(obj.struct)));
    end
    
    function obj = subsasgn(obj, subs, value)
            
      %       thisClass                 = mfilename('class');
      
      reference                 = @(x, s    ) builtin('subsref',  x, s    );
      assign                    = @(x, s, v ) builtin('subsasgn', x, s, v );
      
      try
%         subName                 = subs(1).subs;
%         subType                 = subs(1).type;
        
        st                      = reference(obj, substruct('.', 'struct'));
        
        if ~isequal(subs(1).type, '()')
          subIndex              = 1;
        else
          subIndex              = cell2mat(subs(1).subs);
          
          if numel(subs) > 1
            subs                = subs(2:end);
          end
        end
        
        if numel(subs)==1
          st(subIndex).(subs(1).subs) = value;
        elseif numel(subs)>1
          st(subIndex).(subs(1).subs) = ...
            subsasgn(st(subIndex).(subs(1).subs), subs(2:end), value);
        end
        
        obj                     = assign(obj, substruct('.', 'struct'), st);
        return;
      catch err
        % Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        rethrow(err);
      end
      
      obj                       = assign(obj, subs, value);

    end
      
%       reference             = @(x, s    ) builtin('subsref',  x, s    );
%       assign                = @(x, s, v ) builtin('subsasgn', x, s, v );
%       
%       try
%         subName             = subs(1).subs;
%         subType             = subs(1).type;
%         
%         map                 = reference(obj, substruct('.', 'map'));
%         
%         if isempty(obj.map) || ~isa(map, 'containers.Map')
%           map               = containers.Map;
%         end
%         
%         if isequal(subType,  '.')
%           
%           if ~map.isKey(subName), map(subName) = []; end
%           
%           mapField          = map(subName);
%           
%           if numel(subs)==2 && isequal(subs(2).type , '()')
%             if all(cellfun(@isnumeric,subs(2).subs))
%               mapField{cell2mat(subs(2).subs)} = value;
%             else
%               mapField(subs(2).subs) = value;
%             end
%             % map(subName)    = subsasgn(mapField, subs(2:end));
%             map(subName)    = mapField;
%           elseif  numel(subs)==1
%             map(subName)    = {value};
%           else
%             beep;
%           end
%           
%           obj               = assign(obj, substruct('.', 'map'), map);
%           
%           return;
%         else
%           beep;
%         end
%       end
%       
%       obj                   = assign(obj, subs, value);
%       
%     end
    
    function fieldNames = fieldnames(obj)
      fieldNames            = {}; % obj.fieldnames@Grasppe.Prototypes.Model();
      
      if isstruct(obj.struct), fieldNames = [fieldnames(obj.struct) fieldNames]; end
    end
    
    function isField = isfield(obj, fieldName)
      isField               = isstruct(obj.struct) && isfield(obj.struct, fieldName);

    end
    
    function obj = rmfield(obj, fields)
      try obj.struct = rmfield(obj.struct, fields); end
    end
    
    function disp(obj)
      try
        assert(any(isvalid(obj)), message('MATLAB:class:InvalidHandle'));
        
        %st                  = obj.asStruct();
        
        objClass            = class(obj);
        objClassName        = regexprep(objClass, '.*?\.?([^\.]+$)', '$1');
        objMetaClass        = metaclass(obj);
        objPackageName      = objMetaClass.ContainingPackage.Name;
        
        
        %if isstruct(obj.struct)
          %           mapKeys           = map.keys;
          %           mapValues         = map.values;
          %
          %           mapArgs           = cell(numel(mapKeys)*2,1);
          %           mapArgs(1:2:end)  = mapKeys;
          %           mapArgs(2:2:end)  = mapValues;
          
          %mapStruct         = obj.asStruct(); % struct(mapArgs{:});
          
          dispf('  <a href="matlab:help %s">%s</a>  Structure\n  Package: %s\n', objClass, objClass, objPackageName);
          dispf('  Fields:');
          structDisplay(obj.asStruct());
          
          disp(' ');
          dispf([ ...
            '  <a href="matlab:methods %s">%s Methods</a>,' ...
            ' <a href="matlab:events %s">%s Events</a>,' ... '
            ' <a href="matlab:superclasses %s">%s Superclasses</a>'], ...
            objClass, objClassName, objClass, objClassName, objClass, objClassName);
          
          return;
        %end
        
        % return;
      end
      builtin('disp', obj);
    end
  end
  
  methods (Static)
    
    %     function map = CreateMap(st)
    %       if isstruct(st)
    %       elseif isobject(st)
    %       end
    %     end
    %
    %     function obj = CreateStructure(st)
    %       if isstruct(st)
    %         % obj   =
    %       elseif isa(st, Grasppe.Prototypes.Models.Structure)
    %         obj.Delegate = ConverStruct
    %       end
    %     end
  end
  
end

