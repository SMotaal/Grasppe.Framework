function ProgressUpdate(progress, varargin)
  %SETSTATU Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent hProgress;
  
  if ~exist('progress', 'var') || isempty(progress)
    try delete(hProgress); end
    hProgress               = [];
    return;
  end
  
  if isempty(hProgress) || ~ishandle(hProgress)
    hProgress               = waitbar(progress, varargin{:});
  else
    waitbar(progress, hProgress, varargin{:});
    set(hProgress, 'Visible', 'on');
  end
end

