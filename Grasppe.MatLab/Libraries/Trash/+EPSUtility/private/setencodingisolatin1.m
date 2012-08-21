function FInfo = setencodingisolatin1(FInfo)
%SETENCODINGISOLATIN1   Set font encoding to ISO Latin 1
%   SETENCODINGISOLATIN1(FInfo) sets the encoding for the font
%   information given in FInfo to ISO Latin 1
%
%   This encoding is used if PFB file has the line "/Encoding
%   (ISOLatin1Encoding)" line.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-11-2012) original release

FInfo.CharCode = [
   {...
   'space'           ' ';
   'exclam'          '!';
   'quotedbl'        '"';
   'numbersign'      '#';
   'dollar'          '$';
   'percent'         '%';
   'ampersand'       '&';
   'quotesingle'     '''';
   'parenleft'       '\(';
   'parenright'      '\)';
   'asterisk'        '*';
   'plus'            '+';
   'comma'           ',';
   'hyphen'          '-';
   'period'          '.';
   'slash'           '/';
   'zero'            '0';
   'one'             '1';
   'two'             '2';
   'three'           '3';
   'four'            '4';
   'five'            '5';
   'six'             '6';
   'seven'           '7';
   'eight'           '8';
   'nine'            '9';
   'colon'           ':';
   'semicolon'       ';';
   'less'            '<';
   'equal'           '=';
   'greater'         '>';
   'question'        '?';
   'at'              '@';
   };
   repmat(cellstr(char((65:90).')),1,2);
   {...
   'bracketleft'     '[';
   'backslash'       '\\';
   'bracketright'    ']';
   'asciicircum'     '^';
   'underscore'      '_';
   'quoteleft'       '`';
   }
   repmat(cellstr(char((97:122).')),1,2);
   {
   'braceleft'       '{';
   'bar'             '|';
   'braceright'      '}';
   'asciitilde'      '~';
   'dotlessi'        '\220';
   'grave'           '\221';
   'acute'           '\222';
   'circumflex'      '\223';
   'tilde'           '\224';
   'macron'          '\225';
   'breve'           '\226';
   'dotaccent'       '\227';
   'dieresis'        '\230';
   'ring'            '\232';
   'cedilla'         '\233';
   'hungarumlaut'    '\235';
   'ogonek'          '\236';
   'caron'           '\237';
   'exclamdown'      '\241';
   'cent'            '\242';
   'sterling'        '\243';
   'currency'        '\244';
   'yen'             '\245';
   'brokenbar'       '\246';
   'section'         '\247';
   'dieresis'        '\250';
   'copyright'       '\251';
   'ordfeminine'     '\252';
   'guillemotleft'   '\253';
   'logicalnot'      '\254';
   'registered'      '\256';
   'macron'          '\257';
   'fl'              '\257';
   'degree'          '\260';
   'plusminus'       '\261';
   'twosuperior'     '\262';
   'threesuperior'   '\263';
   'acute'           '\264';
   'mu'              '\265';
   'paragraph'       '\266';
   'cedilla'         '\270';
   'onesuperior'     '\271';
   'ordmasculine'    '\272';
   'guillemotright'  '\273';
   'onequarter'      '\274';
   'onehalf'         '\275';
   'threequarters'   '\276';
   'questiondown'    '\277';
   'Agrave'          '\300';
   'Aacute'          '\301';
   'Acircumflex'     '\302';
   'Atilde'          '\303';
   'Adieresis'       '\304';
   'Aring'           '\305';
   'AE'              '\306';
   'Ccedilla'        '\307';
   'Egrave'          '\310';
   'Eacute'          '\311';
   'Ecircumflex'     '\312';
   'Edieresis'       '\313';
   'Igrave'          '\314';
   'Iacute'          '\315';
   'Icircumflex'     '\316';
   'Idieresis'       '\317';
   'Dcroat'          '\320';
   'Ntilde'          '\321';
   'Ograve'          '\322';
   'Oacute'          '\323';
   'Ocircumflex'     '\324';
   'Otilde'          '\325';
   'Odieresis'       '\326';
   'multiply'        '\327';
   'Oslash'          '\330';
   'Ugrave'          '\331';
   'Uacute'          '\332';
   'Ucircumflex'     '\333';
   'Udieresis'       '\334';
   'Yacute'          '\335';
   'Thorn'           '\336';
   'germandbls'      '\337';
   'agrave'          '\340';
   'aacute'          '\341';
   'acircumflex'     '\342';
   'atilde'          '\343';
   'adieresis'       '\344';
   'aring'           '\345';
   'ae'              '\346';
   'ccedilla'        '\347';
   'egrave'          '\350';
   'eacute'          '\351';
   'ecircumflex'     '\352';
   'edieresis'       '\353';
   'igrave'          '\354';
   'iacute'          '\355';
   'icircumflex'     '\356';
   'idieresis'       '\357';
   'dcroat'          '\360';
   'ntilde'          '\361';
   'ograve'          '\362';
   'oacute'          '\363';
   'ocircumflex'     '\364';
   'otilde'          '\365';
   'odieresis'       '\366';
   'divide'          '\367';
   'oslash'          '\370';
   'ugrave'          '\371';
   'uacute'          '\372';
   'ucircumflex'     '\373';
   'udieresis'       '\374';
   'yacute'          '\375';
   'thorn'           '\376';
   'ydieresis'       '\377';
   }];
