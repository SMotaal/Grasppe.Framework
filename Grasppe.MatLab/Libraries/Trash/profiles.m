function [ data_dir ] = profiles(datafile)
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
    user_dir = regexprep(userpath,'\W$',''); %system_dependent('getuserworkfolder');
    data_dir = fullfile(user_dir,'profiles');
    if (data_dir(end) ~= filesep)
        data_dir = [data_dir filesep];
    end
    dirpath = data_dir;
else
    data_dir = dirpath;
end

if exist('datafile','var')
  data_dir = fullfile(dirpath,datafile);
end

end

