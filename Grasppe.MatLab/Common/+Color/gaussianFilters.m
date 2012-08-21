function [ filters ] = gaussianFilters( filterSet, bandwidths )
%GAUSSIANFILTERS Summary of this function goes here
%   Detailed explanation goes here

% takes as input a 2-by-n matrix of peak wavelengths and filter
% bandwidths and an 1-by-m matrix of wavelength sample points and returns a
% m-by-n matrix of gaussian absorption filter transmittances using the
% following formula.

peaks = filterSet(1,:);
widths = filterSet(2,:);

t = zeros(numel(bandwidths),numel(peaks));

for x = 1:numel(bandwidths)
    band = bandwidths(x);
    for f = 1:numel(peaks)
        peak = peaks(f);
        width = widths(f);
        %if (band > peak-width) && (band < peak+width),
            t(x,f) = exp(-pi*((0.9394/width)^2.0)*((band-peak)^2.0));
            %t(x,f) = max(t(x,f),0);
        %end
    end
end

filters = t; %zeros(numel(peaks),numel(bandwidths));

% for f = 1:numel(peaks)
%    fi = t(f,:)>0;
%    filters(f,:) = interp1(bandwidths(fi),t(f,fi), bandwidths,'cubic','extrap');
%end

end

