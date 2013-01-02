function data=getData(varargin)
%     GETDATA returns a memmapfile object for a variable in the specified file
%     Construction is easy. For example, with data in a  MAT-file
%     or an HDF5 file, just construct an NMATRIX instance with:
%               DATA=GETDATA(FILENAME, VARIABLENAME);
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
%     DATA=GETDATA(FILENAME, '/STRUCTNAME/FIELD1/FIELD2/...');
%
%     To file format will normally be assumed from the file extension.
%     To force the use of a specific format, specify it at
%     construction e.g.:
%             DATA=GETDATA('myfile.dat', '/x', 'H5');
%
%     LIMITATIONS:
%     GETMAP supports:   MAT-files Version (6, 7 or 7.3)
%                        HDF5-files
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
obj=nmatrix(varargin{:},[], 'useRAM_ALWAYS');
data=obj.Map.Data.Adc;
return
end