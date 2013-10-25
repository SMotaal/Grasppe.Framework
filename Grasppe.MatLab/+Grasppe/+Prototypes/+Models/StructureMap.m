classdef Structure < Grasppe.Prototypes.Model %& Grasppe.Prototypes.DynamicDelegator
  %STRUCTURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (GetAccess=private, SetAccess=private)
    map
    st
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
        map                     = varargin{1};
      else
        options                 = varargin;
        map                     = containers.Map;
      end
      
      obj                       = obj@Grasppe.Prototypes.Model(options{:});
      
      obj.createStructure(map);
      
    end
    
    function mapStruct = asStruct(obj)
      thisClass                 = mfilename('class');
      map                       = obj.map;
      
      mapStruct                 = struct();
      
      try
        
        if isa(map, 'containers.Map') && ~isempty(map)
          mapKeys               = map.keys;
          mapValues             = map.values;
          mapLength             = map.length;
          
          if mapLength>0
            
            %subLength           = numel(mapValues{1});
            
            for m = 1:mapLength
                            
              subStructures     = cellfun(@(c)all(isa(c, thisClass)), mapValues{m});
              
              %structures            = cellfun(@(c)all(isa(c, thisClass)), mapValues);
              
              for n = find(subStructures)
                mapValues{m}{n} = mapValues{m}{n}.asStruct();
              end
            end
          end
          
          mapArgs               = cell(numel(mapKeys)*2,1);
          mapArgs(1:2:end)      = mapKeys;
          mapArgs(2:2:end)      = mapValues;
          
          mapStruct             = struct(mapArgs{:});
        end
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        return;
      end
      
    end
    
    function createStructure(obj, map)
      thisClass                 = mfilename('class');
      
      if isstruct(map)
        st                      = map;
        map                     = containers.Map;
        
        fieldNames              = fieldnames(st);
        stLength                = numel(st);
        
        for m = 1:numel(fieldNames)
          fieldName             = fieldNames{m};
          %fieldValue            = cell(1, numel(stLength)); %st.(fieldName);
          
          fieldValue            = {st(:).(fieldName)};
          
          %for m = 1:numel(st)
          
          subStructs            = cellfun(@isstruct, fieldValue);
          
          for n = find(subStructs)
            fieldValue{n}       = Grasppe.Prototypes.Models.Structure(fieldValue{n});
          end
          
          map(fieldName)        = fieldValue;
          
        end
        
      elseif isa(map, thisClass)
        map                     = map.map;
      end
      
      assert(isa(map, 'containers.Map'), 'Grasppe:Structure:InvalidMap');
      
      obj.map                   = map;
    end
    
    %     function set.Map(obj, map)
    %       obj.createStructure(map);
    %     end
    
    function map = get.map(obj)
      if isempty(obj.map) || ~isa(obj.map, 'containers.Map')
        obj.map             = containers.Map;
      end
      
      map                  	= obj.map;
    end
    
  end
  
  
  %% Overload Behaviour
  
  methods
    
    function varargout = subsref(obj, subs)
      
      if nargout>0, varargout = cell(1,nargout); else varargout = {}; end
      
      thisClass               = mfilename('class');
      
      reference               = @(x, s    ) builtin('subsref',  x, s    );
      assign                  = @(x, s, v ) builtin('subsasgn', x, s, v );
      
      try
        subName                 = subs(1).subs;
        subType                 = subs(1).type;
        
        map                     = reference(obj, substruct('.', 'map'));
        
        if isequal(subType,  '.') && isa(map, 'containers.Map')
          value               = [];
          if map.isKey(subName)
            mapField            = map(subName);
            
            if numel(subs)==2 && isequal(subs(2).type , '()')
              if all(cellfun(@isnumeric,subs(2).subs))
                value           = mapField{cell2mat(subs(2).subs)};
              else
                value           = mapField(subs(2).subs);
              end
            elseif numel(subs)==1
              if numel(mapField)==1
                value           = mapField{1};
              else
                value           = mapField;
              end
            else
              if nargout>0
                [varargout{:}]  = subsref(mapField, subs(2:end));
              else
                subsref(mapField, subs(2:end));
              end
              return;
            end
          end
          
          if nargout==1
            varargout{1}        = value;
          elseif nargout>1
            beep;
          else
            disp(value);
          end
          return;
        end
      catch err
        Grasppe.Kit.Utilities.DisplayError(obj, 1, err);
        rethrow(err);
      end
      
      if nargout>0
        [varargout{:}]          = reference(obj, subs);
      else
        disp(reference(obj, subs));
      end
      
    end
    
    function obj = subsasgn(obj, subs, value)
      
      reference             = @(x, s    ) builtin('subsref',  x, s    );
      assign                = @(x, s, v ) builtin('subsasgn', x, s, v );
      
      try
        subName             = subs(1).subs;
        subType             = subs(1).type;
        
        map                 = reference(obj, substruct('.', 'map'));
        
        if isempty(obj.map) || ~isa(map, 'containers.Map')
          map               = containers.Map;
        end
        
        if isequal(subType,  '.')
          
          if ~map.isKey(subName), map(subName) = []; end
          
          mapField          = map(subName);
          
          if numel(subs)==2 && isequal(subs(2).type , '()')
            if all(cellfun(@isnumeric,subs(2).subs))
              mapField{cell2mat(subs(2).subs)} = value;
            else
              mapField(subs(2).subs) = value;
            end
            % map(subName)    = subsasgn(mapField, subs(2:end));
            map(subName)    = mapField;
          elseif  numel(subs)==1
            map(subName)    = {value};
          else
            beep;
          end
          
          obj               = assign(obj, substruct('.', 'map'), map);
          
          return;
        else
          beep;
        end
      end
      
      obj                   = assign(obj, subs, value);
      
    end
    
    function fieldNames = fieldnames(obj)
      fieldNames            = [obj.map.keys; obj.fieldnames@Grasppe.Prototypes.Model();];
    end
    
    function isField = isfield(obj, fieldName)
      isField               = strcmp(obj.map.keys, fieldName);
    end
    
    function disp(obj)
      try
        assert(any(isvalid(obj)), message('MATLAB:class:InvalidHandle'));
        
        map                 = obj.map;
        
        objClass            = class(obj);
        objClassName        = regexprep(objClass, '.*?\.?([^\.]+$)', '$1');
        objMetaClass        = metaclass(obj);
        objPackageName      = objMetaClass.ContainingPackage.Name;
        
        
        if isa(map, 'containers.Map') && ~isempty(map)
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
        end
        
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

