function singlton = GetSinglton()
  %GETSINGLTON Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent Singlton;
  
  if ~isa(Singlton, mfilename('class'));
    Singlton            = feval(mfilename('class'));
  end
  
  singlton              = Singlton;
  
end
