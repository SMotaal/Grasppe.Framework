function message = DisplayError(obj, level, err)
  %STAMPEVENT Print Event Stamp fto Console
  %   Detailed explanation goes here
  try
    if ~isempty(inputname(1))
      evalin('caller', ['debugStamp( err, ' int2str(level) ', ' inputname(1) ');' ]);
    else
      debugStamp( err, level, obj);
    end
  catch err
    debugStamp(err, level, obj);
  end
  
end
