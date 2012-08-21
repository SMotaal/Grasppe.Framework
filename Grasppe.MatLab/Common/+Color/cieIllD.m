% Computes Spectral Power Distributions (SPD) of CIE Daylight illuminants
% (defined for range 4000 - 25000 Kelvin)
%
% [spd] = cieIllD(Tc,cie);
%
% where Tc is a vector of correlated color temperatures in degrees kelvin
% and cie is a structure containing at least the fields "lambda" and "eigD"
% where eigD is the three eigenvectors for CIE standard daylight and lambda
% is the corresponding wavelength information. SPD returns a matrix with
% one column for each SPD of the CCTs indicated in Tc. Note that the CIE
% has normalized the relative power at 560nm to 100.
%
%
%  Example: 
%           figure;plot(cie.lambda,illD([6500,8000],cie));
%  will create a plot of CIE D65 and D80

% LAT - 9/13/2005

function [spd] = cieIllD(Tc,cie)

%convert Tc to a row vector
Tc = Tc(:)';

%test that CCT is in valid range
if min(Tc) < 4000 | max(Tc) > 25000
    warning('SPD data may be bad becuase CCT not in range 4000-25000k');
end

%count the number of CCTs
n = length(Tc);

%compute xD
xD = -4.6070*10.^9./Tc.^3+2.9678*10.^6./Tc.^2+...
    0.09911*10.^3./Tc+0.244063;
list = find(Tc>7000); %find list of CCTs greater than 7000k
xD(list) = -2.0064*10.^9./Tc(list).^3+1.9018*10.^6./Tc(list).^2+...
    0.24748*10.^3./Tc(list)+0.23704;

%compute yD
yD = -3.000.*xD.^2 + 2.870.*xD - 0.275;
M1 = (-1.3515 - 1.7703.*xD + 5.9114.*yD)./(0.0241 + 0.2562.*xD  - .7341.*yD);
M2 = (0.0300 - 31.4424.*xD + 30.0717.*yD)./(0.0241 + 0.2562.*xD  - .7341.*yD);
spd = repmat(cie.eigD(:,1),[1,n]) + cie.eigD(:,2)*M1 + cie.eigD(:,3)*M2;