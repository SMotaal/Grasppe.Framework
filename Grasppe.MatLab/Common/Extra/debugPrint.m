function [ output_args ] = debugPrint( varargin )
  %DEBUGX Summary of this function goes here
  %   Detailed explanation goes here
  
  debugLevel = 5;
  
  args = varargin;
  
  if isnumeric(args{1})
    if args{1} > debugLevel
      return;
    else
      args = args(2:end);
    end
  end
    
    
	dispf(varargin{:});
  
end

