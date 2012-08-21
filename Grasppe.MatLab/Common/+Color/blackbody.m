% function to return the blackbody power distribution for a given wavelength
% range in nm. Note the curve is normalized to a power of 1 at 560
%
% [spd] = blackbody(cct,lambda_nm)
%
% where cct is a row or column vector of blackbody temperatures in kelvin
% and lambda_nm is a vector of the desired wavelength sampling. The results
% are normalized such that the power at 560nm is equal to 1.
%
% Example:
%           figure;plot(400:10:700,blackbody([6000:500:7000],400:10:700));
% Plots the blackbody (planckian) radiators with temperatures of 6000, 6500
% and 7000 degrees kelvin over the range of 400 to 700 nm in increments of
% 10nm
%
% Based on code by David Spetzler (http://venables.asu.edu/quant/DavidS)
% LAT - 9/13/2005

function spd = blackbody(cct,lambda_nm)

%convert lambda from nm to meters and make column vector
lambda = lambda_nm(:).* (10.^-9);

%convert cct to a row matrix
cct = cct(:)';

%setup constants
h = 6.6261*10^-34; % Planck's constant (Js)
c = 2.9979*10^8; % Speed of light (m/s)
k = 1.3807*10^-23; % Boltzmann's constant (J/K)

%compute SPD
spd=diag((8.*pi.*h.*c)./lambda.^5)*(1./(exp((h.*c)./(k.*lambda*cct))-1));

%also compute power at 560 nm
nm560=(8.*pi.*h.*c)./(560*10^-9).^5.*(1./(exp((h.*c)./(k.*cct.*(560*10^-9)))-1));

%renormalize SPD
spd = spd*diag(1./nm560);