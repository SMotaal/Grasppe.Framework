function [ rev ] = stackRev(N)
  %STACKREV stack function file modification code
  %   Returns the modfied code for dbstack frame N where N_caller=1 (default)
  
  if nargin<1, N = 1; end;
  mxi = MX.stackInfo(1+N);
  dtv = datevec(mxi.date);
  ym  = 12*(dtv(1)-100*round(dtv(1)/100)) + dtv(2);
  dh  = dtv(3)*24 + dtv(4);
  ms  = dtv(5)*60 + dtv(6);
  rev = [int2str(ym) '.' int2str(dh) '.' dec2hex(ms)]; %datestr(mfi.date, 'yymmdd.HHMM');
end

