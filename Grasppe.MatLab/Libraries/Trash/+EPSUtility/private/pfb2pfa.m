function [data,fontname] = pfb2pfa(pfbfile,psstr)
%PFB2PFA Read PFB file and convert to a PFA stream

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release

% get PFB data as is
data = pfbread(pfbfile);

if isempty(psstr) % full-set embedding (no name change)
   fontname = char(regexp(data,'\s/FontName\s+/(\S+)\s+def\s','tokens','once'));
else
   % get decrypted PFB data
   [~,data] = type1info(data,true,true);
   
   % create subset encrypted type-1 font definition
   [data,fontname] = type1subset(data,psstr);
end

% get start and end of binary section
Istart = regexp(data,'\scurrentfile eexec\s+','end','once');
Iend = regexp(data,'cleartomark')-1;
cnt = 0;
while cnt<512 && any(data(Iend)==sprintf(' \f\n\r\t\v0'))
   Iend = Iend-1;
   if data(Iend)=='0'
      cnt = cnt+1;
   end
end

% convert binary to hex
N = 2*(Iend-Istart-1);
hexdata = reshape(dec2hex(uint8(data(Istart+1:Iend-1)))',1,N);

% char(decrypt(uint8(hex2dec(reshape(hexdata,2,numel(hexdata)/2)')),uint16(55665)))

M = 127; % max number of characters/row (must be less than 255)
Nrows = floor(N/M);
N1 = M*Nrows;
hexdata = [reshape([reshape(hexdata(1:N1),M,Nrows);repmat(char(10),1,Nrows)],[1 N1+Nrows]) hexdata(M*Nrows+1:end) char(10)];

data = [data(1:Istart) hexdata data(Iend:end)];
