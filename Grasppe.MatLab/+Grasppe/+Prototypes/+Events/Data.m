classdef Data < event.EventData & dynamicprops
  %EVENTDATA Grasppe Graphics Superclass
  %   Detailed explanation goes here
  
  properties
    AffectedObject                = [];
    EventType
    %Data
    SourceData
    Handled                       = false;
  end
  
  properties(Access=private)
    event_data
  end
  
  methods
    function data = Data(affectedObject, eventType, eventData) %, varargin)
      
      if ~exist('affectedObject', 'var'),   affectedObject  = []; end
      if ~exist('eventType', 'var'),        eventType       = []; end
      if ~exist('eventData', 'var'),        eventData       = []; end
      
      data                        = data@event.EventData(); %'EventName', 'abc');
      
      data.event_data             = struct;
      
      data.AffectedObject         = affectedObject;
      data.EventType              = eventType;
      
      
      hasType                     = isempty(eventData) && ~isempty(eventType);
      %isFromStruct                = ~isempty(sourceData) && isstruct(sourceData), 'event.EventData'); % && ~isempty(eventType);
      hasData                     = ~isempty(eventData); % && isa(sourceData, 'event.EventData'); % && ~isempty(eventType);
      
      if hasData
        sourceType                = regexprep(class(eventData), '\w+\.','');
        
        if isempty(eventType), data.EventType = sourceType;  end
        
        sourceData                = eventData;
        
        try data.SourceData       = sourceData; end
        
        S = warning('off', 'MATLAB:structOnObject');
        if isobject(sourceData), sourceData   = struct(sourceData); end
        warning(S);
        
        if isstruct(sourceData)
          
          sourceFields            = sort(fieldnames(sourceData));
          
          for m = 1:numel(sourceFields)
            try
              field               = sourceFields{m};
                            
              value               = eventData.(field); %eventProperties{m};
            
              data.addField(field, value);
            catch err
              debugStamp(err, 1, data);
            end
            %             if strmatch(sourceFields{m}, {'Source', 'EventName', 'Data'}), continue; end
            %             try
            %
            %               fieldName             = sourceFields{m};
            %
            %               if strmatch(fieldName, dataProperties, 'exact')
            %                 fieldName           = [sourceType upper(fieldName(1)) fieldName(2:end)];
            %               end
            %
            %               
            %
            %               fieldMeta             = data.addprop(fieldName);
            %
            %               fieldMeta.SetAccess   = 'protected';
            %
            %               data.(fieldName)      = fieldValue;
            %
            %               %property.GetMethod      = @(data)data.ParentData.(propertyName);
            %               % need to prevent setting!
            %             end
            
          end
          
        end
        
        
      end
      
      %       if isNewData
      %
      %         data.Data                 = eventData;
      %
      %         if ~isempty(varargin), data.Data = {data.Data, varargin{:}}; end
      %
      %       elseif isFromData
      %
      %         data.SourceData           = eventData;
      %
      %         sourceType                = regexprep(class(eventData), '\w+\.','');
      %
      %         if isempty(eventType), data.EventType = sourceType;  end
      %
      %         sourceProperties          = properties(eventData);
      %         dataProperties            = properties(data);
      %
      %         % if isstruct(sourceData)
      %         %   data.Data = sourceData
      %         % elseif isprop(sourceData, 'Data')
      %         %   data.Data = {data.Data, struct(sourceData.Data)};
      %         % end
      %
      %         data.Data                 = struct(eventData);
      %
      %         for m = 1:numel(sourceProperties)
      %           if strmatch(sourceProperties{m}, {'Source', 'EventName', 'Data'}), continue; end
      %           try
      %
      %             fieldName             = sourceProperties{m};
      %
      %             if strmatch(fieldName, dataProperties, 'exact')
      %               fieldName           = [sourceType upper(fieldName(1)) fieldName(2:end)];
      %             end
      %
      %             fieldValue            = eventData.(fieldName); %eventProperties{m};
      %
      %             fieldMeta             = data.addprop(fieldName);
      %
      %             fieldMeta.SetAccess   = 'protected';
      %
      %             data.(fieldName)      = fieldValue;
      %
      %             %property.GetMethod      = @(data)data.ParentData.(propertyName);
      %             % need to prevent setting!
      %           end
      %
      %         end
      %       else
      %         % Return generic event
      %       end
      %
      % disp(data);
    end
    
    function data = addField(data, field, value)
      
      if strmatch(field, {'Source', 'EventName', 'Data'}), return; end
      
      dataProperties              = properties(data);
      
      try
        
        if strmatch(field, dataProperties, 'exact')
          field               = [sourceType upper(field(1)) field(2:end)];
        end
        
        fieldMeta                 = data.addprop(field);
        
        fieldMeta.SetAccess       = 'protected';
        
        data.event_data.(field)   = value;
        
        fieldMeta.GetMethod       = @(data) data.event_data.(field);
        
        %data.(field)              = value;
        
        %property.GetMethod      = @(data)data.ParentData.(propertyName);
        % need to prevent setting!
      end
      
      if nargout<1, clear data; end
      
    end
  end
  
  methods(Static)
    function data = CreateData(eventType, sourceData, varargin)
      data    = feval(mfilename('class'), eventType, sourceData, varargin{:});
    end
    
    function component = DataFactory(eventType, sourceData, varargin)
      %COMPONENTFACTORY Summary of this function goes here
      %   Detailed explanation goes here
      
    %   component                     = [];
    %   
    %   Factory.root                  = 'Grasppe.Graphics.Root';
    %   Factory.figure                = 'Grasppe.Graphics.Figure';
    %   Factory.axes                  = 'Grasppe.Graphics.Axes';
    %   
    %   if ~exist('parent', 'var'),     parent   = []; end
    %   
    %   componentOptions              = varargin;
    %   componentOptions              = [{parent}, componentOptions];
    %   
    %   if exist('object', 'var') && any(ishandle(object))
    %     objectType                  = get(object, 'Type');
    %     factoryMethod               = 'CreateComponentFromObject';
    %     componentOptions            = [{object}, componentOptions];
    %   else
    %     object                      = [];
    %     factoryMethod               = 'CreateComponent';
    %   end
    %   
    %   if ~exist('objectType', 'var'), objectType   = []; end
    %   componentType                  = lower(objectType);
    %   
    %   if isfield(Factory, componentType)
    %     componentClass              = Factory.(componentType);
    %   else
    %     componentClass              = eval(NS.CLASS);
    %     componentOptions            = [{objectType}, componentOptions];
    %   end
    %   
    %   component                     = feval([componentClass '.' factoryMethod], componentOptions{:});
    %   
    %   %         component                   = feval([ '.CreateComponent'], object, parent, varargin{:});
    %   %       else
    %   %         component                   = feval([eval(NS.CLASS) '.CreateComponent'], objectType, object, parent, varargin{:});
    %   %       end
      
      
    end
  end
  
end

