function epsembedfont(varargin)
%EPSEMBEDFONT   Embed fonts to a MATLAB-generated EPS file
%   EPSEMBEDFONT(EPSFILE) analyzes the MATLAB generated EPS file specified
%   by EPSFILE for the fonts used, and embeds all fonts used in the file.
%   The fonts to be embed must be defined in the font search path or in the
%   font alias table.
%
%   EPSEMBEDFONT(EPSFILE,OUTFILE) saves the modified EPS data to a file
%   specified by FILENAME.
%
%   EPSEMBEDFONT(...,'--Subset') only embeds minimum subsets of fonts to be
%   embedded. EPSEMBEDFONT(...,'--Full') conversely embeds full font
%   dictionaries. The default is 'Subset'. 
%
%   EPSEMBEDFONT(...,'--Encrypt') eexec encrypts and encodes (ASCII
%   hexadecimal) the Private & CharStrings subdictionaries of embedded font
%   dictionaries. EPSEMBEDFONT(...,'--NoEncrypt') removes the encryption,
%   which roughly halves the byte size of font dictionaries but leaves
%   binary data to be exposed in the EPS. The default option is 'Encrypt',
%   and it is recommended to keep encryption on if the EPS file may later
%   be modified by hand.
%
%   EPSEMBEDFONT(...,'+/-All','+/-FontName1','+/-FontName2',...) specifies
%   which font to be embedded with the name of the font that is not
%   embedded. Option '+All' is the default, and it selects all needed
%   fonts. Option '+FontName' embeds the specified font, and '-FontName'
%   unembeds the font. '-FontName' option can be used with '+All' option to
%   specify exceptions. 
%
%   Moreover, '+FontName=>EmbedFontName' option may be used to force font
%   conversion. For example, '+Courier=>Courier-SH' is equivalent to the
%   default embedding of the Courier font.
%
%   See also: EPSFONTPATH, EPSFONTALIAS, EPSWRITE, EPSFIXFONTS.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epsembedfont.html','-helpbrowser')">doc epsembedfont</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-18-2012)
%          * major rework
%          * gets font info from PFB files found in EPSFONTPATH and look up
%            font aliases according to EPSFONTALIAS
%          * now uses private functions: getfonts, findfont, pfbread,
%            pfb2pfa
%          * includes font subsetting code which is still under development
% rev. 2 : (03-24-2012)
%          * added subsetting and encryption options.
%          * subsetting is enabled by default
% rev. 3 : (03-31-2012)
%          * fixed error when figure has no character
% rev. 4 : (05-03-2012)
%          * extensive rework to address the major embedding bug
%          * embedded font gets re-embedded even if already embedded
% rev. 5 : (05-08-2012)
%          * added link to help browser

import EPSUtility.*;


% parse input arguments
try
   [infile,outfile,opts] = parse_input(nargin,varargin);
catch ME
   rethrow(ME);
end

% Make sure that the font issues have been addressed
try
   epsfixfonts(infile,outfile);
catch ME
   rethrow(ME);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analyze the figure EPS file first
try
   [imgdata,wmfdata,tifdata] = getdata(infile);
catch ME
   rethrow(ME);
end

% Find used fonts, separate embedded font data from imgdata 
[AllFonts,EmbeddedFonts,EmbeddedFontData,imgdata] = getfonts(imgdata); % fontdata removed from imgdata 
Nfonts = numel(AllFonts);
if Nfonts==0 % if there is no font used
   if ~strcmp(infile,outfile)
      % Output modified EPS data to the file
      try
         putdata(outfile,imgdata,wmfdata,tifdata);
      catch ME
         rethrow(ME);
      end
   end
   return
end
embed0 = false(1,Nfonts); % true if font is already embedded
[~,I] = ismember(EmbeddedFonts,AllFonts);
embed0(I) = true;

% true if subset font data
subset0 = cellfun(@(font)numel(font)>6 && all(font(end-2:end)=='-SS'),AllFonts);

% get full font names
FontNames = AllFonts;
FontNames(subset0) = regexprep(AllFonts(subset0),'-SS$','');

% revert the font name to full font in imgdata
for n = find(subset0)
   % change font name in imgdata to the full set font (no -subset suffix)
   imgdata = fontrep(imgdata,AllFonts{n},FontNames{n});
end

% Start processing embedding requests
outFont = FontNames; % the font name after change
nowarn = isempty(opts); % for default embedding, turn off warning
subset = true;
encrypt = true;
if nowarn % default: embed all
   embed1 = true(1,Nfonts);
else % only selected -> initialize to current state
   embed1 = embed0; % true if embedded
   tok = regexp(opts,'(+|-)([^= \f\n\r\t\v]+)(?:=>)?(\S*)','tokens');
   I = cellfun(@isempty,tok);
   if any(I)
      error('Invalid option.');
   end
   tok(I) = [];
   for n = 1:numel(tok) % for each valid options
      switch lower(tok{n}{1}{2})
         case '-subset'
            subset = true;
         case '-full'
            subset = false;
         case '-encrypt'
            encrypt = true; % default
         case '-noencrypt'
            encrypt = false;
         otherwise
            
            % get font name (currently used in the EPS)
            font = tok{n}{1}{2};

            if strcmpi(font,'all') % check if 'All' option specified
               I(:) = true;
            else
               I = strcmpi(font,FontNames);
            end
            if any(I)
               switch tok{n}{1}{1}
                  case '+' % embed
                     embed1(I) = true;
                  case '-' % unembed
                     embed1(I) = false;
                  otherwise
                     error('Invalid option found (first character must be either ''+'' or ''-''.');
               end
               
               outfont = tok{n}{1}{3};
               if ~isempty(outfont)
                  outFont{I} = outfont;
               end
            end
      end
   end
end

% Prepping for subsetting (get characters used in the image)
if subset && any(embed1)
   % Get all strings in the EPS
   Strings = struct2cell(getallstr(imgdata));
end

% Embed (and re-embed) fonts
for n = find(embed1) % for each font to be embedded
   % Load the font data
   pfbfile = findfont(['/' outFont{n}],true);
   if isempty(pfbfile)
      if ~nowarn
         fprintf('Could not find a PFB file for %s font.\n',outFont{n});
      end
      embed1(n) = ~isempty(EmbeddedFontData{n});
      continue; % ignore this font
   end
   
   if subset
      % gather all glyphs used
      I = strcmp(['/' FontNames{n}],Strings(4,:));
      chars = [Strings{3,I}];
      [fontdata,fontname] = pfbembed(pfbfile,encrypt,chars);
      
      % update imgdata to use the modified font name with suffixe '-SS'
      imgdata = fontrep(imgdata,FontNames{n},fontname);
      outFont{n} = fontname;
   else
      fontdata = pfbembed(pfbfile,encrypt,'');
   end
   
   % Add DSC pre-&post-ambles to declare embedded font blocks, with
   % "%%BeginResource: font" and %%EndResource
   EmbeddedFontData{n} = sprintf('\n%%%%BeginResource: font %s\n%s%%%%EndResource\n',...
      outFont{n},fontdata);
   
   % change font name in imgdata
   imgdata = regexprep(imgdata,['(?<=/|\s)' AllFonts{n}() '(?=\s)'],outFont{n});
   AllFonts{n} = outFont{n};
end

% Insert the embedded font data in the appropriate location within Prolog
I = regexp(imgdata,'%%EndProlog','start');
imgdata = [imgdata(1:I-1) [EmbeddedFontData{embed1}] imgdata(I:end)];

% Update '%%DocumentNeededResources' & '%%DocumentSuppliedResources' headers
EmbeddedFonts = AllFonts(embed1);
NeededFonts = AllFonts(~embed1);
rscstr = '%%DocumentNeededResources:';
if ~isempty(NeededFonts)
   rscstr = sprintf('%s font',rscstr);
   N = 127;
   for n = 1:numel(NeededFonts)
      rscstr_new = sprintf('%s %s',rscstr,NeededFonts{n});
      if numel(rscstr_new)>N % must change line
         N = numel(rscstr)+127;
         rscstr = sprintf('%s\n%%%%+ font %s',rscstr,NeededFonts{n});
      else
         rscstr = rscstr_new;
      end
   end
end
rscstr = sprintf('%s\n',rscstr);
imgdata = regexprep(imgdata,'%%DocumentNeededResources:.+?(?>[\r\n]{1,2})(?!%%\+)',rscstr,'once');

rscstr = '%%DocumentSuppliedResources:';
if ~isempty(EmbeddedFonts)
   rscstr = sprintf('%s font',rscstr);
   N = 127;
   for n = 1:numel(EmbeddedFonts)
      rscstr_new = sprintf('%s %s',rscstr,EmbeddedFonts{n});
      if numel(rscstr_new)>N % must change line
         N = numel(rscstr)+127;
         rscstr = sprintf('%s\n%%%%+ font %s',rscstr,EmbeddedFonts{n});
      else
         rscstr = rscstr_new;
      end
   end
end
rscstr = sprintf('%s\n',rscstr);
imgdata = regexprep(imgdata,'%%DocumentSuppliedResources:.+?(?>[\r\n]{1,2})(?!%%\+)',rscstr,'once');

% Output modified EPS data to the file
try
   putdata(outfile,imgdata,wmfdata,tifdata);
catch ME
   rethrow(ME);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [infile,outfile,opts] = parse_input(N,args)

error(nargchk(1,inf,N));

% All input must be strings
if any(cellfun(@(p)~ischar(p)||size(p,1)>1,args))
   error('All arguments must be a string of characters.');
end

infile = args{1};
[~,~,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension

if N<2 || isempty(args{2}) || any(args{2}(1)=='+-')
   outfile = infile;
   n0 = 2;
else
   outfile = args{2};
   [~,~,e] = fileparts(outfile);
   if isempty(e), outfile = [outfile '.eps']; end % auto-append '.eps' extension
   n0 = 3;
end

% rest are option arguments
opts = args(n0:end);

end
