function [imgdata,wmfdata,tifdata] = getdata(infile)
%GETDATA   Retrieves EPS data from a file.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-20-2012) * precautionaly changed reading bytes as char 
%                         (instead using uint8) to as uint8 (and return
%                         them as chars)

wmfdata = [];
tifdata = [];

fid = fopen(infile ,'rb');
if fid<0
   error('EPSFILE is not a name of a valid file.');
end

try
   data = fread(fid,30,'uint8');
   if all(data(1:2)==[37;33]) % no preview embedded
      frewind(fid);
      imgdata = fread(fid,'uint8=>char').'; % make sure nothing funky to happen
   else
      if any(data(1:4)~=[197;208;211;198])
         error('%s is not a valid EPS file',infile);
      end
      header = getheader(data);
      fseek(fid,header.pspos,'bof');
      imgdata = fread(fid,header.pslen,'uint8=>char').';
      if header.wmflen~=0
         fseek(fid,header.wmfpos,'bof');
         wmfdata = fread(fid,header.wmflen,'uint8');
      end
      if header.tiflen~=0
         fseek(fid,header.tifpos,'bof');
         tifdata = fread(fid,header.tiflen,'uint8');
      end
   end
catch ME
   msg = ferror(fid);
   fclose(fid);
   if isempty(msg)
      rethrow(ME)
   else
      error(msg);
   end
end
fclose(fid);

end

function header = getheader(data)
   fourbytes = 2.^((0:3)*8);
   header = struct('pspos',fourbytes*data(5:8),...
      'pslen',fourbytes*data(9:12),'wmfpos',fourbytes*data(13:16),...
      'wmflen',fourbytes*data(17:20),'tifpos',fourbytes*data(21:24),...
   	'tiflen',fourbytes*data(25:28));
end
