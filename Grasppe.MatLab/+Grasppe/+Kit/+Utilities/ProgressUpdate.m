function ProgressUpdate(progress, varargin)
  %SETSTATU Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent hProgress;
  
  if ~exist('progress', 'var') || isempty(progress)
    try
      set(hProgress, 'Visible', 'off');
    catch err
      try delete(hProgress); end
      hProgress             = [];
    end
    return;
  end
  
  if isempty(hProgress) || ~ishandle(hProgress)
    hProgress               = waitbar(progress, varargin{:}, 'Units', 'pixels', 'Position', [25 25 365 75]);
    
    set(hProgress, 'Units', 'normalized');
  else
    waitbar(progress, hProgress, varargin{:});
  end
  
  
  set(hProgress, 'Visible', 'on');
  
  titleHandle               = get(findobj(hProgress,'Type','axes'),'Title');
  set(titleHandle,'FontSize', 8, 'FontWeight', 'bold');
end

