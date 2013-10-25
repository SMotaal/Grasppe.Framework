classdef Source  < GrasppeAlpha.Core.Component
  %SOURCE Abstract Data Reader
  %   Detailed explanation goes here
  
  properties (GetAccess=public, SetAccess=protected)
    Reader
  end
  
  properties (Dependent)
    IsReady
  end
    
  properties (Access=protected)
    reader
    % readerListeners
  end
  
  
  methods
    
    function obj = Source(varargin)
      obj = obj@GrasppeAlpha.Core.Component(varargin{:});
    end
        
    
    function readerValid = get.IsReady(obj)
      readerValid               = GrasppeAlpha.Data.Source.ValidateReader(obj.reader);
    end
    
%     function set.Reader(obj, reader)
%       
%     end
    
    function reader = get.Reader(obj)
      reader                    = obj.reader;
      if ~isscalar(reader) || ~isa(reader, 'GrasppeAlpha.Data.Reader') || ~isvalid(reader)
        try delete(reader); end
        obj.GetNewReader(obj);
        reader                  = obj.reader;
      end

    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.reader                = [];
      % obj.readerListeners       = event.listener.empty;
      obj.createComponent@GrasppeAlpha.Core.Component;
    end
    
    function tf = attachReader(obj, reader)
      
      tf  = false;
      
      if GrasppeAlpha.Data.Source.ValidateReader(obj.reader), return; end
      
      if ~GrasppeAlpha.Data.Source.ValidateReader(reader), return; end;
      
      %disp(isequal(reader, obj.reader));
      
      try if ~isequal(reader, obj.reader)
          obj.detachReader; end; end
      % tf  = obj.attachReaderListeners(reader);
      
      obj.reader                = reader;
      
    end
    
    function detachReader(obj)
      
      reader                    = obj.reader;
      
      try delete(obj.reader); end
            
      obj.reader                = [];      
      
      %if ~isempty(obj.readerListeners)
      % try delete(obj.readerListeners); end
      %end
      
    end
    
    %     function fireReaderEvent(obj, eventData)
    %       % Notify datasource listeners of event triggered initially by reader
    %       try notify(obj, eventData.EventName, eventData); end
    %     end
    
  end
  
  methods (Static)
    function tf = ValidateReader(reader)
      tf = isscalar(reader) && isa(reader, 'GrasppeAlpha.Data.Reader') && isvalid(reader);
    end
  end
  
  
  methods (Abstract, Access=protected)
    % tf      = attachReaderListeners(obj, reader)
  end
  
  methods (Abstract, Static)
    reader  = GetNewReader(dataSource);
  end
  
  
end

