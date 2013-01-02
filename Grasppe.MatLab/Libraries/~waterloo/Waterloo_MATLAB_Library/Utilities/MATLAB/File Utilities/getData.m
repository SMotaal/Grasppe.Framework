function data=getData(varargin)
%     GETDATA data for a variable in the specified file
%
%     Use is easy. For example, with data in a  MAT-file
%     or an HDF5 file:
%               DATA=GETDATA(FILENAME, VARIABLENAME);
%     where filename is a string giving the fully qualified
%     file name and variablename is the name of the required
%     variable in that file.
%
%     variablename should be a string describing a vector or matrix
%     of a primitive data type such as double, single, uint8, logical
%     char etc. (or an HDF5 equivalent). The data should be real-valued, and
%     non-sparse.
%
%     STRUCTURES AND OBJECTS ARE SUPPORTED
%     The data may be in a structure or object: just give the path to
%     the matrix e.g.
%     DATA=GETDATA(FILENAME, '/STRUCTNAME/FIELD1/FIELD2/...');
%
%     To file format will normally be assumed from the file extension.
%     To force the use of a specific format, specify it at
%     construction e.g.:
%             DATA=GETDATA('myfile.dat', '/x', 'H5');
%
%
%     LIMITATIONS:
%     GETDATA supports:  MAT-files Version (6, 7 and 7.3) and HDF5-files
%     When data are in a structure or object, only the relevant field will
%     be loaded with Version 6 MAT-files. For other file formats, the entire 
%     structure or object will be loaded and the relevant data extracted
%     from it.
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
obj=nmatrix(varargin{:}, [], 'useRAM_ALWAYS');
data=obj.Map.Data.Adc;
return
end