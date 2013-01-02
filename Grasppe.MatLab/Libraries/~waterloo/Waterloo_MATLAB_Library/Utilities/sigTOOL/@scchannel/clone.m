function newobj=clone(obj)
% clone method for the scchannel class
%
% Example:
% obj=clone(obj)
%

% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/10
% Copyright © The Author & King's College London 2010-
% -------------------------------------------------------------------------

warning('off', 'MATLAB:structOnObject');
newobj=scchannel(struct(obj));
newobj.adc=clone(obj.adc);
warning('on', 'MATLAB:structOnObject');
return
end