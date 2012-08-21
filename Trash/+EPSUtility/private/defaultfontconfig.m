function defaultfontconfig()
%DEFAULTFONTCONFIG   Configure font configurations.
%   DEFAULTFONTCONFIG sets up the Type 1 font search path and font
%   aliases by searching two locations:
%
%      %MATLABPATH%/sys
%      %EPSUTILPATH%/fonts
%
%   These locations are searched recursively for PFB files and Fontmap
%   file. Any directory that contains a valid PFB file is included to the
%   font search path, and all font aliases with known fonts defined in
%   Fontmap file are logged for the use by EPS Utility Toolbox.
%
%   NOTE: In R2010b (and possibly other releases), three fonts are
%   noticeably missing: mwa_cmss10.pfb, mwa_cmssbx10.pfb, and
%   mwa_cmssi10.pfb. They are the Computer Modern san serif fonts to render
%   LaTeX texts. If DEFAULTFONTCONFIG detects these fonts are missing,
%   it automatically sets up alias for these fonts so that AMS CM fonts
%   will be used (if available). User will be prompted to download the AMS
%   fonts and place them in %EPSUTILPATH%/fonts directory.

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-19-2012) original release


% get font subfolder (under main upsutil folder)
fontdir = [fileparts(fileparts(which(mfilename))) filesep 'fonts'];
if ~isdir(fontdir)
   mkdir(fontdir);
end

% traverse MATLAB sys directory and gather all fonts and font maps
dirs = {fontdir [matlabroot filesep 'sys']};

fp = {}; % font path
while ~isempty(dirs)
   currd = dirs{1}; % current directory
   dirs(1) = []; % remove current directory from the list
   
   % get directory listing of current directory
   d = dir(currd);
   d(1:2) = []; % remove . and ..
   
   % append subdirectories to dirs
   Idir = [d.isdir];
   %dirs(end+(1:sum(Idir))) = strcat(currd,filesep,{d(Idir).name});
   N = sum(Idir);
   dirs(N+(1:numel(dirs))) = dirs;
   dirs(1:N) = strcat(currd,filesep,{d(Idir).name});

   % get names of the files in the current directory
   f = {d(~Idir).name};
   
   % check for '*.pfb' and 'Fontmap' files
   ispfb = ~cellfun(@isempty,regexp(f,'.pfb$'));
   if any(ispfb)
      fp{end+1} = currd; %#ok
   end
end

% force fontdir to be in the path
if isempty(find(strcmp(fontdir,fp),1))
   fp(2:end+1) = fp;
   fp{1} = fontdir;
end

% Save the findings to EPSUTIL Preference
setpref('epsutil','FontPath',fp);

% Look in all directories in the search path for fontmap file
setpref('epsutil','FontAlias',cell(2,0)); % initialize font alias table
warning off epsutil:InvalidAlias
for n = 1:numel(fp)
   files = dir(fp{n});
   I = find(arrayfun(@(f)~f.isdir&&strcmpi(f.name,'fontmap'),files));
   
   % if fontmap exists, read in the info
   for m = 1:numel(I)
      [~] = epsfontalias([fp{n} filesep files(I(m)).name]);
   end
end
warning on epsutil:InvalidAlias

% Missing fonts in MATLAB R2011B (R2011A, too?)
I = cellfun(@isempty,findfont({'/mwa_cmb10','/mwa_cmss10'},false));
if ~I(1)||I(2)

   % If AMS fonts are not installed, warn user
   I = cellfun(@isempty,findfont({'/CMSS10','/CMSSBX10','/CMSSI10'},false));
   if any(I)
      
      % warn user for what to do
      msg = sprintf('%s %s\n\n   %s\n\n%s\n\n   %s',...
         'Installed MATLAB release is missing san serif Computer Modern fonts (CMSS10, CMSSBX10, and CMSSI10).',...
         'Download AMSFont Collection from',...
         'ftp://ftp.ams.org/pub/tex/amsfonts.zip',...
         'and place cmss10.pfb, cmssbx10.pfb, and cmssi10.pfb included in amsfonts.zip in',...
         fontdir);
      uiwait(msgbox(msg,'EPS Utility Toolbox Setup','modal'));
   else
      % Add extra alias
      [~]=epsfontalias('/mwa_cmss10','/CMSS10');
      [~]=epsfontalias('/mwa_cmssbx10','/CMSSBX10');
      [~]=epsfontalias('/mwa_cmssi10','/CMSSI10');
   end
end
