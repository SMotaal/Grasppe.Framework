function [ info ] = mfileinfo(N)
%MFILEINFO stack function file information
%   Returns the dir output for dbstack frame N where N_caller=1 (default)

if nargin<1, N = 1; end;
[ST,I] = dbstack(N,'-completenames');
info = dir(ST.file);

end

