function data = pfadecrypt(data)
%PFADECRYPT Decode & decrypt PFA font data 

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release

Istart = regexp(data,'\scurrentfile eexec\s+','end','once');
Iend = regexp(data,'cleartomark')-1;
cnt = 0;
while cnt<512 && any(data(Iend)==sprintf(' \f\n\r\t\v0'))
   Iend = Iend-1;
   if data(Iend)=='0'
      cnt = cnt+1;
   end
end
   
hexdata = regexprep(data(Istart+1:Iend-1),'\s','');
N = floor(numel(hexdata)/2);
bindata = uint8(hex2dec(reshape(hexdata(1:2*N),2,N).'));
decdata = decrypt(bindata,uint16(55665));

data = [data(1:Istart) decdata data(Iend:end)];
