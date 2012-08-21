function [ spectra ] = spectralStruct( input_args )
%SPECTRALSTRUCT Summary of this function goes here
%   Detailed explanation goes here


%%
% 1. Create a function, spectra = spectralStruct that returns a structure
% of default values for instrumental measurements (i.e. reflectance,
% radiance or transmittance spectra). As you write functions to read data
% from the unique file formats of each instrument you can insure that what
% they return is organized in a common format by initalizing your functions
% output with spectralStruct. Produce the following output when called:
%       spectra =
%       	mode: 'Invalid'
%       	instrument: ''
%       	samples: 0
%       	lambda: []
%       	data: []
%       	desc: []
%       	filename: []
%       	cct: []
    
structModel = {'mode', 'Invalid', 'instrument', '', 'samples', 0 ...
    , 'lambda', [], 'data',  [], 'desc', [], 'filename', [], 'cct', []}';

spectra = cell2struct(structModel(2:2:end), structModel(1:2:end));
end

