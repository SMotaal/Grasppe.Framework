function epsfixfonts(infile,outfile,embedsymbol)
%EPSFIXFONTS   Fixes font issues on Matlab EPS figure outputs
%   EPSFIXFONTS(EPSFILE) analyzes the MATLAB-generated EPS file specified
%   by the string EPSFILE and fixes the font-related issues in the file.
%
%   The main fix is to embed missing AMS LaTeX fonts. Some versions of
%   Matlab are not equipped with the full library of the AMS LaTeX math
%   fonts (namely, they are missing Computer Modern san serif fonts,
%   mwa_cmss10, mwa_cmssbx10, and mwa_cmssi10). Consequently, these fonts
%   are not properly embedded in the EPS file, resulting in incorrectly
%   rendered equations in EPS. EPSFIXFONTS properly embeds these missing
%   fonts (only if used) to EPSFILE.
%
%   EPSFIXFONTS(EPSFILE,OUTFILE) saves the modified EPS data to a file
%   specified by the string OUTFILE.
%
%   EPSFIXFONTS(...,EMBEDSYMBOL) in addition embeds a public-domain font
%   (StandardSymL) for Symbol font, which is used for all TeX expressions
%   used in the Matlab figures.
%
%   The exact items changed in the EPS file are as follows:
%   1. Re-embed all AMS LaTeX fonts and (if requested) Symbol font. Only
%      the necessary subset of each font will be embedded.
%   2. '%%DocumentNeededFonts' header entry is replaced with the pair of
%      '%%DocumentNeededResources' and '%%DocumentSuppliedResources'. The
%      replaced entries completely lists all the fonts used.
%   3. All '%%BeginDocument' - '%%EndDocument' pairs are replaced with
%      '%%BeginResource' - '%%EndResource' pairs
%   4. All embedded font definitions (each begins with '%%BeginResource'
%      and ends with '%%EndResource') are moved to the Prolog block.
%
%   For the details of EPS file format and specification, consult the PDF
%   documents on the following link:
%      http://partners.adobe.com/public/developer/en/ps

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-18-2012) - rewritten to modularize
%                       - calls private functions: getfonts
%                       - fixes inconsistent font name cases in DSC comments
% rev. 2 : (05-03-2012) - fixed bug in determining missing embedded font
%                       - updated help text
%                       - program structure change (all existing embedded 
%                         font data are removed then re-embedded by calling 
%                         epsembedfont)

import EPSUtility.*;


error(nargchk(1,3,nargin));
if nargin<2
   outfile = '';
end
if nargin<3
   if ~ischar(outfile)
      embedsymbol = outfile;
      outfile = '';
   else
      embedsymbol = [];
   end
end

% Check input file
if ~ischar(infile) || size(infile,1)>1 || size(infile,2)==0
   error('EPSFILE must be a row vector of characters.');
end
[~,~,e] = fileparts(infile);
if isempty(e), infile = [infile '.eps']; end % auto-append '.eps' extension

if isempty(outfile)
   outfile = infile;
elseif ~ischar(outfile) || size(outfile,1)>1 || size(outfile,2)==0
   error('OUTFILE must be a row vector of characters.');
else
   [~,~,e] = fileparts(outfile);
   if isempty(e), outfile = [outfile '.eps']; end % auto-append '.eps' extension
end

if isempty(embedsymbol)
   embedsymbol = false;
elseif ~islogical(embedsymbol) || numel(embedsymbol)~=1
   error('EMBEDSYMBOL must be a logical scalar value (true/false).');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analyze the figure EPS file first
try
   [imgdata,wmfdata,tifdata] = getdata(infile);
catch ME
   rethrow(ME);
end

% get all fonts
AllFonts = getfonts(imgdata);

% Find all embedded font data
[Istart,Iend,fn]=regexp(imgdata,'%%BeginDocument:\s+(\S)+\s+(.*?)%%EndDocument\s+','start','end','tokens');
if isempty(Istart) % figure has no text
   EmbeddedFonts = {};
else
   % make regexp output easier to access
   N = numel(fn);
   EmbeddedFontData = reshape([fn{:}],2,N);
   
   % get actual font name from font data
   fn = regexp(EmbeddedFontData(2,:),'/FontName\s+/(\S+)\s','tokens','once');
   EmbeddedFonts = cell(1,N);
   I = cellfun(@isempty,fn);
   EmbeddedFonts(I) = EmbeddedFontData(1,I); % if data missing, use the DSC name
   EmbeddedFonts(~I) = [fn{:}];

   % remove the existing font data
   for n = N:-1:1
      imgdata(Istart(n):Iend(n)) = [];
   end
   
   % make sure no duplicated font definitions (CMMI10 duped in R2010B)
   EmbeddedFonts = unique(EmbeddedFonts);

   % Prepare EPSEMBEDFONT arguments to add these missing fonts
   EmbedFontOptions = strcat('+',EmbeddedFonts);
   
   % Replace '%%DocumentNeededFonts' header line with more complete, DSCv3
   % compliant '%%DocumentNeededResources' & '%%DocumentSuppliedResources:'
   rscstr = '%%DocumentNeededResources:';
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
   rscstr = sprintf('%s\n%%%%DocumentSuppliedResources:\n',rscstr);
   imgdata = regexprep(imgdata,'%%DocumentNeededFonts:.+?(?>[\r\n]{1,2})(?!%%\+)',rscstr,'once');
end

% Output modified EPS data to the file
try
   putdata(outfile,imgdata,wmfdata,tifdata);
catch ME
   rethrow(ME);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Embed necessary fonts

% Also embed Symbol font (by replacing it with StandardSymL font)
if embedsymbol && any(strcmp('Symbol',AllFonts))
   Symbol = {'+Symbol'};
elseif isempty(EmbeddedFonts)
   return; % no fonts to be embedded
else
   Symbol = {};
end

% Reaches here if at least 1 font to be embedded
try
   epsembedfont(outfile,EmbedFontOptions{:},Symbol{:});
catch ME
   rethrow(ME);
end
