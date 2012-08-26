function [ output_args ] = mkDir( varargin )
  %MKDIR Make folder without warnings
  
  s = warning('off', 'all');
  mkdir(varargin{:});
  s = warning(s);  
end

