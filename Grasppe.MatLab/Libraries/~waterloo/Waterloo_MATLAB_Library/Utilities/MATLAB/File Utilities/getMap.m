function map=getMap(filename, dataset, fileformat, option)
%     GETMAP returns a memmapfile object for a variable in the specified file
%     Construction is easy. For example, with data in a  MAT-file
%     or an HDF5 file, just construct an memmapfile instance with:
%               MyMap=GETMAP(FILENAME, VARIABLENAME);
%     where filename is a string giving the fully qualified
%     file name and variablename is the name of the required
%     variable in that file.
%
%     variablename should be a string describing a vector or matrix
%     of a primitive data type such as double, single, uint8, logical
%     etc. (or an HDF5 equivalent). The data should be real-valued, and
%     non-sparse.
%
%     Structures and objects are supported
%     The data may be in a structure or object: just give the path to
%     the matrix e.g.
%     MyMap=GETMAP(FILENAME, '/STRUCTNAME/FIELD1/FIELD2/...');
%
%     To file format will normally be assumed from the file extension.
%     To force the use of a specific format, specify it at
%     construction e.g.:
%             MyMap=NMATRIX('myfile.dat', '/x', 'H5');
%
%     LIMITATIONS:
%     [1] MAT-files Version 6 Fully supported
%     [2] MAT files Version 7 & 7.3
%           You must explicitly set the usecopy_always flag e.g
%           MyMap=GETMAP('MYFILE.DAT', '/x', 'mat', 'usecopy_always');
%           A temporary V6 MAT-file will be created and mappped.
%           The user is responsible for deleting this as required.
%     [3] HDF5-files if the accessed data set is not  "chunked"
%                                   or compressed.
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

% Create an nmatrix. Note this allows us to use the nmatrix class internal
% hashtable for efficiently mapping of MAT-file contents
switch nargin
    case {0,1}
        error('You must specify a file and data set');
    case 2
        fileformat=[];
        option='usecopy_never';
    case 3
        option='usecopy_never';
end
try
    obj=nmatrix(filename, dataset, fileformat, option);
catch ex
    switch ex.identifier
        case 'nmatrix:UnsupportedFormat'
            throw(MException('nmatrix:UnsupportedFormat',...
                'getMap: With MAT files Version 7 & 7.3 you must explicitly set the usecopy_always flag\ne.g mymap=getMap(''myfile.dat'', ''/x'', ''mat'', ''usecopy_always'');\nA temporary V6 MAT-file will be created and mappped.\nThe user is responsible for deleting this as required.'));
        otherwise
            rethrow(ex);
    end
end
obj.setDeleteOnDelete(false);
% Force map creation
obj.instantiateMap();
% Now return the map
map=obj.Map;
delete(obj);
return
end