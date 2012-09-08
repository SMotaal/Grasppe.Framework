classdef GrasppeKit
  %GRASPPEKIT Commonly Used Tools
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Static)
    delayTimer = DelayedCall(callback, delay, start)
    
    function DeleteEvent(evt, force)
            
      if ~exist('force', 'var') || isempty(force)
        GrasppeKit.DelayedCall(@(s, e)GrasppeKit.DeleteEvent(evt, 'force'), 1, 'start');
      else
        try delete(evt); end
      end
    end
    
  end
  
end

