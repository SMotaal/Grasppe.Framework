function width = getstrwidth(str,font,sz)
%GETSTRWIDTH   Get width of EPS string in inches
%   GETSTRWIDTH(STRING,FONT,SZ) returns the width of the string, given in
%   STRING, using SZ-point Type 1 font information given in FONT (struct
%   returned by TYPE1INFO).


% Compute the width of the string
table = font.CharCode;
N = numel(str); % number of characters
width = 0;
n = 0;
while n<N
   if str(n+1)=='\' % if escape character
      if any(str(n+2)=='(\)')
         chlen = 2; % parenthesis or backslash
      elseif any(str(n+2)=='23')
         chlen = 4; % octal
      else
         error('Invalid escape character sequence found.');
      end
      if n+chlen>N
         error('Unterminated escape charactger sequence found.');
      end
   else
      chlen = 1;
   end
   
   ch = str(n+1:n+chlen);
   n = n + chlen;
   
   I = find(strcmp(ch,table(:,2)),1);
   if isempty(I)
      error('Unsupported character code found.');
   end
   
   width = width + font.CharWidth.(table{I,1});
end

% Scale the width to actual inches
width = width*sz/72;
