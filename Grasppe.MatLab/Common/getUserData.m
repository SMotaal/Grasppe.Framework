function [ userData ] = getUserData( handle )
  %GETUSERDATA Retireve user data from graphic handle
  
  try
    userData = get(handle, 'UserData');
  catch err
    userData = [];
  end
  
end

