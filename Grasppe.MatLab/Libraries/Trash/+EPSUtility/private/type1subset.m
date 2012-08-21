function [data,fontname] = type1subset(data,chars)
%TYPE1SUBSET   Define a subset font definition of Type-1 font
%   SUBSETFONT(TYPE1DATA,CHARS) takes the Type-1 font definition in
%   TYPE1DATA and create its subset definition that is sufficient to render
%   CHARS postscript string sequence.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-15-2012) original release

% Get detailed font info
finfo = type1info(data,true,true);

% Append "-SS" to the font name to specify the change
fontname = [finfo.FontName(2:end) '-SS']; % subset

% Change font name
data = strrep(data,finfo.FontName(2:end),fontname);

% Remove UniqueID
% [I0,I1] = regexp(data,'/UniqueID \d+ def\s+')

% Determine the subset glyphs
subset = cell(numel(chars),1);
n = 1; k = 0;
while n<=numel(chars)
   k = k+1;
   if chars(n)=='\'
      if any(chars(n+1)=='(\)')
         enc = chars(n:n+1);
         n = n + 2;
      else % octal
         enc = chars(n:n+3);
         n = n + 4;
      end
   else
      enc = chars(n);
      n = n + 1;
   end
   I = strcmp(enc,finfo.CharCode(:,2));
   if isempty(I)
      error('Invalid character code found.');
   end
   subset(k) = finfo.CharCode(I,1);
end
subset = unique(subset(1:k));
Nglyphs = numel(subset); % number of glyphs to include

% Reduce Encoding array
Encoding = cell(Nglyphs,1);
enc = regexp(data,'/Encoding\s*(\S+)','tokens','once');
if strcmp(enc,'StandardEncoding')
   [Istart,Iend] = regexp(data,'\s/Encoding\s+.+?\s+def\s+','start','end','once');
   for n = 1:Nglyphs
      I = strcmp(subset{n},finfo.CharCode(:,1));
      if ~any(I)
         error('Invalid character encoding found.');
      end
      code = finfo.CharCode{I,2};
      switch numel(code)
         case 1 % ASCII
            code = double(code);
         case 2 % (|)
            code = double(code(2));
         case 4 % octal
            code = double(code(2:end)-'0')*[64;8;1];
         otherwise
            error('Invalid character encoded value.');
      end
      Encoding{n} = sprintf('dup %d /%s put\n',code,subset{n});
   end
   Nenc = 256;
else %
   [Istart,Iend,Nencstr] = regexp(data,'\s/Encoding\s+(\d+)\s+array\s+.+?readonly\s+def\s+','start','end','tokens','once');
   Nenc = str2double(Nencstr);
   
   for n = 1:Nglyphs
      Encoding(n) = regexp(data,['\s(dup\s+\d+\s*/' subset{n} '\s+put\s+)'],'tokens','once');
   end
   
end

data = [data(1:Istart) ...
   sprintf('/Encoding %d array\n0 1 %d { 1 index exch /.notdef put} for\n',Nenc,Nenc-1) ...
   Encoding{:} ...
   sprintf('readonly def\n') ...
   data(Iend+1:end)];

% Reduce CharString dict
Istart = regexp(data,'\s/CharStrings.+?begin\s+','start','once');
Ilast = regexp(data,'\send\s+end\s+(?:readonly\s+)?put\s+(?:noaccess\s+)?put\s','start','once');

CharStrings = cell(Nglyphs+1,1); % must have '.notdef' as necessary glyph
for n = 1:Nglyphs
   CharStrings(n) = regexp(data,['(/' subset{n} ' \d+ RD .+?ND\s+)'],'tokens','once');
end
CharStrings(end) = regexp(data,'(/.notdef \d+ RD .+?ND\s+)','tokens','once');

data = [data(1:Istart) ...
   sprintf('/CharStrings %d dict dup begin\n',Nglyphs+1) ...
   CharStrings{:} ...
   data(Ilast+1:end)];
