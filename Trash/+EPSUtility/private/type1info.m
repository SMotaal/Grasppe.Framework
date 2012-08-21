function [FInfo,data] = type1info(data,detail,winenc)
%TYPE1INFO   Get Type 1 font info
%   [INFO,DATA] = TYPE1INFO(DATA,DETAIL,WINENC)

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release

tok = regexp(data,{...
   '/(FontName)\s*(\S+)',...
   '/(FullName)\s*\((.+?)\)',...
   '/(FamilyName)\s*\((.+?)\)',...
   '/(Weight)\s*\((\S+)\)',...
   '/(ItalicAngle)\s*(\S+)'},'tokens','once');
tok = [tok{:}];
FInfo = struct(tok{:});
if isfield(FInfo,'ItalicAngle')
   FInfo.ItalicAngle = str2double(FInfo.ItalicAngle);
else
   FInfo.ItalicAngle = 0;
end

if detail
   
   % Check Encoding
   enc = regexp(data,'/Encoding\s*(\S+)','tokens','once');
   FInfo.StandardEncoding = strcmp(enc,'StandardEncoding');
   
   % Check font scaling
   tok = regexp(data,'/FontMatrix\s*(\[.+?\])','tokens','once');
   FontMatrix = str2num(tok{1}); %#ok
   
   % Collect character info
   tok = regexp(data,'/lenIV \d+','tokens','once');
   if isempty(tok)
      k0 = 4;
   else
      k0 = str2double(tok);
   end
   
   % Decrypt Private & CharStrings dictionaries (only if needed)
   if isempty(regexp(data,'/Private','once')) % not yet decrypted
      Istart = regexp(data,'\scurrentfile\s+eexec\s+','end','once');
      if isempty(Istart)
         error('Invalid Type-1 font: encrypted section of the data not found.');
      end
      
      % determine the last encrypted byte (start from cleartomark & back track 512 '0's)
      Iend = regexp(data,'cleartomark[\s{\(]')-1;
      if isempty(Iend)
         error('Invalid Type 1 font data: does not have "cleartomark" command.');
      end
      cnt = 0;
      while cnt<512 && any(data(Iend)==sprintf(' \f\n\r\t\v0'))
         Iend = Iend-1;
         if data(Iend)=='0'
            cnt = cnt+1;
         end
      end
      
      encdata = data(Istart+1:Iend-1);
      if all(ismember(encdata(1:4),'0123456789abcdefABCDEF')) % then ASCII HEX encoded
         hexdata = regexprep(encdata,'\s','');
         N = floor(numel(hexdata)/2);
         encdata = hex2dec(reshape(hexdata(1:2*N),2,N).');
      end
      
      % decrypt the encoded section of the PFB data
      encdata = char(decrypt(uint8(encdata),uint16(55665)));
      I = regexp(encdata,'\scurrentfile\s+closefile\s?','end','once'); % only include up to 'closefile'
      if isempty(I)
         error('Invalid Type-1 font data: Encrypted section does not end with "closefile" operator.');
      end
      data = [data(1:Istart) ...
         encdata(5:I) ... % remove the padded initial 4 bytes
         sprintf('\n') ...
         data(Iend:end)];
   end
   
   % Extract the width info (by getting the operands of the first operator
   % for each glyph)
   tok = regexp(data,'/(\S+) \d+ RD (.+?)ND','tokens');
   I = cellfun(@(x)strcmp(x{1},'.notdef'),tok);
   tok(I) = [];
   N = numel(tok);
   FInfo.CharWidth = cell2struct(cell(1,N),...
      cellfun(@(x)x{1},tok,'UniformOutput',false),2);
   FInfo.CharCode = FInfo.CharWidth;
   
   stack = zeros(24,1);
   for n = 1:N
      charstr = double(decrypt(uint8(tok{n}{2}),uint16(4330)));
      k = k0;
      p = 0;
      while k<=numel(charstr)
         k = k + 1;
         v = charstr(k);
         if v<32 % command: first command must contain the width info
            done = true;
            if v == 13 % hsbw
               FInfo.CharWidth.(tok{n}{1}) = stack(p)*FontMatrix(1);
            elseif v == 12
               switch charstr(k+1)
                  case 7 % sbw
                     FInfo.CharWidth.(tok{n}{1}) = stack(p-1)*FontMatrix(1);
                  case 12 % div
                     done = false;
                     stack(p-1) = stack(p-1)/stack(p);
                     p = p - 1;
                     k = k + 1;
                  otherwise
                     disp(['Unknown command: 12 ' num2str(charstr(k+1))]);
               end
            else
               disp(['Unknown command: ' num2str(charstr(k+1))]);
            end
            if done, break; end % stop after command
         elseif v>=32 && v<=246
            % 1. A charstring byte containing a value, v, between 32
            %    and 246 inclusive, indicates the integer v - 139.
            p = p + 1; % next stack position
            stack(p) = v - 139;
         elseif v==255 % 4-byte integer
            % 4. Finally, if the charstring byte contains the value 255, the next four
            %    bytes indicate a two’s complement signed integer. The first of these
            %    four bytes contains the highest order bits, the second byte contains
            %    the next higher order bits and the fourth byte contains the lowest
            %    order bits. Thus, any 32-bit signed integer may be encoded in 5 bytes
            %    in this manner (the 255 byte plus 4 more bytes).
            k = k + 4;
            y = charstr(k-3:k);
            p = p + 1; % next stack position
            stack(p) = y*(2.^(24:-8:0).');
         else % 2-byte integer
            k = k + 1;
            w = charstr(k);
            p = p + 1; % next stack position
            if v<=250
               % 2. A charstring byte containing a value, v, between 247
               %    and 250 inclusive, indicates an integer involving
               %    the next byte, w, according to the formula: [(v -
               %    247) * 256] + w + 108
               stack(p) = ((v-247)*256) + w + 108;
            else%if v>=251 && v<=254
               % 3. A charstring byte containing a value, v, between 251
               %    and 254 inclusive, indicates an integer involving
               %    the next byte, w, according to the formula: - [(v -
               %    251) * 256] - w - 108
               stack(p) = ((v-251)*256) - w - 108;
            end
         end
      end
   end
   
   % Get Character code
   if winenc && isfield(FInfo.CharCode,'Agrave') % Windows
      FInfo(:) = setencodingwindows(FInfo);
   elseif FInfo.StandardEncoding
      FInfo(:) = setencodingstandard(FInfo);
   else % Custom
      tok = regexp(data,'dup\s+(\d+)\s?/(\S+)\s+put\s+','tokens');
      N = numel(tok);
      cct = cell(N,2);
      for n = 1:numel(tok)
         cct{n,1} = tok{n}{2}; % glyph name
         ch = str2double(tok{n}{1});
         if ch>=32 && ch<127 % 'use regular character
            ch = char(ch);
            if any(ch=='()\') % exceptions requiring escape character
               ch = ['\' ch]; %#ok
            end
            cct{n,2} = ch;
         else
            oct = '\   ';
            oct(2) = floor(ch/64)+48;
            ch = mod(ch,64);
            oct(3) = floor(ch/8)+48;
            ch = mod(ch,8);
            oct(4) = ch+48;
            cct{n,2} = oct;
         end
      end
      FInfo.CharCode = cct;
   end
end
