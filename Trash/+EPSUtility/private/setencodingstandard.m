function FInfo = setencodingstandard(FInfo)
%SETENCODINGSTANDARD   Set font encoding to Standard Latin 1
%   SETENCODINGSTANDARD(FInfo) sets the encoding for the font
%   information given in FInfo to Standard Latin 1.
%
%   This encoding is used if PFB file has the line "/Encoding
%   (StandardEncoding)" line and does not define /Agrave.

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
   'quoteright'      '''';
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
   'exclamdown'      '\241';
   'cent'            '\242';
   'sterling'        '\243';
   'fraction'        '\244';
   'yen'             '\245';
   'florin'          '\246';
   'section'         '\247';
   'currency'        '\250';
   'quotesingle'     '\251';
   'quotedblleft'    '\252';
   'guillemotleft'   '\253';
   'guilsinglleft'   '\254';
   'guilsinglright'  '\255';
   'fi'              '\256';
   'fl'              '\257';
   'endash'          '\261';
   'dagger'          '\262';
   'daggerdbl'       '\263';
   'periodcentered'  '\264';
   'paragraph'       '\266';
   'bullet'          '\267';
   'quotesinglbase'  '\270';
   'quotedblbase'    '\271';
   'quotedblright'   '\272';
   'guillemotright'  '\273';
   'ellipsis'        '\274';
   'perthousand'     '\275';
   'questiondown'    '\277';
   'grave'           '\301';
   'acute'           '\302';
   'circumflex'      '\303';
   'tilde'           '\304';
   'macron'          '\305';
   'breve'           '\306';
   'dotaccent'       '\307';
   'dieresis'        '\310';
   'ring'            '\312';
   'cedilla'         '\313';
   'hungarumlaut'    '\315';
   'ogonek'          '\316';
   'caron'           '\317';
   'emdash'          '\320';
   'AE'              '\341';
   'ordfeminine'     '\343';
   'Lslash'          '\350';
   'Oslash'          '\351';
   'OE'              '\352';
   'ordmasculine'    '\353';
   'ae'              '\361';
   'dotlessi'        '\365';
   'lslash'          '\370';
   'oslash'          '\371';
   'oe'              '\372';
   'germandbls'      '\373';
   }];
