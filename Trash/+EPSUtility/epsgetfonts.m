function [AllFonts,EmbeddedFonts] = epsgetfonts(infile)
%EPSGETFONTS   Get all fonts used in an EPS file
%   EPSGETFONTS(EPSFILE) prettyprint all the fonts used in the EPS file
%   specified by EPSFILE.
%
%   [AllFonts,EmbeddedFonts] = EPSGETFONTS(EPSFILE) returns the cell arrays
%   of strings, AllFonts and EmbeddedFonts, that contains all the fonts
%   used in the EPS file.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epsgetfonts.html','-helpbrowser')">doc epsgetfonts</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release
% rev. 1 : (05-08-2012) added link to help browser

import EPSUtility.*;


% Input check
error(nargchk(1,1,nargin));

if ~ischar(infile)
   error('EPSFILE must be a character string.');
end

if ~exist(infile,'file')
   [~,~,e] = fileparts(infile);
   if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension
end

% Read EPS file
try
   imgdata = getdata(infile);
catch ME
   rethrow(ME);
end

% Find font data
[AllFonts,EmbeddedFonts] = getfonts(imgdata);

% Add leading slashes
Nfonts = numel(AllFonts);
if Nfonts>0
   AllFonts = strcat('/',AllFonts);
   if ~isempty(EmbeddedFonts)
      EmbeddedFonts = strcat({'/'},EmbeddedFonts);
   end
end

if nargout==0 % pretty print if no output argument assigned
   embed0 = false(1,Nfonts); % true if font is already embedded
   [~,I] = ismember(EmbeddedFonts,AllFonts);
   embed0(I) = true;
   
   len = cellfun(@numel,AllFonts);
   Ncol = [max(len)+3 9]; % column width (incl. tail spaces)
   
   fprintf('\n\t\tEPSGETFONTS\n\n')
   fprintf('\tFont Name%sEmbedded?\n',repmat(' ',1,Ncol(1)-7));
   fprintf('\t%s\n',repmat('-',1,sum(Ncol)+2));
   for n = 1:Nfonts
      fprintf('\t%s%s',AllFonts{n},repmat(' ',1,Ncol(1)-len(n)));
      if embed0(n)
         fprintf('\tYES\n');
      else
         fprintf('\tNO\n');
      end
   end
   clear AllFonts
end
