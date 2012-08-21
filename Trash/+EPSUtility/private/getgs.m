function gsexe = getgs()
%GETGS   Get Path to the Ghostscript Executable

% Copyright 2012 Takeshi Ikuma
% History:
% rev. - : (03-02-2012) original release
% rev. 1 : (03-11-2012)
%          * Name changed from getgsexe.m -> getgs.m
%          * If failed to access Ghostscript, it now simply errors out

if ~ispref('epsutil','Ghostscript')
   error('EPS Utility Toolbox has not been setup. Please run EPSSETUP first.');
end

gsexe = getpref('epsutil','Ghostscript'); % executable path

% check to make sure that the Ghostscript program exists
[fail,msg] = system([gsexe ' -v']);
if fail || isempty(strfind(msg,'Ghostscript'))
   error('Ghostscript executable no longer exists. Please run EPSSETUP again.');
end
