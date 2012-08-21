function f = objDE94(M,DC,Lab,XYZn)
%OBJDE94 returns the mean deltaE94 result for a transformation matrix (M)
%   The objective function used to optimize the transformation matrix to
%   minimize the mean deltaE*94 error

%%
% Compute estimated XYZ & Lab values from the camera signals
estXYZ = M*DC;
estLab = XYZ2Lab(estXYZ,XYZn);

%%
% Compute CIE94 color differences from the measured values (XYZ)
DE94 = deltaE94(estLab,Lab);
f = mean(reshape(DE94,1,[]));

end

