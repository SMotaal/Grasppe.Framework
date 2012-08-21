function FInfo = setencodingwindows(FInfo)
%SETENCODINGWINDOWS   Set font encoding to Windows Latin 1
%   SETENCODINGWINDOWS(FInfo) sets the encoding for the font
%   information given in FInfo to Windows Latin 1 only if compatible.
%
%   All Latin fonts in the MATLAB EPS files are encoded using this
%   encoding.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release

% if
if ~isfield(FInfo.CharWidth,'Agrave')
   return; % not compatible with WindowsLatin1Encoding
end

% Initialize to ISO Latin1
FInfo(:) = setencodingisolatin1(FInfo);

I1 = find(strcmp('asciitilde',FInfo.CharCode(:,1)),1);
I2 = find(strcmp('exclamdown',FInfo.CharCode(:,1)),1);

% Apply the modification
FInfo.CharCode = [
   FInfo.CharCode(1:I1,:)
   {
   'quotesinglbase'  '\202';
   'florin'          '\203';
   'quotedblbase'    '\204';
   'ellipsis'        '\205';
   'dagger'          '\206';
   'daggerdbl'       '\207';
   'circumflex'      '\210';
   'perthousand'     '\211';
   'Scaron'          '\212';
   'guilsinglleft'   '\213';
   'OE'              '\214';
   'quoteleft'       '\221';
   'quoteright'      '\222';
   'quotedblleft'    '\223';
   'quotedblright'   '\224';
   'bullet'          '\225';
   'endash'          '\226';
   'emdash'          '\227';
   'ytilde'          '\230';
   'trademark'       '\231';
   'scaron'          '\232';
   'guilsinglright'  '\233';
   'oe'              '\234';
   'Ydieresis'       '\237';
   }
   FInfo.CharCode(I2:end,:)
   ];
