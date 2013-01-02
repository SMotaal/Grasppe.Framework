function [ output_args ] = grasppe( input_args )
  %GRASPPE Summary of this function goes here
  %   Detailed explanation goes here
  
  addBaseFolders();
  
  disp('');
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
  initilizeLibraries  = false;
  
  libfolder           = 'Libraries';
  libpath             = fullfile(grasppeFolder, libfolder);
  files               = dir(libpath);
  folders             = files([files.isdir]);
  
  libs                = {folders(3:end).name};
  libs                = libs(cellfun(@(x)isequal(x,1), regexpi(libs,'~.*')));
  
  workingPath         = cd;
  
  initializeScripts   = {};
  initializeLibs      = {};
  
  libCount            = numel(libs);
  
  %% Add ~Library Paths & Execute Initialize (Pre-Loading)
  for m = 1:libCount
    try
      libFolder               = libs{m};
      libName                 = libFolder(2:end);
      libPath                 = fullfile(libpath, libFolder);
      
      if ~exist(libPath, 'dir'), continue; end
      
      addpath(libPath);
      
      includeScript           = ['include_'     lower(libName)];
      initializeScript        = ['initialize_'  lower(libName)];
      
      
      if exist(fullfile(libPath, [includeScript '.m']), 'file')==2
        try
          eval(includeScript);
        catch err
          debugStamp(err, 1);
        end
      end
      
      if exist(fullfile(libPath, [initializeScript '.m']), 'file')==2
        initializeLibs        = [initializeLibs     {libName}           ];
        initializeScripts     = [initializeScripts  {initializeScript}  ];
      end
      
    catch err
    end
  end
  
  %% Display or Execute ~Library Startup (Post-Loading) Scripts
  if initilizeLibraries && numel(initializeScripts)>0
    for m = 1:numel(initializeScripts), 
      try
        eval(initializeScripts{m});
      catch err
        debugStamp(err, 1);
      end
    end
    GrasppeKit.Utilities.DisplayText('GRASPPE ~LIBRARY LOADER', [int2str(libCount) ' libraries have been included and initialized']);
  else
    GrasppeKit.Utilities.DisplayText('GRASPPE ~LIBRARY LOADER', [int2str(libCount) ' libraries have been included but not initialized'], ...
      [strcat(initializeLibs(:)',':'), initializeScripts(:)']);
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
