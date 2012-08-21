function [ output_args ] = addFolder( folder )
%ADDFOLDER Adds a folder 
%   ...

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));

addpath(fullfile(pathstr,'..',folder));
%fileattrib(fullfile(pathstr,'..',folder))
end
