function onKeyPress(obj, src, evt)
  %ONKEYPRESS Figure Key Press Event Handling
  %   Detailed explanation goes here
  
  
      obj.AltKeyDown          = any(strcmp('alt',     evt.Modifier));
      obj.ControlKeyDown      = any(strcmp('control', evt.Modifier));
      obj.ShiftKeyDown        = any(strcmp('shift',   evt.Modifier));
      obj.MetaKeyDown         = any(strcmp('command', evt.Modifier));               % any(strcmp('meta',    evt.Modifier))
      
      try
        switch evt.Character
          case 'i'
            if isequal({'COMMAND'}, sort(upper(evt.Modifier)))
              try
                if ishandle(obj.Object.CurrentObject), inspect(obj.Object.CurrentObject); end
              catch err
                obj.inspect();
              end
              
            elseif isequal({'COMMAND', 'SHIFT'}, sort(upper(evt.Modifier)))
              obj.inspect();
            end
            return;
          case 'r'
            if isequal({'COMMAND'}, sort(upper(evt.Modifier)))
              h                     = []; % obj.Handle;
              try h                 = overobj('axes'); end
              try if isempty(h), h  = obj.CurrentAxes; end; end
              try reset(h); end
            elseif isequal({'COMMAND', 'SHIFT'}, sort(upper(evt.Modifier)))
              try reset(obj.Handle); end
            end
        end
        
        switch evt.Key
          % case 'alt'
            % try obj.Object.CurrentAxes = overobj('axes'); end
        end
      catch err
        GrasppeKit.Utilities.DisplayError(obj, 1, err);
      end
      
      Grasppe.Prototypes.Utilities.StampEvent(obj, struct('Name', evt.Key), evt);
      
      obj.GestureComponent.setVisible(obj.AltKeyDown);
    end
