function map=getPartialMap(varargin)
% getPartialMap creats a memmapfile intance representing part of a data set
% 
% Examples:
% pmap=getPartialMap(filename, dataset, start, stop);
% pmap=getPartialMap(memmapfile object, start, stop);
%
% For a vector:
%     start and stop are the first and last elements
% For a matrix
%     start and stop are the linear indices into the last dimension.
%     Thus, for a 2D matrix start and stop would be the first and last column
%     to map. For a 4D matrix of dimension [m, n, p, q], q(start) to q(stop)
%     would be mapped.
%
% Data will always be represented through the pmap.Data.Adc field of the
% resulting memmapfile object.
% 
% Indexing into the resulting partial map begins at 1 (not start) so for a
% data set representing a 128x128x3x1000 matrix created with
%           pmap=getPartialMap(filename, dataset, 500, 25);
% pmap.Data.Adc(:,:,:,1) would return the data for dataset(:,:,:,500)
%
% If required, partial maps can be wrapped in a nakhur subclass such as
% nmatrix, e.g.:
%               x=nmatrix(pmap);
% Low-level i/o will then be supported
%
% SUPPORTED FILE FORMATS:
%       Version 6 MAT-files (not 7 or 7.3)
%       HDF5 data sets that are not chunked or compressed
%       Binary files through user specified memmapfile instance
%
% See also memmapfile, nakhur, nmatrix
%
%----------------------------------------------------------------------
% Part of Project Waterloo and the sigTOOL Project at King's College
% London.
% Author: Malcolm Lidierth 02/10
% Copyright © The Author & King's College London 2010-
% Email: sigtool (at) kcl.ac.uk
% ---------------------------------------------------------------------
%                               LICENSE
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ---------------------------------------------------------------------

switch nargin
    case 4
        % Need to construct a map:
        % getPartialMap(filename, dataset, start, stop)
        try
            map=getMap(varargin{1}, varargin{2});
        catch ex
            switch ex.identifier
               case 'nmatrix:UnsupportedFormat'
                   throw(MException('getPartialMap:unsupportedFormat',...
                       sprintf('Version 7/7.3 format MAT-files are not mappable using <a href="matlab:doc memmapfile">memmapfile\n</a>')));
                otherwise
                    rethrow(ex);
            end
        end
        start=varargin{3};
        stop=varargin{4};
    case 3
        % Memmapfile object supplied as input
        % getPartialMap(map, start, stop)
        map=varargin{1};
        start=varargin{2};
        stop=varargin{3};
    otherwise
        error('Too few input arguments');
end

siz=map.Format{2};

if ndims(siz)==2 && any(siz(1:2)==1)
    % Vector
    map.Offset=map.Offset+((start-1)*nakhur.sizeof(map.Format{1}));
    switch siz(1)
        case 1
            % Row vector
            map.Format{2}=[1 stop-start+1];
        otherwise
            % Column vector
            map.Format{2}=[stop-start+1 1];
    end
else
    % Matrix
    framesize=prod(siz(1:end-1));
    map.Offset=map.Offset+((start-1)*framesize*nakhur.sizeof(map.Format{1}));
    map.Format{2}=[siz(1:end-1) stop-start+1];
end

return
end