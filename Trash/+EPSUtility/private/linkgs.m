function linkgs()
%LINKGS   Get the location of the Ghostscript executable

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-04-2012) original release
% rev. 1 : (03-11-2012) 
%          * Renamed from getgsexe to linkgs
%          * Changed preference to 'epsutil::Ghostscript'

% get existing config
if ispref('ghostscript','gsexe') % for backward compatibility
   gsexe = {getpref('ghostscript','gsexe')};
   rmpref('ghostscript');
elseif ispref('epsutil','Ghostscript')
   gsexe = {getpref('epsutil','Ghostscript')};
else
   gsexe = {};
end

% first search automatically
gsnames = [gsexe {'gs' 'gswin64c' 'gswin32c'}];
for n = 1:numel(gsnames)
   [fail,~] = system([gsnames{n} ' -v']);
   if ~fail
      gsexe = gsnames{n};
      setpref('epsutil','Ghostscript',gsexe); % save for later
      return;
   end
end

% then ask user for the location of the file
switch computer
   case {'pcwin' 'pcwin64'}
      filter = {'gswin32c.exe;gswin64c.exe','Ghostscript EXE file';'*.exe','All EXE files (*.exe)'};
   otherwise % linux/mac
      filter = {'gs','Ghostscript EXE file';'*.*','All files'};
end

[filename, pathname] = uigetfile(filter,'Locate Ghostscript executable file');
if filename==0 % cancelled
   gsexe = '';
else
   gsexe = [pathname filename];
   if any(gsexe==' '), gsexe = ['"' gsexe '"']; end
   
   % try
   [fail,msg] = system([gsexe ' -v']);
   if fail || isempty(strfind(msg,'Ghostscript'))
      gsexe = '';
      disp('Invalid Ghostscript executable specified.');
   end
end

setpref('epsutil','Ghostscript',gsexe);
