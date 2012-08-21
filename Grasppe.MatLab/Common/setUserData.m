function [ userData ] = setUserData( handle, userData )
  %SETUSERDATA Set user data to graphic handle
  
  try
    set(handle, 'UserData', userData);
  catch err
    userData = [];
  end

end

