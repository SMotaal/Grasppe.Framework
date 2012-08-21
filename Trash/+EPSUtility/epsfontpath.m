function pout = epsfontpath(p1,p2)
%EPSFONTPATH Get/set PFB font search path.
%   EPSFONTPATH, by itself, prettyprints EPSUTIL's search path for Type 1
%   fonts (*.pfb files).
%
%   P = EPSFONTPATH returns a string containing the path in P.
%
%   EPSFONTPATH(P) changes the path to P. Like MATLAB's search path,
%   multiple directories may be registered by concatenating them with path
%   separator given by PATHSEP.
%
%   EPSFONTPATH(P1,P2) changes the path to the concatenation of the two
%   path strings P1 and P2.  Thus, EPSFONTPATH(EPSFONTPATH,P) appends a new
%   directory to the current path and EPSFONTPATH(P,EPSFONTPATH) prepends a
%   new directory.  If P is already on the path, then
%   EPSFONTPATH(EPSFONTPATH,P) moves P to the end of the path, and
%   similarly, EPSFONTPATH(P,EPSFONTPATH) moves P to the beginning of the
%   path.
%
%   See also EPSFONTALIAS, EPSSETUP.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epsfontpath.html','-helpbrowser')">doc epsfontpath</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release
% rev. 1 : (05-08-2012) added link to help browser

import EPSUtility.*;


error(nargchk(0,2,nargin));

% If FontPath has not been set, run the setup
if ~ispref('epsutil','FontPath')
   defaultfontconfig;
end

if nargin>0 % set new path
   ispc = strncmp(computer,'PC',2);
   
   p1 = regexp(p1,['([^' pathsep ']+)'],'tokens');
   p1 = [p1{:}];
   if ispc % in Windows OS
      p1 = strrep(p1,'/','\');
   end
   
   % if no path separator is included, check the path
   for n = find(cellfun(@isempty,regexp(p1,filesep,'once')))
      w = what(p1{n});
      if ~isempty(w)
         p1{n} = w(end).path;
      end
   end   
   
   if nargin>1
      p2 = regexp(p2,['([^' pathsep ']+)'],'tokens');
      p2 = [p2{:}];
      
      if ispc % in Windows OS
         p2 = strrep(p2,'/','\');
         p2(ismember(lower(p2),lower(p1))) = [];
      else % in other OS
         p2(ismember(p2,p1)) = [];
      end

      % if no path separator is included, check the path
      for n = find(cellfun(@isempty,regexp(p2,filesep,'once')))
         w = what(p2{n});
         if ~isempty(w)
            p2{n} = w(end).path;
         end
      end
      
      % remove duplicates in p2
      if ispc % in Windows OS
         p2(ismember(lower(p2),lower(p1))) = [];
      else % in other OS
         p2(ismember(p2,p1)) = [];
      end
      
      % combine 2 pathes
      p1(end+(1:numel(p2))) = p2;
   end

   % check for valid path
   N = numel(p1);
   notok = false(1,N);
   for n = 1:numel(p1)
      w = what(p1{n});
      notok(n) = isempty(w);
      if notok(n)
         disp('Warning: Name is nonexistent or not a directory: %s.',p1{n});
      else
         p1{n} = w.path; % make sure to include the full path
      end
   end
   p1(notok) = [];
   
   % only keep unique path (in case there are duplicates)
   p1 = unique(p1);

   % save the new path
   setpref('epsutil','FontPath',p1);
end

% retrieve the font path
p = getpref('epsutil','FontPath');
N = numel(p);
if nargout==0 % prettyprint
   fprintf('\n\t\tEPSFONTPATH\n\n')
   for n = 1:N
      fprintf('\t%s\n',p{n});
   end
else
   if isempty(p)
      pout = '';
   else
      Np = cellfun(@numel,p);
      len = sum(Np)+N-1;
      pout = repmat(' ',1,len);
      pout(1:Np(1)) = p{1};
      Np = [Np;ones(1,N)];
      I = cumsum(Np(:))+1;
      for n = 2:numel(p)
         pout(I(2*n-3)) = pathsep;
         pout(I(2*n-2):I(2*n-1)-1) = p{n};
      end
   end
end
