function sb = setStatus( t, h, p )
  %SETSTATUS Set status bar text and progress
  %   SB = SETSTATUS(text, h, progress) updates the status text and
  %   progress for the specified figure handle using Altman's statusbar
  %   function.
  %
  %   SB = SETSTATUS(text) updates root status, where h = 0
  %
  %   SB = SETSTATUS(text, h) updates status for specified figure handle
  %
  %   SB =
  
  %if nargin==0, return; end
  if ~NS.argPassed('t'), t=''; end
  if ~NS.argPassed('h'), h=0; end
  if ~NS.argPassed('p'), p=[]; end
  
  sb = statusbar(h, t);
  
  if isnumeric(p) && isscalar(p)
    if p==-1
      sb.ProgressBar.setIndeterminate(true);
      sb.ProgressBar.setVisible(true);
    else
      set(sb.ProgressBar, 'Minimum',0, 'Maximum',100, 'Value', p);
      sb.ProgressBar.setIndeterminate(false);
      sb.ProgressBar.setVisible(true);
      sb.ProgressBar.setString([int2str(p) '%']);
    end
  else
    try sb.ProgressBar.setVisible(false); end
  end
  
  drawnow update;
  
  
end

