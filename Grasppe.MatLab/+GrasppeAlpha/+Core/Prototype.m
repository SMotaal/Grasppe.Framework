classdef Prototype < handle & dynamicprops %& hgsetget
  %GRASPPEPROTOTYPE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden)
    MetaProperties
    ClassName
    ClassPath
    MetaClass
    VerboseDebugging      = false;
  end
  
  methods
    function obj = Prototype()
      GrasppeAlpha.Core.Prototype.RegisterPrototype(obj);
      obj.createMetaPropertyTable;
    end
    
    function delete(obj)
      return;
      %% delete MetaProperties
      %       metaProperties = obj.MetaProperties;
      %
      %       if isstruct(metaProperties) && ~isempty(metaProperties)
      %         prototypes = struct2cell(metaProperties);
      %         delete(prototypes{:});
      %       end
    end
    
    function createMetaPropertyTable(obj)
      definedProperties = obj.getRecursiveProperty('Properties');
      
      if isempty(definedProperties) || ~isa(definedProperties, 'cell'), return; end
      
      definingClasses   = definedProperties(2,:);
      definedProperties = definedProperties(1,:);
      tableSize = size(definedProperties{1});
      
      if isa(definedProperties{1}, 'cell') && tableSize(2)==5
        metaProperties   = struct;
        
        for m = 1:numel(definedProperties)
          definingClass = definingClasses{m};
          tableSize = size(definedProperties{m});
          for n = 1:tableSize(1)
            property    = definedProperties{m}{n,1};
            metaData    = definedProperties{m}(n,2:5);
            
            metaProperties.(property) = GrasppeAlpha.Core.MetaProperty.Declare( ...
              property, obj, definingClass, metaData{:});
          end
        end
        obj.MetaProperties = metaProperties;
      end

    end
    
    function dup = CreateDuplicate(obj)
      dup = [];
    end
    
    
    function className = get.ClassName(obj)
      className = class(obj);
    end
    
    function classPath = get.ClassPath(obj)
      classPath = fullfile(which(obj.ClassName));
    end
    
    function metaClass = get.MetaClass(obj)
      metaClass = metaclass(obj);
    end
    
    function propertyTable = getRecursiveProperty(obj, suffix)
      propertyTable = {};
      try
        tree        = vertcat(class(obj), superclasses(obj));
        properties  = regexp(strcat(tree, suffix), '(?<=\.)\w+$', 'match');
        %properties  = regexp(strcat(tree, suffix),'[A-Z][^\.]*$', 'match');
        properties  = horzcat(properties{:});
        
        idx = cellfun(@(c)isprop(obj, c),properties);
        
        if ~any(idx), return; end
        
        propertyTable   = cellfun(@(c)obj.(c), properties(idx), 'UniformOutput', false)';
        propertyTable   = [propertyTable tree(idx)]';
        
        %propertyTable = [cellfun(@(c)obj.(c), properties(idx), 'UniformOutput', false)' tree{idx};];
        
        %propertyTable{1, :} = cellfun(@(c)obj.(c), properties(idx), 'UniformOutput', false);
        %propertyTable{2, :} = tree{idx};%cellfun(@(c)obj.(c), properties(idx), 'UniformOutput', false);
        %properties  = properties(idx);
        
        % for m = 1:numel(properties)
        %   try
        %     classProperties         = s.(properties{m});
        %     propertyTable{1, end+1} = classProperties;
        %     propertyTable{2, end}   = tree{m};
        %   end
        %
        % end
      end
    end
    
    
  end
  
%   methods (Access=protected)
%     function registerHandle(obj, handles)
%     end
%     
%     function deleteHandles(obj)
%     end
%     
%     function createComponent(obj)
%     end
%   end
  
  methods (Static, Hidden)
    
    function ProcessPrototypeHeader(obj)
      header = struct(...
        'ComponentType', [], 'MetaProperties', [], ...
        'HandleProperties', [], 'HandleEvents', [], ...
        'DataProperties', [] ...
        );
      
      fields = fieldnames(header);
      
      for m = 1:numel(fields)
        field = fields{m};
        name  = upper(field);
        header.(field) = evalin('caller', name);
      end
      
    end
        
    function ClearPrototypes()
      objects = GrasppeAlpha.Core.Prototype.RegisterPrototype;
      
      if ~isempty(objects)
        tic;
        deleted = 0;
        records = numel(objects);
        for m = 1:records
          object = objects{m};
          try
            if ~isempty(object) && isvalid(object)
              deleted = deleted + 1;
              delete(objects{m});
            end
          end
          GrasppeAlpha.Core.Prototype.RegisterPrototype(m);
        end
        try dispf('Deleted %d of %d prototypes in %2.1f seconds', deleted, records, toc); end
      end
      
      % GrasppeAlpha.Core.Prototype.RegisterPrototype('clear');
    end
    
    function objects = RegisterPrototype(obj)
      persistent prototypes;
      
      % mlock;
      % objects = [];
      % return;
      
      if nargout==1
        objects = prototypes;
      end
      
      if nargin==1
        if ischar(obj) && isequal(obj, 'clear')
          clear prototypes; return;
        end
        if isnumeric(obj)
          object = prototypes{obj};
          try 
            if ishandle(object) || (isa(object, 'object') && isvalid(object))
              delete(object);
            end
          end
          prototypes{obj} = {};
          return;
        end
        if ~iscell(prototypes)
          prototypes = {};
        end
        prototypes = [prototypes {obj}];
      end
    end
    
    function checks = checkInheritence(obj, classname)
      checks = false;
      try
        checks = isa(obj, classname);
      catch
        try checks = isa(obj, eval(NS.CLASS)); end
      end
    end
    
  end
  
end

