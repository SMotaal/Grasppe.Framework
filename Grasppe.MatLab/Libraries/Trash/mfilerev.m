function [ rev ] = mfilerev(N)
%MMODIFIED stack function file modification code
%   Returns the modfied code for dbstack frame N where N_caller=1 (default)

if nargin<1, N = 1; end;
mfi = mfileinfo(1+N); 
rev = datestr(mfi.date, 'yymmdd.HHMM');

end

