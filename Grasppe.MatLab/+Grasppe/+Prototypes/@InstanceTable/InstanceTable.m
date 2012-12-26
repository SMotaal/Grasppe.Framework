classdef (Sealed) InstanceTable < handle  % containers.Map
  %INSTANCETABLE Singlton for Grasppe Core Prototypes 2
  %   Detailed explanation goes here
  
  properties (Transient)
    % Table = Grasppe.Prototypes.InstanceTable.GetTable;
    Map     = containers.Map;
  end
  
  properties (SetAccess=private, GetAccess=protected, Transient, Hidden)
    isAlive = true;
  end
  
  methods (Access=private)
    function obj = InstanceTable(varargin)
    end
  end
  
  
  methods (Static)  % Instance Functions
    function [id base idx] = RegisterInstance(id, instance)
      map                 = Grasppe.Prototypes.InstanceTable.GetMap;
      
      if isempty(id), id  = class(instance); end; %Grasppe.Prototypes.InstanceTable.GenerateInstanceID(class(instance)); end
      
      instanceID          = regexprep(id, '(\w+\.)|\.', '');
      
      newIndex            = 1;
      newID               = [instanceID '-1'];
      
      while map.isKey(newID)
        newIndex          = newIndex + 1;
        newID             = [instanceID '-' int2str(newIndex)];
      end
      
      instanceRecord      = Grasppe.Prototypes.InstanceTable.CreateInstanceRecord(newID, instance);
      
      if isstruct(instanceRecord)
        map(newID)        = instanceRecord;
      end
      
      if mod(map.length, 10)==0
        Grasppe.Prototypes.InstanceTable.Clean();
      end
      
      if nargout>0, id    = newID;          end
      if nargout>1, base  = instanceID;     end
      if nargout>2, idx   = newIndex;       end
    end
    
    function instanceRecord = CreateInstanceRecord(id, instance)
      instanceID      = regexprep(id, '(\w+\.)|\.', '');
      instanceRecord = struct(          ...
        'ID',         instanceID,       ...
        'Class',      class(instance),  ...
        'Time',       now(),            ...
        'Object',     instance          ...
        );
    end
    
    function instance = GetInstance(id)
      map             = Grasppe.Prototypes.InstanceTable.GetMap;
      instanceID      = regexprep(id, '(\w+\.)|\.', '');
      instnaceFound   = map.isKey(instanceID);
      instance        = [];
      
      if instnaceFound
        instance      = map(instanceID).Object;
      end
    end
    
    function instanceRecord = GetInstanceRecord(id)
      map             = Grasppe.Prototypes.InstanceTable.GetMap;
      instanceID      = regexprep(id, '(\w+\.)|\.', '');
      instnaceFound   = map.isKey(instanceID);
      
      instanceRecord  = map(instanceID);
    end
    
    function UnregisterInstance(id, instance)
      map             = Grasppe.Prototypes.InstanceTable.GetMap;
      instanceID      = regexprep(id, '(\w+\.)|\.', '');
      instanceFound   = map.isKey(instanceID);
      
      if instanceFound
        try
          obj = map(instanceID).Object;
          if isvalid(obj) && isa(obj, 'Grasppe.Prototypes.Instance') && obj.isAlive
            delete(obj);
          end
        end
        map.remove(instanceID);
      end
    end
    
    function id = GenerateInstanceID(target, id)
      map             = Grasppe.Prototypes.InstanceTable.GetMap;
      index           = 0;
      
      if ~ischar(target)
        target        = class(target);
      end
      
      target          = regexprep(target, '(\w+\.)|\.', '');
      
      if ~exist('id', 'var') || ~ischar(id)
        id            = [target int2str(index)];
      end
      
      id              = regexprep(id, '(\w+\.)|\.', '');
      
      while map.isKey(id)
        index         = index+1;
        id            = [target int2str(index)];
      end
      
    end
  end
  
  methods(Static) % Table Functions
    
    function Clean()
      map           = Grasppe.Prototypes.InstanceTable.GetMap;
      keys          = map.keys;
      
      for m = 1:numel(keys)
        id          = keys{m};
        try
          instance  = map(id);
          if isobject(instance) && ~instance.isvalid
            error('Grasppe:InstanceTable:InvalidObject', ...
              'This object is no longer valid and must be deleted' ...
              );
          end
        catch err
          try delete(map(id)); end
          try map.remove(id); end
        end
      end
    end
    
    function table = GetTable()
      table             = getappdata(0, 'GrasppeInstanceTable');
      
      try
        if ~isa(table, 'Grasppe.Prototypes.InstanceTable') || ~table.isAlive==true
          error(...
            'Grasppe:InstanceTable:InvalidTable', ...
            'This object is not a valid instance table' ...
            );
        end
      catch err
        table           = Grasppe.Prototypes.InstanceTable();
        Grasppe.Prototypes.InstanceTable.CreateMap(table);
      end
      
      setappdata(0, 'GrasppeInstanceTable', table);
      
      assignin('base', 'GrasppeInstanceTable', table);
    end
    
    function map = GetMap()
      table             = Grasppe.Prototypes.InstanceTable.GetTable;
      
      if ~isa(table.Map, 'containers.Map') || ~isvalid(table.Map)
        Grasppe.Prototypes.InstanceTable.CreateMap(table);
      end
      
      map               = table.Map;
    end
    
    function CreateMap(table)
      tableID         = 'InstanceTable';
      tableRecord     = Grasppe.Prototypes.InstanceTable.CreateInstanceRecord(tableID, table);
      table.Map       = containers.Map(tableID, tableRecord);
    end
    
    
    function ClearAll()
      
      map             = Grasppe.Prototypes.InstanceTable.GetMap;
      
      try
        keys          = map.keys;
        
        for m = 1:numel(keys)
          id          = keys{m};
          
          if isequal('InstanceTable', id), continue; end;
          
          try if isvalid(map(id).Object), delete(map(id).Object); end; end
          try map.remove(id); end
        end
      catch err
        debugStamp(err, 1, Grasppe.Prototypes.InstanceTable.GetInstance);
      end
      
      try delete(map); end
      try rmappdata(0, 'GrasppeInstanceTable'); end
      try evalin('base','clear GrasppeInstanceTable'); end
      try delete(Grasppe.Prototypes.InstanceTable.GetTable); end
    end
    
    function Display()
      map               = Grasppe.Prototypes.InstanceTable.GetMap;
      
      records           = {};
      header            = {'ID',  'Time', 'Size', 'Class'};
      
      %try
      keys              = map.keys;
      
      idLength          = 5;
      sizeLength        = 5;
      classLength       = 5;
      
      for m = 1:numel(keys)
        id              = keys{m};
        %records(m,:)  = struct2cell(map(id))';
        %records{m,3}  = toString(records{m,3});
        
        record          = map(id);
        
        recordID        = id;
        try recordID    = record.ID; end
        try idLength    = max(idLength, numel(recordID)); end
        % try if numel(recordID)>20
        %     recordID = ['...' recordID(end-17:end)];
        %   end; end
        
        recordTime      = '';
        try recordTime  = datestr(record.Time,'HH:MM:SS'); end
        
        recordClass     = '';
        try recordClass = record.Class; end
        try classLength = max(classLength, numel(recordClass)); end
        
        recordSize      = '';
        try
          recordSize    = num2str(size(record.Object),'%dx');
          recordSize    = recordSize(1:end-1);
        end
        try sizeLength  = max(sizeLength, numel(recordSize)); end
        
        records(end+1,:)= {recordID,  recordTime, recordSize, recordClass};
        
        % disp(sprintf( ...
        %   '%s\t%s\t%s\t%d\n', ...
        %   recordID,  recordTime, recordClass, recordSize));
        
      end
      %end
      records = records';
      disp(Grasppe.Prototypes.InstanceTable.GetTable);
      disp(sprintf('\n\t%s', 'Records:'));
      
      headerStr         = sprintf( ...
        ['\t\t%-' int2str(idLength) 's  %-8s  %-' int2str(sizeLength) 's  %-s'], ...
        header{:});
      
      recordsStr        = sprintf( ...
        ['\t\t%-' int2str(idLength) 's  %8s  %' int2str(sizeLength) 's  %-s\n'], ...
        records{:});
      
      dividerStr        = sprintf('\t\t%s', repmat('-', 1, idLength+2+8+2+sizeLength+2+classLength));
      
      
      disp(headerStr);
      disp(dividerStr);
      disp(recordsStr);
      
    end
    
  end
  
end

