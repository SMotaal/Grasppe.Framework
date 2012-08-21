function [ structure ] = emptyStruct( varargin )
  %EMPTYSTRUCT create struct with fieldnames only
  
  args = cell(numel(varargin)*2,1);

  args(1:2:end) = varargin(:);
  
  structure = struct(args{:});
  
end
