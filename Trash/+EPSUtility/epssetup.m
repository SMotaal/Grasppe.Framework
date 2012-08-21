function epssetup()
%EPSSETUP   Set up EPS Utility Toolbox
%   Run EPSSETUP before using EPS Utility Toolbox for the first time. The
%   folder containing EPS Utility Toolbox must be writable at the time of
%   running EPSSETUP. This setup script performs the following tasks:
%
%   1.  Adding EPS Utility Toolbox to MATLAB path
%   2.  Builds MEX functions
%   3.  Links to Ghostscript
%   4a. Sets up Type 1 font search path
%   4b. Builds Type 1 font alias table
%
%   User will be prompted to assist the setup process.
%
%   Reference Page in Help browser
%      <a href="matlab:  web('html/doc_epssetup.html','-helpbrowser')">doc epssetup</a>.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-18-2012) original release
% rev. 1 : (05-08-2012) added link to help browser

import EPSUtility.*;


dlgtitle = 'EPS Utility Toolbox Setup';
epsdir = fileparts(which(mfilename));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('STEP 1: Adding EPS Utility Toolbox to MATLAB path...');

perm = ~isempty(strfind(pathdef,epsdir));
if ~perm    % prompt only if it's not already in the path
   msg = 'Permanently add EPS Utility Toolbox to MATLAB search path?';
   switch questdlg(msg, dlgtitle, 'Yes', 'No', 'Cancel', 'Yes')
      case 'Yes'
         perm = true;
      case 'No'
         perm = false;
      otherwise % 'Cancel' or 'X'
         disp('EPSSETUP is prematurely terminated by user.');
         return;
   end
end

if perm
   p = path; % save current path
   path(pathdef); % revert to the default path
   addpath(epsdir) % add EPS Utility Toolbox directory to MATLAB path
   if savepath % save the change
      % if cannot write to matlabroot/toolbox/local create pathdef.m in userpath
      up = regexp(userpath,['([^' pathsep ']+)'],'tokens','once');
      if savepath([up{:} filesep 'pathdef.m']);
         disp('EPSSETUP failed to save the updated MATLAB path.');
      end
   end
   path(p); % revert back to the current path
   
   fprintf('   %s added to MATLAB default path.\n',epsdir);
end
addpath(epsdir) % add EPS Utility Toolbox directory to current MATLAB path
fprintf('   %s added to current MATLAB path.\n',epsdir);
disp('   ...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('STEP 2: Builds MEX functions...');

ok = true;
try
   mex('-outdir',[epsdir filesep 'private'],[epsdir filesep 'src' filesep 'decrypt.cpp']);
catch %#ok
   ok = false;
end
if ok
   fprintf('   decrypt.%s successfully compiled and added to %s%sprivate.\n',...
      mexext,epsdir,filesep);
end

ok = true;
try
   mex('-outdir',[epsdir filesep 'private'],[epsdir filesep 'src' filesep 'encrypt.cpp']);
catch %#ok
   ok = false;
end
if ok
   fprintf('   encrypt.%s successfully compiled and added to %s%sprivate.\n',...
      mexext,epsdir,filesep);
end

disp('   ...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('STEP 3: Links to Ghostscript...');
linkgs();
gs = getpref('epsutil','Ghostscript');
if isempty(gs)
   disp('   Ghostscript link not set.');
else
   fprintf('   Ghostscript executable: %s\n',gs);
end
disp('   ...done.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('STEP 4. Sets up Type 1 font search path and font alias table...');
defaultfontconfig;
epsfontpath;
epsfontalias;
disp('   ...done.');
