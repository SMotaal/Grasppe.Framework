function [data,fontname] = pfbembed(pfbfile,doencrypt,psstr)
%PFBEMBED Get embedding-ready Type-1 font data from a PFB file
%   [DATA,FONTNAME] = PFBEMBED(PFBFILE,DOENCRYPT,PSSTR)
%      DATA - Type 1 font data (char array possibly including binary strands)
%      FONTNAME - font name, if subset, with '-SS' suffix
%      PFBFILE - font file path
%      DOENCRYPT - true to use EEXEC encryption + HEX ASCII encoding
%      PSSTR   - postscript string to obtain subset font data (pass in
%                empty to return full font data
%
%   Use PFBREAD if just need encrypted full font data.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release
% rev. 1 : (03-20-2012)
%          * renamed from PFB2PFA
%          * supports unencrypted embedding
% rev. 2 : (03-24-2012)
%          * fixed regular expression to remove 'mark...cleartomark' text

subset = ~isempty(psstr); % true if to subset

% Read full PFB data
[data,fontname] = pfbread(pfbfile);

if doencrypt && ~subset
   return; % if full doencrypted font requested, done
end

% Remove encryption
Istart = regexp(data,'\scurrentfile\s+eexec\s+','end','once');
if isempty(Istart) % font data is not encrypted (possible?), ignore ENCRYPT argument
   doencrypt = false;
elseif ~doencrypt || subset % perform eexec decrypt
   % determine the last encrypted byte (start from cleartomark & back track 512 '0's)
   Iend = regexp(data,'cleartomark[\s{\(]')-1;
   if isempty(Iend)
      error('Invalid Type 1 font: does not have "cleartomark" command.');
   end
   cnt = 0;
   while cnt<512 && any(data(Iend)==sprintf(' \f\n\r\t\v0'))
      Iend = Iend-1;
      if data(Iend)=='0'
         cnt = cnt+1;
      end
   end
   
   % decrypt the encoded section of the PFB data
   encdata = char(decrypt(uint8(data(Istart+1:Iend-1)),uint16(55665)));
   I = regexp(encdata,'\scurrentfile\s+closefile\s?','end','once'); % only include up to 'closefile'
   if isempty(I)
      error('Invalid PFB file. Encrypted segment does not end with "closefile" operator.');
   end
   
   % recombine the data
   data = [data(1:Istart) ...
      encdata(5:I) ... % remove the padded initial 4 bytes
      sprintf('\n') ...
      data(Iend:end)];
   
   if ~doencrypt % will not be re-encrypted, remove encryption code
      data = regexprep(data,...
         {'(\s)currentfile\s+eexec(\s)','(\s)mark.+?cleartomark([\s{\(])'},...
         '$1$2','once');
   end
end

if subset % subset embedding
   % create subset encrypted type-1 font definition
   [data,fontname] = type1subset(data,psstr);
   % -> fontname gets overwritten: /FontName + '-SS' to indicate it's a subset
end

if doencrypt
   % retrieve section to be encrypted
   [encdata,I] = regexp(data,...
      '\scurrentfile\s+eexec\s+(.+?\scurrentfile\s+closefile\s)',...
      'tokens','tokenExtents','once');
   
   if isempty(encdata)
      error('Failed to subset: eexec segment not found.');
   end
   
   % eexec encrypt the section (may try a few times if encrypted data does
   % not conforms to the Type-1 standard)
   encdata = encrypt([ones(1,4,'uint8') uint8(encdata{1})],uint16(55665));
   header = char(encdata(1:4));
   while isempty(regexp(header,'^[^\w]','once')) && isempty(regexp(header,'[^a-fA-F0-9]','once'))
      encdata(:) = encrypt([randi(255,[1,4],'uint8') uint8(data(I(1):I(2)))],uint16(55665));
      header = char(encdata(1:4));
   end
   
   % convert binary to hex
   N = 2*numel(encdata); % number of HEX digits to expect
   encdata = reshape(dec2hex(encdata)',1,N);

   % wrap HEX sequence to meet # of characters per line constaint
   M = 127; % max number of characters/row (must be less than 255)
   Nrows = floor(N/M);
   N1 = M*Nrows;
   encdata = [reshape([reshape(encdata(1:N1),M,Nrows);repmat(char(10),1,Nrows)],[1 N1+Nrows]) encdata(M*Nrows+1:end)];

   % recombine data
   data = [data(1:I(1)-1) ...
      encdata ...
      data(I(2)+1:end)];
end
