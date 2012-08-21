function [ path ] = dataDir(varargin)
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
      docdir = fullfile(getenv('USERPROFILE'), 'My Documents');
    else;
      docdir = fullfile(getenv('HOME'), 'Documents');
    end
    
    path = fullfile(docdir, 'data');
    if (path(end) ~= filesep)
        path = [path filesep];
    end
    dirpath = path;
else
    path = dirpath;
end

if size(varargin,2) > 0
  file = fullfile(varargin{:});
  path = fullfile(dirpath, file);
end

end

