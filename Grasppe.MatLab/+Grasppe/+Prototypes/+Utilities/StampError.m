function StampError(obj, level, err)
  %STAMPEVENT Print Event Stamp fto Console
  %   Detailed explanation goes here
  
  evalin('caller', ['debugStamp( err, ' int2str(level) ', ' inputname(1) ');' ]);
  
  return;
  
end
