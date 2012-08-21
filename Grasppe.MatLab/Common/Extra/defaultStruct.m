function [ structure ] = defaultStruct( default, varargin )
  %EMPTYSTRUCT create struct with fieldnames only
  
  args = cell(numel(varargin)*2,1);

  args(1:2:end) = varargin(:);
  args(2:2:end) = default;
  
  structure = struct(args{:});
  
end
