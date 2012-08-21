function [data,fontname] = pfbread(pfbfile)
%PFBREAD   Read and decrypt a Printer Font Binary (PFB) file
%   [DATA,FONTNAME] = PFBREAD(PFBFILE) returns character string (including
%   encrypted binary segment) of the Type 1 font given in a PFB file
%   specified by PFBFILE.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release
% rev. 1 : (03-20-2012)
%          * added try-catch block in case fread errors out
%          * additionally returns the fontname

% pfbfile = 'urwbase35\usyr.pfb';
fid = fopen(pfbfile,'rb');
try
   data = fread(fid,'*uint8');
catch ME
   fclose(fid);
   rethrow(ME);
end
fclose(fid);

PFBMARKER = 128;
PFB_DONE	= 3;

uint32 = 2.^((0:3)*8);

Iseghdr = zeros(3,6);

N = numel(data);
n = 0; % data byte counter
for s = 1:3 % for each expected segments
   Iseghdr(s,:) = (n+1):(n+6);
   if n>=N-2 || data(n+1)~=PFBMARKER
      error('Invalid segment header.');
   elseif data(n+2)==PFB_DONE
      break;
   end

   block_len = uint32*double(data(n+2+(1:4)));
   n = n + 6 + block_len;
end

data([Iseghdr(:);N-1;N]) = [];
data = char(data).';

% get font name
if nargout>1
   fontname = regexp(data,'\s/FontName\s+(/\S+)\s+def\s','tokens','once');
   fontname = fontname{1}; % to plain char array
end
