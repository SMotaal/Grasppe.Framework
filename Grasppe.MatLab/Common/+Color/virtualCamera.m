function [ DC ] = virtualCamera(QE, filters, illum, reflects)
%VIRTUALCAMERA generates DC from QE, filters, illum, reflects
%   takes as input, QE, a m-by-1 vector of the camera?s quantum
%   efficiencies, filters an m-by-k matrix of k filter transmittances,
%   illum an m-by-1 vector describing the spectral power distribution of
%   the taking illuminant, and reflects, an m-by-n matrix of n reflectance
%   samples. The function should return DC a k-by-n matrix of camera
%   signals (digital counts).
cameraWhite = filters'*(QE(:).*illum(:));
DC = (diag(1./cameraWhite) * filters' *diag(QE) *diag(illum)) * reflects;
%DC = DC(:,
end