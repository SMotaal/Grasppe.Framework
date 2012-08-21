function check = isValidHandle( object )
  %ISVALIDHANDLE   Validate handle and check size
  
  try
    if isnumeric(object)
      object = num2str(object);
    end
    check = evalin('caller', ['ishandle(' object ')']);
    check = isequal(check, true);
  catch
    check = false;
  end
    

%   if isnumeric(object)
%     check = validCheck(object,'handle');
%   elseif ischar(object)
%     check = evalin('caller', ['validCheck(''' object ''', ''handle'')']);
%   end
end

