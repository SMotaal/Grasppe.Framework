function [ output_args ] = statusUpdate( status, fid )
  %STATUSUPDATE Summary of this function goes here
  %   Detailed explanation goes here
  
  default status '';
  default fid false;
  
  if isempty(status)
    statusbar(0);
  else
    if ischar(status)
      statusbar(0, status);
      if isnumeric(fid)
        fprintf(fid, ['\n' status]);
      else
        disp(status);
      end
    end
  end
  
end

