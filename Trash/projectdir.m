function [ projectsDir ] = projectdir(varargin)
%DATADIR Get user's data directory
%   DATADIR returns the name of the user's data directory. A file
%   separator is appended at the end.
%
%   Based on tempdir function.
%
%   See also TEMPDIR, FULLFILE.
%
%   TEMPDIR - Copyright 1984-2007 The MathWorks, Inc.
%
%   Copyright 2007-2011 Saleh Abdel Motaal.
%   $Revision: 1.0.0.1 $  $Date: 2011/07/19 16:00:00 $

persistent dirpath;
if isempty(dirpath)
  
  % Referenced Andy: http://www.mathworks.se/matlabcentral/fileexchange/15885-get-user-home-directory
    if ispc;
      projectsDir = fullfile(regexprep(userpath,';$',''));
    else;
      projectsDir = fullfile(regexprep(userpath,':$',''));
    end
    
    if (projectsDir(end) ~= filesep)
        projectsDir = [projectsDir filesep];
    end
    dirpath = projectsDir;
else
    projectsDir = dirpath;
end

if size(varargin,2) > 0
  projectsFile = fullfile(varargin{:});
  projectsDir = fullfile(dirpath, projectsFile);
end

end

