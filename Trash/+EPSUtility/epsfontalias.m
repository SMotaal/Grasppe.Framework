function ftout = epsfontalias(alias,actual)
%EPSFONTALIAS Get/set Type 1 font aliases.
%   EPSFONTALIAS, by itself, prettyprints EPSUTIL's search path for Type 1
%   fonts.
%
%   ALIAS = EPSFONTALIAS returns a 2-column cell string matrix, each row
%   containing the alias font name (1st col) and its actual name (2nd col).
%
%   EPSFONTALIAS(ALIAS,ACTUAL) either adds a new alias or changes the
%   existing alias, specified by the string ALIAS, to be associated with
%   an actual font, specified by the string ACTUAL. Both ALIAS and ACTUAL
%   must begin with '/'. If the actual font does not exist, no changes will
%   occur.
%
%   EPSFONTALIAS(ALIAS,'--Remove') removes the existing alias specified by
%   the string ALIAS.
%
%   EPSFONTALIAS(FONTMAP) reads a font map file specified by string
%   FONTMAP. A font map file is a text file with rows specifying the font
%   aliases. For example,
%
%      /AvantGarde-Demi /URWGothicL-Demi;
%
%   assigns the font /URWGothicL-Demi to Adobe standard /AvantGarde-Demi.
%   The line must be terminated by a semicolon and all white space
%   characters are ignored.
%
%   See also EPSFONTPATH, EPSSETUP.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epsfontalias.html','-helpbrowser')">doc epsfontalias</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release
% rev. 1 : (05-08-2012)
%    * changed alias removal argument from 'remove' to '--Remove'
%    * added link to help browser

import EPSUtility.*;


error(nargchk(0,2,nargin));

% If FontPath has not been set, run the setup
if ~ispref('epsutil','FontAlias')
   defaultfontconfig;
end

% Retrieve the font alias table
ft = getpref('epsutil','FontAlias');

if nargin>0
   if nargin==1 % set new aliases from font map file
      
      % read in the entire file
      fid = fopen(alias,'r');
      if fid<0
         error('The Fontmap file does not exist or cannot be opened.');
      end
      try
         data = fread(fid,'*char').';
      catch %#ok
         msg = ferror(fid);
         fclose(fid);
         error(msg);
      end
      fclose(fid);
      
      % get font aliases ('/ActualFontName /AliasedFontName ;')
      lines = cellfun(@(x)x{1},regexp(data,'([^\n\r]+)(?>[\n\r]{1,2})','tokens'),'UniformOutput',false).';
      lines(:) = strtrim(lines); % remove surrounding white spaces
      lines(cellfun(@(str)str(1)=='%',lines)) = []; % remove comment lines
      tok = regexp(lines,'\s*(/\S+)\s*(/\S+)\s*;','tokens','once');
      tok = [tok{:}];
      tok = reshape(tok,2,numel(tok)/2);
      
      % make sure that the actual font exists
      pfbfiles = findfont(tok(2,:),false);
      I = cellfun(@isempty,pfbfiles);
      if any(I)
         warning('epsutil:InvalidAlias','At least one alias is not set as its actual font does not exist in the EPS font search path.');
         tok(:,I) = [];
      end
      
      % update existing aliases
      [ok,I] = ismember(tok(1,:),ft(1,:));
      ft(2,I(ok)) = tok(2,ok);
      tok(:,ok) = [];
      
      % add new aliases
      N = size(tok,2);
      ft(:,N+(1:size(ft,2))) = ft;
      ft(:,1:N) = tok;
      
   else % set new alias as specified in argument
      remove = strcmpi(actual,'--Remove');
      if alias(1)~='/' || (~remove && actual(1)~='/')
         error('Both ALIAS and ACTUAL must begin with a ''/''.');
      end
      I = find(strcmp(alias,ft(1,:)),1);
      
      if remove
         if isempty(I)
            warning('epsutil:InvalidAlias','Specified ALIAS does not exist.');
         else
            ft(:,I) = []; % remove the alias
         end
      else
         if isempty(findfont(actual,false))
            warning('epsutil:InvalidAlias','Specified ACTUAL font does not exist.');
         else
            if isempty(I), I = size(ft,2)+1; end % append to the end
            ft{1,I} = alias;
            ft{2,I} = actual;
         end
      end
   end
   % save the new path
   setpref('epsutil','FontAlias',ft);
end

N = size(ft,2);
if nargout==0 % prettyprint
   fprintf('\n\t\tEPSFONTALIAS\n\n')
   if N==0
      fprintf('\tNo Type 1 font alias defined\n');
   else
      len = cellfun(@numel,ft);
      Ncol = max(len,[],2)+3; % column width (incl. tail spaces)
      
      fprintf('\tAlias%sActual Name\n',repmat(' ',1,Ncol(1)-5));
      fprintf('\t%s\n',repmat('-',1,sum(Ncol)));
      for n = 1:N
         fprintf('\t%s%s%s\n',ft{1,n},repmat(' ',1,Ncol(1)-len(1,n)),ft{2,n});
      end
   end
else
   ftout = ft.';
end
