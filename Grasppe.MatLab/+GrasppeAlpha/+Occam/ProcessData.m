classdef ProcessData < handle
  %PROCESS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Type
    Name
    ProcessParameters
    Variables = struct;
  end
  
  methods
    
    function obj = ProcessData(type, name, parameters)
      
      if nargin==1 && isstruct(type)
        type = findField(type, 'type');
        name = findField(type, 'name');
        parameters = findField(type, 'parameters');
      end
      % elseif nargin==3
      try obj.Type        = type; end
      try obj.Name        = name; end
      try obj.ProcessParameters  = parameters; end
      % elseif nargin > 0
      % end
    end
    
    function data = getProcessData(obj)
      data = GrasppeAlpha.Occam.ProcessData(obj.Type, obj.Name, obj.ProcessParameters);
    end
    
    function S = getDataStruct(obj)
      S = struct;
      for m = 1:numel(obj)
        item = obj(m);
        try
          type = item.Type;
        end
        
        if isempty(type), type = class(item); end
        
        typeName  = type;
        
        try
          typeName  = char(regexp(typeName, '(?=.)\w*$', 'match'));
        end        
        
        try 
          name = item.Name;
        end
        
        if isempty(name)
          instanceNumber = 1;
          try instanceNumber = GrasppeAlpha.Occam.Singleton.Get.Names.(typeName) + 1; end
          GrasppeAlpha.Occam.Singleton.Get.Names.(typeName) = instanceNumber + 1;
          name = [typeName int2str(instanceNumber)];
        end
        
        try S.(name) = item.ProcessParameters; end
        
      end
    end
    
    
    
    function S = saveobj(obj)
      % Save property values in struct
      % Return struct for save function to write to MAT-file
      S.Type        = obj.Type;
      S.Name        = obj.Name;
      S.ProcessParameters  = obj.ProcessParameters;
      S.Variables   = obj.Variables;
    end
    
    %     function display(obj)
    %       for m = 1:numel(obj)
    %         item = obj(m);
    %
    %         %% Type
    %         type      = []; % class(item);
    %
    %
    %         try
    %           type = item.Type;
    %         end
    %
    %         if isempty(type), type = class(item); end
    %
    %         typeName  = type;
    %
    %         try
    %           typeName  = char(regexp(typeName, '(?=.)\w*$', 'match'));
    %         end
    %
    %         %% Name
    %         name = '';
    %
    %         try
    %           name = item.Name;
    %         end
    %
    %         if isempty(name), name = ['Unnamed' typeName]; end
    %
    %         dispf('%s [%s]:', name, type);
    %
    %         try
    %           disp(structTree(struct('Variables',obj(m).Variables),2,['\t' name]));
    %         catch err
    %           dispf(['\t' name '.Variables'])
    %           disp(obj(m));
    %         end
    %
    %
    %         try
    %           disp(structTree(struct('Parameters',obj(m).Parameters),2,['\t' name]));
    %         catch err
    %           dispf(['\t' name '.Parameters'])
    %           disp(obj(m));
    %         end
    %
    %         disp(' ');
    %       end
    %     end
    
    function obj = reload(obj,S)
      % Method used to assign values from struct to properties
      % Called by loadobj and subclass
      obj.Type        = S.Type;
      obj.Name        = S.Name;
      obj.ProcessParameters  = S.ProcessParameters;
      obj.Variables   = S.Variables;
    end
  end
  
  
  methods (Static)
    function obj = loadobj(S)
      % Constructs a MySuper object
      % loadobj used when a superclass object is saved directly
      % Calls reload to assign property values retrived from struct
      % loadobj must be Static so it can be called without object
      obj = ProcessData;
      obj = reload(obj,S);
    end
  end
  
  
end

