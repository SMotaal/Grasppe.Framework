function fonts = epsfontlist()
%EPSFONTLIST Get all Type 1 fonts found in the search path.
%   EPSFONTLIST, by itself, prettyprints all Type 1 fonts found in the
%   EPSUTIL's search path.
%
%   FONTS = EPSFONTLIST returns a 2-column cell string array containing the
%   names of the fonts in the first column and a logical value in the
%   second column. The value is true if the font name is an alias.
%
%   See also EPSFONTPATH, EPSFONTALIAS.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epsfontlist.html','-helpbrowser')">doc epsfontlist</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release
% rev. 1 : (05-08-2012) added link to help browser

import EPSUtility.*;


error(nargchk(0,2,nargin));

% If FontPath has not been set, run the setup
if ~ispref('epsutil','FontAlias') || ~ispref('epsutil','FontPath')
   defaultfontconfig;
end

% Create output cell (default to 128 entries)
Ndefault = 256;
fonts = cell(Ndefault,2);
fonts(:,1) = {''};

% Add all aliases
ft = getpref('epsutil','FontAlias');
N = size(ft,2);
fonts(1:N,1) = ft(1,:);
fonts(1:N,2) = {true};

% Search the path
fp = getpref('epsutil','FontPath');
for p = 1:numel(fp)
   pfbfiles = dir([fp{p} filesep '*.pfb']);
   pfbfiles(arrayfun(@(x)x.isdir,pfbfiles)) = [];
   
   for k = 1:numel(pfbfiles)
      info = type1info(pfbread([fp{p} filesep pfbfiles(k).name]),false,false);
      N = N+1;
      fonts{N,1} = info.FontName;
      fonts{N,2} = false;
   end
end

% sort by name
fonts(N+1:end,:) = [];
[~,I] = sort(fonts(:,1));
fonts(:) = fonts(I,:);

if nargout==0 % prettyprint
   fprintf('\n\t\tEPSFONTLIST\n\n')
   if N==0
      fprintf('\tNo Type 1 font found\n');
   else
      len = cellfun(@numel,fonts(:,1));
      Ncol = max(len)+3; % column width (incl. tail spaces)
      
      fprintf('\tFont Name%sIs Alias?\n',repmat(' ',1,Ncol(1)-10));
      fprintf('\t%s\n',repmat('-',1,Ncol+9));
      for n = 1:N
         fprintf('\t%s%s',fonts{n,1},repmat(' ',1,Ncol-len(n)));
         if fonts{n,2}
            fprintf('Yes\n');
         else
            fprintf('No\n');
         end
      end
   end

   clear fonts
end

