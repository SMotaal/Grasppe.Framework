%% 4.1 The refXYZ function
% Functions are created with many factors in mind.
% Depending on the uses, the code may include added validation or in
% cases where speed is desired such validations are ignored. Here,
% speed is critical. As such, validation and error handling are not
% included with the assumption that validation is done earlier. The
% down side is that the input arguments must conform.
%
function [ XYZ ] = ref2XYZ(object, observer, lightsource )
  %REFXYZ Summary of this function goes here
  %   ref2XYZ that takes as input a vector of reflectance factor data, a set
  %   of CIE color matching functions, and the spectral power distribution
  %   of a light source, and returns a 3-by-n (n is the number of reflectance
  %   samples) vector of CIE tristimulus values (XYZ).
  
  %% 4.1.1 Examining input arguments
  % Assuming that R is a m-by-n vector of reflectance (m) data for a set of
  % objects (n), the first step is to obtain the size information.
  %
  [rM, rN] = size(object);
  
  %% 4.1.2 Setting the Variables
  % Lightsource defines the CIE Standard Illuminant (S)
  % Object(:,n) defines the set of Reflectance Factors (R)
  % Observer defines the CIE Standard Observer (CMF; Color Matching Function)
  R = object;
  CMF = observer;
  S = lightsource;
  
  %% 4.1.3 Calculating the normalizing constant (k)
  % Since the lightsource and observer data may be normalized to arbitrary
  % values at 560 nm, the k factor is used to normalize the final XYZ values.
  k = 100.0/sum(double(S).*double(CMF(:,2)));
  
  %% 4.1.4 Calculating the XYZ values
  % A for loop is used to calculate SR for each object, which are multipled
  % with the CMF - element-wise. The sums are then multipled by k. The for
  % loop makes it possible to append the XYZ output with a new row for each
  % object.
  
  XYZ = zeros(3,rN);
  
  if any(R~=1)
    for iN = 1:rN;
      SR = S.*R(:,iN);
      XYZ(:,iN) = sum([SR SR SR].*CMF);
    end
  else
      XYZ = repmat(sum([S S S].*CMF), 1, rN);
  end
  
  XYZ = XYZ*k;
  
  % for iN = 1:rN;
  %     SR = S.*R(:,iN);
  %     %XYZ(:,iN) = k .* sum(repmat(SR,1,3) .* CMF);
  % %     XYZ(:,iN) = k .* sum([SR SR SR] .* CMF);
  %     XYZ(:,iN) = k .* sum(SR.*CMF);
  % end
  
end
