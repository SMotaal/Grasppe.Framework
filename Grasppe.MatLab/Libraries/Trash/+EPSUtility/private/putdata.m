function putdata(outfile,imgdata,wmfdata,tifdata)
%PUTDATA   Save EPS data to a file

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-20-2012) * fixed binary data bug (must use uint8 not char)

%Open flie
fid = fopen(outfile,'wb');
if fid<0
   error('%s cannot be opened.',outfile);
end

Nps = numel(imgdata);
Nwmf = numel(wmfdata);
Ntif = numel(tifdata);
HasBinary = Ntif>0 || Nwmf>0;

try
   if HasBinary % binary data exists
      % write header
      fwrite(fid,putheader(Nps,Nwmf,Ntif),'uint8');
   end
   
   % write postscript data
   fwrite(fid,uint8(imgdata),'uint8');
   
   % write windows meta file data
   if Nwmf>0
      fwrite(fid,wmfdata,'uint8');
   end
   
   % write TIFF data
   if Ntif>0
      fwrite(fid,tifdata,'uint8');
   end
catch %#ok
   msg = ferror(fid);
   fclose(fid);
   error(msg);
end
fclose(fid); % done

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = putheader(pslen,wmflen,tiflen)
   offset = 30;
   data = zeros(offset,1);
   data(1:4) = [197;208;211;198];
   data(5:8) = [offset;0;0;0]; % immediately follows the header
   data(9:12) = typecast(cast(pslen,'uint32'),'uint8');
   if ~isempty(wmflen)
      offset = offset + pslen;
      data(13:16) = typecast(cast(offset,'uint32'),'uint8');
      data(17:20) = typecast(cast(wmflen,'uint32'),'uint8');
   end
   if ~isempty(tiflen)
      offset = offset + wmflen;
      data(21:24) = typecast(cast(offset,'uint32'),'uint8');
      data(25:28) = typecast(cast(tiflen,'uint32'),'uint8');
   end
   data(29:30) = 255; % no checksum
end 
