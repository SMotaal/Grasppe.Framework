classdef Map < containers.Map & Grasppe.Prototypes.Handle
  %MAP Event-Enabled Grasppe Map Prototype
  %   Detailed explanation goes here
  
  properties
  end
  
  events
    MapPreGet
    MapPostGet
    MapPreSet
    MapPostSet
  end
  
  methods
    
    function obj = Map(varargin)
      obj                   = obj@containers.Map(varargin{:});
      obj                   = obj@Grasppe.Prototypes.Handle();
      obj.initialize();
    end
    
    function varargout = subsref(obj, subs, silent)
      
      silent = exist('silent', 'var') && isequal(silent, true);
      
      try
        subRef                  = subs(1).subs;
        subType                 = subs(1).type;
        
        mapType                 = isequal(subType, '()');
        % fieldType               = isequal(subType, '.');
        
        subsCall                = @() builtin('subsref', obj, subs);
        
        if mapType && ~silent
          value                 = obj.subsref@containers.Map(subs(1));
          eventData             = Grasppe.Prototypes.Events.Data(obj, 'MapPreGet', ...
            struct('Key', subRef, 'Value', value));
          obj.notify('MapPreGet', eventData);
          
          subsCall              = @() obj.subsref@containers.Map(subs);
        end
        
        varargout               = {[]};
        if nargout>0, varargout = cell(1, nargout); end
        
        if mapType
          [varargout{:}]        = obj.subsref@containers.Map(subs);
        else
          try
            [varargout{:}]      = builtin('subsref', obj, subs);  %obj.subsref@containers.Map(subs);
          catch err
            builtin('subsref', obj, subs);
          end
        end

        
        %         if nargout>0
        %           [varargout{1:nargout}]  = subsCall();
        %           %           if mapType
        %           %             [varargout{1:nargout}]  = obj.subsref@containers.Map(subs);
        %           %           else
        %           %             [varargout{1:nargout}]  = builtin('subsref', obj, subs);  %obj.subsref@containers.Map(subs);
        %           %           end
        %         else
        %           try
        %             [varargout{1}]  = subsCall();
        %             %             if mapType,
        %             %               [varargout{1}]          = obj.subsref@containers.Map(subs);
        %             %             else
        %             %               [varargout{1}]          = builtin('subsref', obj, subs);  %obj.subsref@containers.Map(subs);
        %             %             end
        %           catch err
        %             subsCall();
        % %             if mapType
        % %               obj.subsref@containers.Map(subs);
        % %             else
        % %               builtin('subsref', obj, subs);
        % %             end
        %           end
        %         end
        
        if mapType && ~silent
          newValue              = obj.subsref@containers.Map(subs(1));
          eventData             = Grasppe.Prototypes.Events.Data(obj, 'MapPostGet', ...
            struct('Key', subRef, 'Value', value, 'NewValue', newValue));
          obj.notify('MapPostGet', eventData);
        end
        
        
      catch err
        rethrow(err);
      end
      
    end
    
    function obj = subsasgn(obj, subs, newValue)
      
      try
        subRef                  = subs(1).subs;
        subType                 = subs(1).type;
        
        mapType                 = isequal(subType, '()');
        
        if mapType
          value                 = obj.subsref(subs(1), true);
          eventData             = Grasppe.Prototypes.Events.Data(obj, 'MapPreSet', ...
            struct('Key', subRef, 'Value', value));
          obj.notify('MapPreSet', eventData);
        end
        
        obj                     = obj.subsasgn@containers.Map(subs, newValue);
        
        if mapType
          newValue              = obj.subsref(subs(1), true);
          eventData             = Grasppe.Prototypes.Events.Data(obj, 'MapPostSet', ...
            struct('Key', subRef, 'Value', value, 'NewValue', newValue));
          obj.notify('MapPostSet', eventData);
        end
        
      catch err
        rethrow(err);
      end
      
    end
    
    %     function onMapPreGet(obj, src, evt)
    %       disp(evt);
    %     end
    %
    %     function onMapPostGet(obj, src, evt)
    %       disp(evt);
    %     end
    %
    %
    %     function onMapPreSet(obj, src, evt)
    %       disp(evt);
    %     end
    %
    %     function onMapPostSet(obj, src, evt)
    %       disp(evt);
    %     end
    
  end
  
end

