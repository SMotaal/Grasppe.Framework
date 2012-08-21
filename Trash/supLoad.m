function [ output_args ] = supLoad( varargin )
%SUPLOAD Goes to the UniformPrinting directory and passes supLoad call
%   Passes all the arguments to supLoad

cd(projectdir('UniformPrinting'));

supLoad(varargin{:});

end

