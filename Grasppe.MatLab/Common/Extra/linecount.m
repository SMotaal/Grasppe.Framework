function [ count ] = linecount( filepath, fileext)
  %LINECOUNT Summary of this function goes here
  %   Detailed explanation goes here
  
  if nargin<1
    filepath  = '.';
  else
    %filepath = fullfile(filepath, '.');
    if exist(filepath, 'dir')==0
      if exist(['+' filepath], 'dir')~=0
        filepath = ['+' filepath];
      end
    end
  end
  
  if nargin<2
    fileext   = '*.m';
  else
    fileext   = ['*. ' fileext];
  end
  
  fileext = ['''' fileext ''''];
    
  result = system(['find ' filepath ' -name ' fileext ' | xargs wc -l']);
end

