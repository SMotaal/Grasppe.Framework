function [ output_args ] = grasppe( input_args )
  %GRASPPE Summary of this function goes here
  %   Detailed explanation goes here
  
  addBaseFolders();
  addLibraryFolders();
end

function addBaseFolders()
  baseFolders = {
    grasppeFolder('Common')
    };
  
  for m = 1:numel(baseFolders)
    addpath(baseFolders{m});
  end
end

function addLibraryFolders()
  
  libfolder = 'Libraries';
  libpath   = fullfile(grasppeFolder, libfolder);
  files     = dir(libpath);
  folders   = files([files.isdir]);
  
  libs      = {folders(3:end).name};
  libs      = libs(cellfun(@(x)isequal(x,1), regexpi(libs,'~.*')));
  
  for m = 1:numel(libs)
    lib = libs{m};
    addpath(fullfile(libpath, lib));
  end
  
  %rmpath(fullfile(libpath, 'Sources'));
  
  return;
end

function pathstr = grasppeFolder(varargin)
  [pathstr, name, ext] = fileparts(mfilename('fullpath'));
  
  if nargin>0
    pathstr = fullfile(pathstr, varargin{:});
  end
end
