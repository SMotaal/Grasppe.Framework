function ProgressUpdate(progress, varargin)
  %ProgressUpdate Summary of this function goes here
  %   Detailed explanation goes here
  
  method                    = 'statusbar';
  
  switch lower(method)
    case 'waitbar'
      if ~exist('progress', 'var')
        setWaitbar();
      else
        setWaitbar(progress, varargin{:});
      end
    case 'statusbar'
      if ~exist('progress', 'var')
        setStatusBar();
      else
        setStatusBar(progress, varargin{:});
      end
  end
end

function setStatusBar(progress, varargin)
  if ~exist('progress', 'var') || isempty(progress) || ~isnumeric(progress)
    statusbar(0, '');
  else
    progressPrefix        = 'Processing';
    progressString        = '';
    try progressPrefix    = varargin{1}; end
    if isequal(progress, 1)
      try progressString  = ['<html><b>' strtrim(progressPrefix) ': </b>Done!</html>']; end
      try GrasppeKit.Utilities.DelayedCall(@(s, e) statusbar(0, ''), 10, 'start'); end
    else
      try progressString  = ...
          ['<html><b>' strtrim(progressPrefix) ': </b>' ...
          num2str(progress*100, '%1.0f%%') ' complete'...
          '</html>']; end
    end
    try statusbar(0, regexprep(progressString, '%', '%%')); end
  end
  
  try 
    GrasppeKit.Utilities.DelayedCall(@(s, e) drawnow('expose', 'update'), 1, 'start'); 
  catch err
    drawnow('expose', 'update');
  end
end

function setWaitbar(progress, varargin)
  persistent hProgress mProgress;
  
  if ~exist('progress', 'var') || isempty(progress)
    try
      if ~isempty(varargin)
        if isempty(mProgress), mProgress = 0; end
        progress            = mProgress;
      else
        set(hProgress, 'Visible', 'off');
        return;
      end
    catch err
      try delete(hProgress); end
      hProgress             = [];
      return;
    end
  end
  
  if isempty(hProgress) || ~ishandle(hProgress)
    hProgress               = waitbar(progress, varargin{:}, 'Units', 'pixels', 'Position', [25 75 365 75]);
    set(hProgress, 'Units', 'normalized');
  else
    waitbar(progress, hProgress, varargin{:});
  end
  
  mProgress                 = progress;
  
  set(hProgress, 'Visible', 'on');
  
  
  jProgress = get(handle(hProgress),'JavaFrame');
  
  try
    jProgress.fFigureClient.getWindow().setAlwaysOnTop(true);
  catch err
    jProgress.fHG1Client.getWindow().setAlwaysOnTop(true);
  end
  % try  end
  
  titleHandle               = get(findobj(hProgress,'Type','axes'),'Title');
  set(titleHandle,'FontSize', 8, 'FontWeight', 'bold');
  
end
