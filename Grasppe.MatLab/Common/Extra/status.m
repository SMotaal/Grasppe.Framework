function [ sb ] = status( text, h, varargin )
  %STATUS Summary of this function goes here
  %   Detailed explanation goes here
  
  if nargin==0, return; end
  
  if nargin<2 || isempty(h), h=0; end
  
  sb = statusbar(h, text); drawnow update; %forcedraw();
  
  if numel(varargin)>=1
    pv = varargin{1};
    
    if isnumeric(pv) && isscalar(pv)
      if pv==-1
        sb.ProgressBar.setIndeterminate(true);
        sb.ProgressBar.setVisible(true);        
      else
        set(sb.ProgressBar, 'Minimum',0, 'Maximum',100, 'Value', pv);
        sb.ProgressBar.setIndeterminate(false);
        sb.ProgressBar.setVisible(true);      
        sb.ProgressBar.setString([int2str(pv) '%']);
      end
    elseif isempty(pv)
      sb.ProgressBar.setVisible(false);
    end
  end
  
end

