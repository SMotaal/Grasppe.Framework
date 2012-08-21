function f = objDE942(filterSet, oQei, oIll, oRef, oXYZ, oLab, oXYZn, oLambda)
%OBJDE94 returns the mean deltaE94 result for a transformation matrix (M)
%   The objective function used to optimize the transformation matrix to
%   minimize the mean deltaE*94 error

%filterSet = [Peaks;Widths];

%global oQei oIll oRef oXYZ oLab oXYZn oLambda

filters = gaussianFilters(filterSet, oLambda);

DC = virtualCamera(oQei,filters,oIll,oRef);

%%
% Compute estimated XYZ & Lab values from the camera signals
M = oXYZ*pinv(DC);
estXYZ = M*DC;
estLab = XYZ2Lab(estXYZ,oXYZn);

%%
% Compute CIE94 color differences from the measured values (XYZ)
DE94 = deltaE94(estLab,oLab);
f = mean(reshape(DE94,1,[]));
end

