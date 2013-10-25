classdef ChangeEventData < event.EventData
  %EVENTDATA Printing uniformity data event
  %   Detailed explanation goes here
  
  properties (Access=protected)
    
    parameter
    newValue
    previousValue
    previousData
    
    status        = 'clear';
    
    exception
    
    reason
    
  end
  
  properties (Dependent)
    Parameter
    CurrentValue
    NewValue
    PreviousValue
    PreviousData
    
    Pending
    Active
    Succeeded
    Failed
    Aborted
    
    Reverted
    
    Exception
    Reason
    
    Status
  end
  
  methods (Access=protected)
    function evt = ChangeEventData(parameter, newValue, previousValue, previousData)
      evt.Initialize(parameter, newValue, previousValue, previousData);
    end
    
    function value = getCurrentValue(evt)
      value     = evt.previousValue;
      if isequal(evt.status, 'succeeded')
        value   = evt.newValue; end
    end
    
    function exception = eventError(evt, id, varargin)
      
      exception = GrasppeAlpha.Data.ChangeEventData.GenerateException(evt, id, varargin{:});
            
      if nargout==0, throw(exception); end
      
    end
    
  end
  
  methods
    
    function Initialize(evt, parameter, newValue, previousValue, previousData)
      try
        
        if ~isequal(evt.status, 'clear'), evt.eventError('CannotInitialize'); end
        
%         parameters            = feval([class(evt) '.GetDataParameters']);
%         
%         if iscellstr(parameters) && ~isempty(parameters)
%           try
%             parameter         = parameters(find(strcmpi(parameter, parameters), 1));
%           catch err
%             parameter         = [];
%           end
%         end
%         
%         if ~isempty(newValue) && isempty(parameter)
%           evt.eventError('InvalidParameter');
%         end
        
        try evt.parameter     = parameter;        end
        try evt.newValue      = newValue;         end
        try evt.previousValue = previousValue;    end
        try evt.previousData  = previousData;     end
        
        evt.status            = 'pending';
                
      catch err
        rethrow(err);
      end
    end
    
    function Activate(evt) %, parameter, newValue, previousValue, previousData)
      try
        
        if isequal(evt.status, 'active'), evt.eventError('CannotActivate'); end
                
        evt.status            = 'active';
        
      catch err
        rethrow(err);
      end
    end
    
    
    function Complete(evt)
      try
        
        if ~isequal(evt.status, 'active'), evt.eventError('CannotSucceed'); end
        
        evt.status        = 'succeeded';
        
      catch err
        % rethrow(err);
      end
    end
    
    function Abort(evt, cause)
      try
        
        if ~isequal(evt.status, 'active'), evt.eventError('CannotAbort'); end
        
        switch cause
          case {'user'},      reason  = 'The event was aborted by the user';
          case {'interrupt'}, reason  = 'The event was interrupted by a more recent event.';
          otherwise,          reason  = 'The event was aborted.';
        end
        
        try evt.reason    = reason; end
        
        evt.status        = 'aborted';
        
      catch err
        rethrow(err);
      end
    end
    
    function Fail(evt, cause)
      try
        if ~isequal(evt.status, 'active'), evt.eventError('CannotFail'); end
        
        try evt.exception = cause; end
        
        evt.status        = 'failed';
        
      catch err
        rethrow(err);
      end
    end
    
    function [active] = CheckStatusWithException(evt)
      try active          = evt.CheckStatus(true);
      catch err
        rethrow(err);
      end
    end
    
    function [active status] = CheckStatus(evt, withException)
      if ~exist('withException', 'var') || ~isequal(withException, true)
        withException = false; end      
      
      if ~isvalid(evt)
        status            = 'deleted';
        active            = false;
        if withException
          GrasppeAlpha.Data.ChangeEventData.GenerateException(evt, 'EventDeleted');
        end
      end
            
      
      if nargout>1, status = evt.status; end
      
      active = false;      
      
      try
        
        switch evt.status
          case {'active'},  active = true;
          case {'aborted'}, evt.eventError('EventAborted');
          case {'failed'},  evt.eventError('EventFailed');
        end
        
      catch err
        if withException, rethrow(err);end
      end
    end
    
  end
  
  
  %% Property Getters & Setters
  methods
    
    function parameter = get.Parameter(evt)
      parameter = evt.parameter; end
    
    function value = get.CurrentValue(evt)
      value     = evt.getCurrentValue(); end
    
    function value = get.NewValue(evt)
      value     = evt.newValue; end
    
    function value = get.PreviousValue(evt)
      value     = evt.previousValue;  end
    
    function data = get.PreviousData(evt)
      data      = evt.previousData; end
    
    function status = get.Status(evt)
      status    = evt.status; end
    
    function tf = get.Pending(evt)
      tf        = isequal(evt.status, 'pending'); end      
    
    function tf = get.Active(evt)
      tf        = isequal(evt.status, 'active'); end
    
    function tf = get.Succeeded(evt)
      tf        = isequal(evt.status, 'succeeded'); end
    
    function tf = get.Aborted(evt)
      tf        = isequal(evt.status, 'aborted'); end
    
    function tf = get.Failed(evt)
      tf        = isequal(evt.status, 'failed'); end
    
    function tf = get.Reverted(evt)
      tf        = strcmpi(evt.status, {'failed', 'aborted'}); end
    
    function exception = get.Exception(evt)
      exception = evt.exception;
    end
    
    function reason = get.Reason(evt)
      reason    = evt.reason;
    end
  end
  
  %% Property Failsafe
  methods
    function set.status(evt, status)
      switch lower(status)
        case {'pending', 'waiting', 'ready'}
          status  = 'pending';
        case {'active'}
          status  = 'active';
        case {'success', 'succeessful'}
          status  = 'succeeded';
        case {'abort', 'cancel', 'aborted', 'terminated'}
          status  = 'aborted';
        case {'fail', 'failed', 'failure'}
          status  = 'failed';
        otherwise
      end
      
      evt.status  = status;
    end
  end
  
  methods (Static)
    function exception = GenerateException(evt, id, varargin)
      cause           = [];
      switch id
        case 'InvalidParameter'
          id          = 'Event:InvalidParameter';
          message     = sprintf('Cannot create event data for parameter %s.', varargin{:});
        case 'CannotInitialize'
          id          = 'Event:InvalidState';
          message     = 'This event cannot be initialized.';          
        case 'CannotActivate'
          id          = 'Event:InvalidState';
          message     = 'This event cannot be actived.';
        case 'CannotSucceed'
          id          = 'Event:InvalidState';
          message     = 'This event cannot succeed since it is no longer active.';
        case 'CannotAbort'
          id          = 'Event:InvalidState';
          message     = 'This event cannot be aborted since it is no longer active.';
        case 'CannotFail'
          id          = 'Event:InvalidState';
          message     = 'This event cannot fail since it is no longer active.';
        case 'EventAborted'
          id          = 'Event:Aborted';
          message     = 'The event was aborted.';
          try message = evt.reason; end
        case 'EventFailed'
          id          = 'Event:Failed';
          message     = 'The event has failed.';
          try cause   = evt.exception; end
        case 'EventDeleted'
          id          = 'Event:Deleted';
          message     = 'The event was deleted.';
          try cause   = evt.exception; end          
        otherwise  % generic exception
          message     = 'An unexpected error has occured';
          try if ischar(varargin{1}), message = varargin{1}; end; end
          try
            id        = ['Generic:' id];
          catch err
            id        = 'Generic:UnexpectedError';
          end
      end
      
      exception       = MException(['Grasppe:' id], message, varargin{:});
      
      try exception.addCause(cause); end;
      
    end
  end
  
  methods (Abstract, Static)
    % parameters =  GetDataParameters();
    evt        =  CreateEventData(parameter, newValue, previousValue, previousData)
  end
  
end




      %       switch id
      %         case 'InvalidParameter'
      %           id          = 'InvalidParameter';
      %           message     = sprintf('Cannot create event data for parameter %s.', varargin{:});
      %           cause       = [];
      %         case 'CannotActivate'
      %           id          = 'InvalidState';
      %           message     = 'This event cannot be actived since it is already active';
      %           cause       = [];
      %         case 'CannotSucceed'
      %           id          = 'InvalidState';
      %           message     = 'This event cannot succeed since it is no longer active';
      %           cause       = [];
      %         case 'CannotAbort'
      %           id          = 'InvalidState';
      %           message     = 'This event cannot be aborted since it is no longer active';
      %           cause       = [];
      %         case 'CannotFail'
      %           id          = 'InvalidState';
      %           message     = 'This event cannot fail since it is no longer active';
      %           cause       = [];
      %         case 'EventAborted'
      %           id          = 'Aborted';
      %           message     = evt.reason;
      %           cause       = [];
      %         case 'EventFailed'
      %           id          = 'Failed';
      %           message     = 'The event has failed';
      %           cause       = evt.exception;
      %       end
      %
      %       exception       = MException(['Grasppe:Event:' id], message, varargin{:});
      %
      %       try if isa(cause, 'MException'),  exception.addCause(cause); end; end
