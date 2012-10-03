%% 2.1 The getCieStruct function
% Creates a structure named "cie" with the data for various CIE
% Illumninats, Color Matching Functions, and CIE eigD function.

function [ output_args ] = getCieStruct( lambda )
  %GETCIESTRUCT returns common CIE tables
  % Creates a structure named "cie" with the data for various CIE
  % Illumninats, Color Matching Functions, and CIE eigD function.
  
  [pathstr, name, ext] = fileparts(mfilename('fullpath'));
  
  
  % lambda, cmf2deg
  cmf2degTXT      = importdata(fullfile(pathstr,'data','CIE_2Deg_380-780-5nm.txt'));
  
  m.lambda        = cmf2degTXT(:,1)';
  
  m.cmf2deg       = cmf2degTXT(:,2:4);
  
  % cmf10deg
  cmf10degTXT     = importdata(fullfile(pathstr,'data','CIE_2Deg_380-780-5nm.txt'));
  
  m.cmf10deg      = cmf10degTXT(:,2:4);
  
  % illA
  illATXT         = importdata(fullfile(pathstr,'data','CIE_IllA_380-780-5nm.txt'));
  
  m.illA          = illATXT(:,2);
  
  % illD65
  illD65TXT       = importdata(fullfile(pathstr,'data','CIE_IllD65_380-780-5nm.txt'));
  
  m.illD65        = illD65TXT(:,2);
  
  % illE
  m.illE(1:81,1)  = 100';
  
  % illF
  illFTXT         = importdata(fullfile(pathstr,'data','CIE_IllF_1-12_380-780-5nm.txt'));
  
  m.illF          = illFTXT(:,2:13);
  
  %eigD
  eigDTXT         = importdata(fullfile(pathstr,'data','CIE_eigD_380-780-5nm.txt'));
  
  m.eigD          = eigDTXT(:,2:4);
  
  %isoV
  isoVTXT         = importdata(fullfile(pathstr,'data','ISO_VisualFilter_360-780-10nm.txt'));  
  m.isoV          = interp1(isoVTXT(:,1), isoVTXT(:, 2),m.lambda');
  
  % if ~exist('lambda','var'), lambda        = m.lambda; end
  
  if exist('lambda','var') && isnumeric(lambda)

    cieFields     = fieldnames(m, '-full');

    for fi = 2:length(cieFields)
      try
    
        cf        =  char(cieFields(fi));
        m.(cf)    = interp1(m.lambda',m.(cf),lambda');

      catch err 
        debugStamp();
      end
    end

    m.lambda      = lambda;
  end
  
  output_args     = m;
end

